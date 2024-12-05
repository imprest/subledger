import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import tailwindcss from '@tailwindcss/vite';

// https://vite.dev/config/
// export default defineConfig({
// 	plugins: [tailwindcss(), svelte()]
// });

// https://vite.dev/config/
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
		base: isDev ? undefined : '/assets/',
		plugins: [tailwindcss(), svelte()],
		publicDir: false,
		build: {
			target: 'esnext',
			minify: 'esbuild',
			outDir: '../priv/static/assets',
			emptyOutDir: true,
			manifest: false,
			rollupOptions: {
				input: ['src/app.js', 'src/main.ts'],
				output: {
					entryFileNames: '[name].js',
					chunkFileNames: '[name].js',
					assetFileNames: '[name][extname]'
				}
			}
		}
	};
});
