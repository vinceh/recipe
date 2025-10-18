import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue({
      // Vue plugin options
      script: {
        // Enable defineModel (Vue 3.4+)
        defineModel: true,
        // Enable propsDestructure (Vue 3.5+)
        propsDestructure: true
      }
    })
  ],

  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },

  // Development server configuration
  server: {
    port: 5173,
    strictPort: false,
    host: true, // Listen on all addresses
    open: true, // Open browser on start
    cors: true
  },

  // Build configuration
  build: {
    target: 'esnext',
    outDir: 'dist',
    assetsDir: 'assets',

    // Source maps for production (optional)
    sourcemap: false,

    // Minification
    minify: 'esbuild',

    // Chunk splitting strategy
    rollupOptions: {
      output: {
        manualChunks: {
          // Separate vendor chunks
          'vue-vendor': ['vue', 'vue-router'],
          // Add other vendor splits as needed
          // 'ui-vendor': ['primevue', 'primeicons']
        }
      }
    },

    // Performance warnings
    chunkSizeWarningLimit: 1000
  },

  // CSS configuration
  css: {
    devSourcemap: true,
    preprocessorOptions: {
      scss: {
        // SCSS global variables
        // additionalData: `@import "@/styles/variables.scss";`
      }
    }
  },

  // Optimization
  optimizeDeps: {
    include: ['vue', 'vue-router']
    // Add other dependencies that should be pre-bundled
  },

  // Environment variables prefix
  envPrefix: 'VITE_',

  // Preview server (for production build preview)
  preview: {
    port: 4173,
    strictPort: false,
    host: true,
    open: true
  }
})
