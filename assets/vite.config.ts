import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

// https://vitejs.dev/config/
export default defineConfig(({ command }) => {
  const isDev = command !== 'build';
  if (isDev) {
    // Terminate the watcher when phx quits
    process.stdin.on('close', () => {
      process.exit(0);
    });
    process.stdin.resume();
  }

  return {
    plugins: [svelte()],
    build: {
      target: 'esnext',
      minify: 'esbuild', // false
      outDir: '../priv/static/assets',
      emptyOutDir: true,
      assetsInlineLimit: 0,
      manifest: false,
      rollupOptions: {
        input: ['src/main.ts', 'src/app.js'],
        output: {
          entryFileNames: '[name].js',
          chunkFileNames: '[name].js',
          assetFileNames: '[name][extname]'
        }
      }
    }
  };
});
