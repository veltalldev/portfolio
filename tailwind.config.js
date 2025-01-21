/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.{html,md}",
    "./themes/**/layouts/**/*.html"
  ],
  darkMode: 'class',
  theme: {
    extend: {},
  },
  plugins: [],
}

