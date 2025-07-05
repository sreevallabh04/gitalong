import { Octokit } from '@octokit/rest';

// Initialize Octokit with GitHub API
const octokit = new Octokit({
  auth: process.env.REACT_APP_GITHUB_TOKEN,
});

export interface GitHubUser {
  id: number;
  login: string;
  avatar_url: string;
  name: string;
  bio: string;
  public_repos: number;
  followers: number;
  following: number;
  created_at: string;
  location: string;
  company: string;
  blog: string;
  twitter_username: string;
}

export interface Repository {
  id: number;
  name: string;
  full_name: string;
  description: string;
  html_url: string;
  stargazers_count: number;
  forks_count: number;
  language: string;
  topics: string[];
  updated_at: string;
  visibility: string;
  default_branch: string;
}

export interface Commit {
  sha: string;
  commit: {
    message: string;
    author: {
      name: string;
      email: string;
      date: string;
    };
  };
  author: {
    login: string;
    avatar_url: string;
  };
}

export interface SearchResult {
  total_count: number;
  incomplete_results: boolean;
  items: GitHubUser[];
}

class GitHubService {
  // Mock data for development
  private mockUsers: GitHubUser[] = [
    {
      id: 1,
      login: 'alice-dev',
      avatar_url: 'https://avatars.githubusercontent.com/u/1?v=4',
      name: 'Alice Johnson',
      bio: 'Full-stack developer passionate about React, Node.js, and open source',
      public_repos: 45,
      followers: 234,
      following: 89,
      created_at: '2018-03-15T10:30:00Z',
      location: 'San Francisco, CA',
      company: 'TechCorp',
      blog: 'https://alice.dev',
      twitter_username: 'alice_dev'
    },
    {
      id: 2,
      login: 'bob-contributor',
      avatar_url: 'https://avatars.githubusercontent.com/u/2?v=4',
      name: 'Bob Smith',
      bio: 'Backend engineer specializing in Python, Django, and microservices',
      public_repos: 32,
      followers: 156,
      following: 67,
      created_at: '2019-07-22T14:20:00Z',
      location: 'New York, NY',
      company: 'StartupXYZ',
      blog: 'https://bobsmith.dev',
      twitter_username: 'bob_contributor'
    },
    {
      id: 3,
      login: 'carol-maintainer',
      avatar_url: 'https://avatars.githubusercontent.com/u/3?v=4',
      name: 'Carol Davis',
      bio: 'DevOps engineer and open source maintainer. Love Docker, Kubernetes, and CI/CD',
      public_repos: 78,
      followers: 445,
      following: 123,
      created_at: '2017-11-08T09:15:00Z',
      location: 'Austin, TX',
      company: 'CloudTech',
      blog: 'https://carol.dev',
      twitter_username: 'carol_maintainer'
    },
    {
      id: 4,
      login: 'david-flutter',
      avatar_url: 'https://avatars.githubusercontent.com/u/4?v=4',
      name: 'David Wilson',
      bio: 'Mobile developer focused on Flutter, React Native, and cross-platform solutions',
      public_repos: 28,
      followers: 189,
      following: 94,
      created_at: '2020-01-12T16:45:00Z',
      location: 'Seattle, WA',
      company: 'MobileFirst',
      blog: 'https://david.dev',
      twitter_username: 'david_flutter'
    },
    {
      id: 5,
      login: 'emma-ai',
      avatar_url: 'https://avatars.githubusercontent.com/u/5?v=4',
      name: 'Emma Chen',
      bio: 'ML engineer and data scientist. Working on AI/ML projects and contributing to open source',
      public_repos: 56,
      followers: 312,
      following: 78,
      created_at: '2018-09-30T11:30:00Z',
      location: 'Boston, MA',
      company: 'AITech',
      blog: 'https://emma.dev',
      twitter_username: 'emma_ai'
    }
  ];

  private mockRepositories: Repository[] = [
    {
      id: 1,
      name: 'react-todo-app',
      full_name: 'alice-dev/react-todo-app',
      description: 'A modern React todo application with TypeScript and Tailwind CSS',
      html_url: 'https://github.com/alice-dev/react-todo-app',
      stargazers_count: 156,
      forks_count: 23,
      language: 'TypeScript',
      topics: ['react', 'typescript', 'todo', 'frontend'],
      updated_at: '2024-01-15T10:30:00Z',
      visibility: 'public',
      default_branch: 'main'
    },
    {
      id: 2,
      name: 'python-api',
      full_name: 'bob-contributor/python-api',
      description: 'FastAPI-based REST API with PostgreSQL and Docker',
      html_url: 'https://github.com/bob-contributor/python-api',
      stargazers_count: 89,
      forks_count: 12,
      language: 'Python',
      topics: ['fastapi', 'python', 'api', 'postgresql'],
      updated_at: '2024-01-14T15:20:00Z',
      visibility: 'public',
      default_branch: 'main'
    },
    {
      id: 3,
      name: 'kubernetes-tools',
      full_name: 'carol-maintainer/kubernetes-tools',
      description: 'Collection of useful Kubernetes tools and scripts for DevOps',
      html_url: 'https://github.com/carol-maintainer/kubernetes-tools',
      stargazers_count: 234,
      forks_count: 45,
      language: 'Shell',
      topics: ['kubernetes', 'devops', 'docker', 'automation'],
      updated_at: '2024-01-13T09:15:00Z',
      visibility: 'public',
      default_branch: 'main'
    }
  ];

