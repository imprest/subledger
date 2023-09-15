// const colors = require('tailwindcss/colors');
// const { fontFamily } = require("tailwindcss/defaultTheme");

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class'],
  content: [
    './src/**/*.{html,js,svelte,ts}',
    '../lib/ghr_web/{components,controllers}/**/*.{heex,ex}'
  ],
  theme: {
    extend: {}
  },
  plugins: []
};
