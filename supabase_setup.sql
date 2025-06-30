-- GitAlong Database Setup Script
-- Run this in your Supabase SQL Editor

-- =================
-- 1. CREATE TABLES
-- =================

-- Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('contributor', 'maintainer')),
    avatar_url TEXT,
    bio TEXT,
    github_url TEXT,
    skills TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    repo_url TEXT NOT NULL,
    skills_required TEXT[] DEFAULT '{}',
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed')),
    image_url TEXT,
    stars INTEGER,
    language TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Swipes table
CREATE TABLE IF NOT EXISTS swipes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    swiper_id UUID REFERENCES users(id) ON DELETE CASCADE,
    target_id UUID NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('left', 'right')),
    target_type TEXT NOT NULL CHECK (target_type IN ('user', 'project')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(swiper_id, target_id, target_type)
);

-- Matches table
CREATE TABLE IF NOT EXISTS matches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contributor_id UUID REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(contributor_id, project_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'file')),
    is_read BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Badges table
CREATE TABLE IF NOT EXISTS badges (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    badge_type TEXT NOT NULL CHECK (badge_type IN ('firstMatch', 'fiveMatches', 'tenMatches', 'firstPr', 'fivePrs', 'tenPrs', 'streakWarrior', 'openSourceHero', 'earlyAdopter')),
    description TEXT,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, badge_type)
);

-- Contributions table
CREATE TABLE IF NOT EXISTS contributions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('started', 'prOpen', 'merged', 'closed')),
    pr_url TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Saved projects table
CREATE TABLE IF NOT EXISTS saved_projects (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, project_id)
);

-- =================
-- 2. CREATE INDEXES
-- =================

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_swipes_swiper_target ON swipes(swiper_id, target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_messages_participants ON messages(sender_id, receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_projects_owner ON projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(receiver_id, is_read);

-- =================
-- 3. ENABLE ROW LEVEL SECURITY
-- =================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_projects ENABLE ROW LEVEL SECURITY;

-- =================
-- 4. CREATE RLS POLICIES
-- =================

-- Users table policies
CREATE POLICY "Users can view all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Projects table policies  
CREATE POLICY "Projects are publicly readable" ON projects FOR SELECT USING (true);
CREATE POLICY "Users can create projects" ON projects FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Users can update own projects" ON projects FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Users can delete own projects" ON projects FOR DELETE USING (auth.uid() = owner_id);

-- Swipes table policies
CREATE POLICY "Users can view own swipes" ON swipes FOR SELECT USING (auth.uid() = swiper_id);
CREATE POLICY "Users can create own swipes" ON swipes FOR INSERT WITH CHECK (auth.uid() = swiper_id);

-- Matches table policies
CREATE POLICY "Users can view own matches" ON matches 
FOR SELECT USING (
    auth.uid() = contributor_id OR 
    auth.uid() IN (SELECT owner_id FROM projects WHERE id = project_id)
);
CREATE POLICY "System can create matches" ON matches FOR INSERT WITH CHECK (true);

-- Messages table policies
CREATE POLICY "Users can view own messages" ON messages 
FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send messages" ON messages 
FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Users can update own messages" ON messages 
FOR UPDATE USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Badges table policies
CREATE POLICY "Users can view all badges" ON badges FOR SELECT USING (true);
CREATE POLICY "System can award badges" ON badges FOR INSERT WITH CHECK (true);

-- Contributions table policies
CREATE POLICY "Users can view own contributions" ON contributions 
FOR SELECT USING (
    auth.uid() = user_id OR 
    auth.uid() IN (SELECT owner_id FROM projects WHERE id = project_id)
);
CREATE POLICY "Users can create own contributions" ON contributions 
FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own contributions" ON contributions 
FOR UPDATE USING (auth.uid() = user_id);

-- Saved projects table policies
CREATE POLICY "Users can view own saved projects" ON saved_projects 
FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can save projects" ON saved_projects 
FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unsave projects" ON saved_projects 
FOR DELETE USING (auth.uid() = user_id);

-- =================
-- 5. CREATE FUNCTIONS
-- =================

-- Function to automatically update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to tables that have updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON projects 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_contributions_updated_at ON contributions;
CREATE TRIGGER update_contributions_updated_at 
    BEFORE UPDATE ON contributions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to get user conversations for messaging
CREATE OR REPLACE FUNCTION get_user_conversations(user_id UUID)
RETURNS TABLE (
    other_user_id UUID,
    other_user_name TEXT,
    other_user_avatar TEXT,
    last_message TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE,
    unread_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    WITH conversation_partners AS (
        SELECT 
            CASE 
                WHEN sender_id = user_id THEN receiver_id 
                ELSE sender_id 
            END AS partner_id,
            content AS last_msg,
            timestamp AS last_time,
            ROW_NUMBER() OVER (
                PARTITION BY CASE 
                    WHEN sender_id = user_id THEN receiver_id 
                    ELSE sender_id 
                END 
                ORDER BY timestamp DESC
            ) as rn
        FROM messages 
        WHERE sender_id = user_id OR receiver_id = user_id
    ),
    latest_messages AS (
        SELECT partner_id, last_msg, last_time
        FROM conversation_partners 
        WHERE rn = 1
    ),
    unread_counts AS (
        SELECT sender_id as partner_id, COUNT(*) as count
        FROM messages 
        WHERE receiver_id = user_id AND is_read = false
        GROUP BY sender_id
    )
    SELECT 
        lm.partner_id,
        u.name,
        u.avatar_url,
        lm.last_msg,
        lm.last_time,
        COALESCE(uc.count, 0)
    FROM latest_messages lm
    JOIN users u ON u.id = lm.partner_id
    LEFT JOIN unread_counts uc ON uc.partner_id = lm.partner_id
    ORDER BY lm.last_time DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================
-- 6. ENABLE REALTIME
-- =================

-- Enable realtime for important tables
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE matches;

-- =================
-- 7. INSERT SAMPLE DATA (Optional)
-- =================

-- Sample projects for testing (uncomment if you want sample data)
/*
INSERT INTO projects (title, description, repo_url, skills_required, owner_id, language) VALUES 
('React Todo App', 'A simple todo application built with React and TypeScript. Perfect for beginners looking to contribute to open source.', 'https://github.com/example/react-todo', ARRAY['React', 'TypeScript', 'JavaScript'], '00000000-0000-0000-0000-000000000000', 'JavaScript'),
('Python Data Analysis', 'Data analysis tools and scripts using pandas and matplotlib. Great for data science enthusiasts.', 'https://github.com/example/python-analysis', ARRAY['Python', 'Pandas', 'Matplotlib'], '00000000-0000-0000-0000-000000000000', 'Python'),
('Flutter Weather App', 'Cross-platform weather application with beautiful UI and real-time data.', 'https://github.com/example/flutter-weather', ARRAY['Flutter', 'Dart', 'Mobile'], '00000000-0000-0000-0000-000000000000', 'Dart');
*/

-- =================
-- SETUP COMPLETE! 
-- =================

-- Your GitAlong database is now ready!
-- Tables created: users, projects, swipes, matches, messages, badges, contributions, saved_projects
-- Security: Row Level Security enabled with proper policies
-- Performance: Indexes added for optimal query performance
-- Realtime: Enabled for messages and matches
-- Functions: Auto-update timestamps and conversation helpers 