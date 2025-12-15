<template>
  <div class="admin-layout">
    <AdminNavBar @toggle-sidebar="toggleSidebar" />

    <div class="admin-layout__container">
      <AdminSidebar :is-open="sidebarOpen" @close="closeSidebar" />

      <main class="admin-layout__main">
        <div class="admin-layout__content">
          <router-view />
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import AdminNavBar from './AdminNavBar.vue'
import AdminSidebar from './AdminSidebar.vue'

const sidebarOpen = ref(true)

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const closeSidebar = () => {
  sidebarOpen.value = false
}
</script>

<style scoped>
.admin-layout {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: var(--color-provisions-bg);
}

.admin-layout__container {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.admin-layout__main {
  flex: 1;
  overflow-y: auto;
  min-width: 0;
}

.admin-layout__content {
  padding: var(--spacing-xl);
  margin: 0 auto;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .admin-layout__content {
    padding: var(--spacing-md);
  }
}
</style>
