/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        'mono': ['JetBrains Mono', 'SF Mono', 'Monaco', 'Inconsolata', 'Fira Code', 'Consolas', 'Courier New', 'monospace'],
      },
      colors: {
        github: {
          bg: '#0D1117',
          secondary: '#161B22',
          border: '#30363D',
          green: '#2EA043',
        }
      }
    },
  },
  plugins: [],
};