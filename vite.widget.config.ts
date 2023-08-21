import { defineConfig } from 'vite'
import { resolve } from 'path'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import sveltePreprocess from 'svelte-preprocess'

/** @type {import('vite').UserConfig} */
export default defineConfig({
  build: {
    sourcemap: true,
    target: 'modules',
    chunkSizeWarningLimit: 5000,
    rollupOptions: {
      input: resolve(
        __dirname,
        './src/components/web-components/fund-ring-widget.ts'
      ),
      output: {
        format: 'iife',
        dir: resolve(__dirname, './widget'),
        entryFileNames: 'fund-ring-widget.js'
      }
    }
  },
  optimizeDeps: {
    exclude: ['uint8arrays', 'clipboard-copy', 'web3.storage']
  },
  plugins: [
    svelte({
      preprocess: sveltePreprocess(),
      exclude: '/.component.svelte$/',
      emitCss: false,
    }),
    svelte({
      preprocess: sveltePreprocess(),
      include: '/.component.svelte$/',
      compilerOptions: {
        customElement: true
      },
      emitCss: false
    })
  ],
  resolve: {
    alias: {
      $components: resolve('./src/components'),
      $contracts: resolve('./src/contracts'),
      $lib: resolve('./src/lib'),
      $routes: resolve('./src/routes'),
      $src: resolve('./src'),
      $static: resolve('./static')
    }
  }
})
