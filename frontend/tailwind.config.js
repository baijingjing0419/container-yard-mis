/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#1e40af',
        'primary-light': '#3b82f6',
        secondary: '#0ea5e9',
        accent: '#06b6d4',
        dark: '#0f172a',
        sidebar: '#1e293b',
        card: '#ffffff',
        bg: '#f1f5f9',
      },
    },
  },
  plugins: [],
}
