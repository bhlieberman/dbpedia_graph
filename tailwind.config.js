/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["_build/default/app/lib/*.js", "_build/default/app/app.js"],
  theme: {
    extend: {},
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["light", "dark", "cupcake", "cyberpunk"],
  },
}