  private mockCommits: Commit[] = [
    {
      sha: 'abc123def456',
      commit: {
        message: 'feat: Add user authentication system',
        author: {
          name: 'Alice Johnson',
          email: 'alice@example.com',
          date: '2024-01-15T10:30:00Z'
        }
      },
      author: {
        login: 'alice-dev',
        avatar_url: 'https://avatars.githubusercontent.com/u/1?v=4'
      }
    },
    {
      sha: 'def456ghi789',
      commit: {
        message: 'fix: Resolve authentication bug in login flow',
        author: {
          name: 'Alice Johnson',
          email: 'alice@example.com',
          date: '2024-01-14T15:20:00Z'
        }
      },
      author: {
        login: 'alice-dev',
        avatar_url: 'https://avatars.githubusercontent.com/u/1?v=4'
      }
    },
    {
      sha: 'ghi789jkl012',
      commit: {
        message: 'docs: Update README with installation instructions',
        author: {
          name: 'Alice Johnson',
          email: 'alice@example.com',
          date: '2024-01-13T09:15:00Z'
        }
      },
      author: {
        login: 'alice-dev',
        avatar_url: 'https://avatars.githubusercontent.com/u/1?v=4'
      }
    }
  ];

  // Search users
  async searchUsers(query: string, page: number = 1): Promise<SearchResult> {
    try {
      if (process.env.NODE_ENV === 'development') {
        // Return mock data in development
        const filteredUsers = this.mockUsers.filter(user =>
          user.login.toLowerCase().includes(query.toLowerCase()) ||
          user.name?.toLowerCase().includes(query.toLowerCase()) ||
          user.bio?.toLowerCase().includes(query.toLowerCase())
        );
        
        return {
          total_count: filteredUsers.length,
          incomplete_results: false,
          items: filteredUsers.slice((page - 1) * 10, page * 10)
        };
      }

      const response = await octokit.search.users({
        q: query,
        page,
        per_page: 10
      });

      return response.data;
    } catch (error) {
      console.error('Error searching users:', error);
      throw error;
    }
  }

  // Get user profile
  async getUser(username: string): Promise<GitHubUser> {
    try {
      if (process.env.NODE_ENV === 'development') {
        const user = this.mockUsers.find(u => u.login === username);
        if (!user) {
          throw new Error('User not found');
        }
        return user;
      }

      const response = await octokit.users.getByUsername({ username });
      return response.data;
    } catch (error) {
      console.error('Error fetching user:', error);
      throw error;
    }
  }

  // Get user repositories
  async getUserRepositories(username: string): Promise<Repository[]> {
    try {
      if (process.env.NODE_ENV === 'development') {
        return this.mockRepositories.filter(repo => 
          repo.full_name.startsWith(`${username}/`)
        );
      }

      const response = await octokit.repos.listForUser({ username });
      return response.data;
    } catch (error) {
      console.error('Error fetching repositories:', error);
      throw error;
    }
  }

  // Get repository README
  async getRepositoryReadme(owner: string, repo: string): Promise<string> {
    try {
      if (process.env.NODE_ENV === 'development') {
        return `# ${repo}

This is a sample README for the ${repo} repository.

## Features

- Modern React/TypeScript setup
- Tailwind CSS for styling
- Responsive design
- Unit tests with Jest
- CI/CD pipeline

## Installation

\`\`\`bash
npm install
npm start
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details
`;
      }

      const response = await octokit.repos.getReadme({
        owner,
        repo,
        mediaType: {
          format: 'html'
        }
      });

      return response.data as string;
    } catch (error) {
      console.error('Error fetching README:', error);
      return 'README not available';
    }
  }

  // Get repository commits
  async getRepositoryCommits(owner: string, repo: string): Promise<Commit[]> {
    try {
      if (process.env.NODE_ENV === 'development') {
        return this.mockCommits;
      }

      const response = await octokit.repos.listCommits({
        owner,
        repo,
        per_page: 10
      });

      return response.data;
    } catch (error) {
      console.error('Error fetching commits:', error);
      throw error;
    }
  }

  // Get trending repositories
  async getTrendingRepositories(): Promise<Repository[]> {
    try {
      if (process.env.NODE_ENV === 'development') {
        return this.mockRepositories;
      }

      const response = await octokit.search.repos({
        q: 'created:>2024-01-01',
        sort: 'stars',
        order: 'desc',
        per_page: 10
      });

      return response.data.items;
    } catch (error) {
      console.error('Error fetching trending repositories:', error);
      throw error;
    }
  }
}

export const githubService = new GitHubService(); 