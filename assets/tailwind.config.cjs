// const colors = require('tailwindcss/colors');
const { fontFamily } = require('tailwindcss/defaultTheme');

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class'],
  content: [
    './src/**/*.{html,js,svelte,ts}',
    '../lib/subledger_web/{components,controllers}/**/*.{heex,ex}'
  ],
  theme: {
    extend: {
      colors: {
        secondary: 'oklch(40% 0.23 283)',
        error: 'oklch(54% 0.22 29)',
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        transparent: 'transparent',
        current: 'currentColor',
        highlight: 'hsl(var(--table-hover))',
        primary: {
          DEFAULT: 'oklch(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
          hover: 'hsl(var(--primary-hover))',
          focus: 'hsl(var(--primary-focus))',
          active: 'hsl(var(--primary-active))'
        },
        secondary: {
          DEFAULT: 'oklch(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
          hover: 'hsl(var(--secondary-hover))',
          focus: 'hsl(var(--secondary-focus))',
          active: 'hsl(var(--secondary-active))'
        },
        error: {
          DEFAULT: 'oklch(var(--error))',
          foreground: 'oklch(var(--error-foreground))'
        },
        warning: {
          DEFAULT: 'hsl(var(--warning))',
          foreground: 'hsl(var(--warning-foreground))'
        },
        info: {
          DEFAULT: 'hsl(var(--info))',
          foreground: 'hsl(var(--info-foreground))'
        },
        success: {
          DEFAULT: 'hsl(var(--success))',
          foreground: 'hsl(var(--success-foreground))'
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))'
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))'
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))'
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))'
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))'
        }
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)'
      },
      fontFamily: {
        sans: ['Inter', 'Roboto', 'Droid Sans', ...fontFamily.sans]
      }
    }
  },
  plugins: []
};
