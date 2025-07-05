# GitAlong Website

A modern, responsive website for GitAlong - a platform that helps developers find coding partners and collaborators.

## 🚀 Features

- **Modern Design**: Beautiful, responsive design with smooth animations
- **Authentication**: Firebase-powered sign in/sign up with Google and GitHub
- **Real-time**: Live updates and notifications
- **Mobile-First**: Optimized for all devices
- **Performance**: Fast loading with optimized builds

## 🛠️ Tech Stack

- **Frontend**: React 18 + TypeScript
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **Authentication**: Firebase Auth
- **Database**: Firestore
- **Deployment**: Vercel
- **Build Tool**: Vite

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   ```
   
   Fill in your Firebase configuration in `.env.local`:
   ```env
   VITE_FIREBASE_API_KEY=your_api_key_here
   VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   VITE_FIREBASE_PROJECT_ID=your_project_id
   VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   VITE_FIREBASE_APP_ID=your_app_id
   VITE_FIREBASE_MEASUREMENT_ID=your_measurement_id
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

## 🚀 Deployment to Vercel

### Automatic Deployment (Recommended)

1. **Connect to Vercel**
   - Push your code to GitHub
   - Connect your repository to Vercel
   - Vercel will automatically detect the Vite configuration

2. **Set Environment Variables**
   - Go to your Vercel project dashboard
   - Navigate to Settings → Environment Variables
   - Add all Firebase environment variables from `.env.example`

3. **Deploy**
   - Vercel will automatically build and deploy on every push to main branch

### Manual Deployment

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Build the project**
   ```bash
   npm run build
   ```

3. **Deploy**
   ```bash
   vercel --prod
   ```

## 🔧 Build Commands

```bash
# Development
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

## 📁 Project Structure

```
project/
├── src/
│   ├── components/     # Reusable UI components
│   ├── pages/         # Page components
│   ├── contexts/      # React contexts
│   ├── lib/           # Utility libraries
│   └── assets/        # Static assets
├── public/            # Public assets
├── dist/              # Build output
└── vercel.json        # Vercel configuration
```

## 🔒 Environment Variables

Make sure to set these environment variables in your Vercel deployment:

- `VITE_FIREBASE_API_KEY`
- `VITE_FIREBASE_AUTH_DOMAIN`
- `VITE_FIREBASE_PROJECT_ID`
- `VITE_FIREBASE_STORAGE_BUCKET`
- `VITE_FIREBASE_MESSAGING_SENDER_ID`
- `VITE_FIREBASE_APP_ID`
- `VITE_FIREBASE_MEASUREMENT_ID`

## 🎨 Customization

### Colors
The website uses a GitHub-inspired dark theme with green accents. Colors are defined in Tailwind CSS classes throughout the components.

### Animations
Animations are powered by Framer Motion. You can customize animations in the component files.

### Content
Update content in the component files:
- `HeroSection.tsx` - Main hero content
- `FeaturesSection.tsx` - Feature descriptions
- `TestimonialsSection.tsx` - User testimonials
- `AboutPage.tsx` - About page content

## 📱 Performance

- **Code Splitting**: Automatic code splitting with Vite
- **Image Optimization**: Optimized images and assets
- **Caching**: Proper cache headers for static assets
- **Bundle Analysis**: Use `npm run build` to analyze bundle size

## 🔍 SEO

- Meta tags are configured in `index.html`
- Open Graph tags for social sharing
- Proper title and description tags

## 🐛 Troubleshooting

### Build Issues
- Ensure all environment variables are set
- Check that all dependencies are installed
- Verify TypeScript compilation

### Deployment Issues
- Check Vercel build logs
- Verify environment variables in Vercel dashboard
- Ensure `vercel.json` is properly configured

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

Built with ❤️ by developers, for developers. 