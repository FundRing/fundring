import { sveltekit } from '@sveltejs/kit/vite'
import { resolve } from 'path'

/** @type {import('vite').UserConfig} */
const config = {
  build: {
    sourcemap: true
  },
  plugins: [sveltekit()],
  resolve: {
    alias: {
      $components: resolve('./src/components'),
      $contracts: resolve('./src/contracts'),
      $routes: resolve('./src/routes'),
      $src: resolve('./src'),
      $static: resolve('./static')
    }
  }
}

export default config
