<template>
  <aside :class="sidebarClasses">
    <!-- Mobile Overlay -->
    <div v-if="isOpen" class="admin-sidebar__overlay" @click="$emit('close')"></div>

    <!-- Sidebar Content -->
    <div class="admin-sidebar__content">
      <!-- Navigation Menu -->
      <nav class="admin-sidebar__nav">
        <router-link
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          class="admin-sidebar__link"
          exact-active-class="admin-sidebar__link--active"
        >
          <i :class="`pi pi-${item.icon}`"></i>
          <span>{{ $t(item.labelKey) }}</span>
          <Badge v-if="item.badge" :variant="item.badgeVariant" size="sm">
            {{ item.badge }}
          </Badge>
        </router-link>
      </nav>

      <!-- Divider -->
      <div class="admin-sidebar__divider"></div>

      <!-- Secondary Menu -->
      <nav class="admin-sidebar__nav">
        <router-link
          v-for="item in secondaryMenuItems"
          :key="item.path"
          :to="item.path"
          class="admin-sidebar__link"
          exact-active-class="admin-sidebar__link--active"
        >
          <i :class="`pi pi-${item.icon}`"></i>
          <span>{{ $t(item.labelKey) }}</span>
        </router-link>
      </nav>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Badge from '@/components/shared/Badge.vue'

interface Props {
  isOpen: boolean
}

interface Emits {
  (e: 'close'): void
}

const props = defineProps<Props>()
defineEmits<Emits>()

interface MenuItem {
  path: string
  labelKey: string
  icon: string
  badge?: string | number
  badgeVariant?: 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info'
}

const menuItems: MenuItem[] = [
  {
    path: '/admin',
    labelKey: 'navigation.dashboard',
    icon: 'chart-line'
  },
  {
    path: '/admin/recipes',
    labelKey: 'navigation.recipes',
    icon: 'book'
  },
  {
    path: '/admin/data-references',
    labelKey: 'navigation.dataReferences',
    icon: 'database'
  },
  {
    path: '/admin/prompts',
    labelKey: 'navigation.aiPrompts',
    icon: 'sparkles'
  },
  {
    path: '/admin/ingredients',
    labelKey: 'navigation.ingredients',
    icon: 'list'
  }
]

const secondaryMenuItems: MenuItem[] = [
  {
    path: '/admin/settings',
    labelKey: 'navigation.settings',
    icon: 'cog'
  }
]

const sidebarClasses = computed(() => ({
  'admin-sidebar': true,
  'admin-sidebar--open': props.isOpen
}))
</script>

<style scoped>
.admin-sidebar {
  position: relative;
  width: 240px;
  flex-shrink: 0;
  transition: transform var(--transition-base);
}

.admin-sidebar__overlay {
  display: none;
}

.admin-sidebar__content {
  height: calc(100vh - 60px);
  background-color: var(--color-provisions-bg);
  border-right: 1px solid var(--color-provisions-border);
  overflow-y: auto;
  padding: var(--spacing-md) 0;
}

.admin-sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: 0;
  padding: 0;
}

.admin-sidebar__link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  color: var(--color-provisions-text-dark);
  text-decoration: none;
  border-radius: 0;
  transition: all var(--transition-fast);
  font-family: var(--font-family-heading);
  font-size: 14px;
  font-weight: 500;
  position: relative;
  border-bottom: 1px solid transparent;
}

.admin-sidebar__link i {
  font-size: 16px;
  color: var(--color-provisions-text-muted);
  transition: color var(--transition-fast);
  width: 20px;
  text-align: center;
}

.admin-sidebar__link span {
  flex: 1;
}

.admin-sidebar__link:hover {
  background-color: rgba(0, 0, 0, 0.05);
  color: var(--color-provisions-border);
}

.admin-sidebar__link:hover i {
  color: var(--color-provisions-border);
}

.admin-sidebar__link--active {
  background-color: var(--color-provisions-border);
  color: var(--color-provisions-bg);
  font-weight: 600;
}

.admin-sidebar__link--active i {
  color: var(--color-provisions-bg);
}

.admin-sidebar__divider {
  height: 1px;
  background-color: var(--color-provisions-border);
  margin: var(--spacing-md) 0;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .admin-sidebar {
    position: fixed;
    top: 60px;
    left: 0;
    bottom: 0;
    z-index: var(--z-index-fixed);
    transform: translateX(-100%);
  }

  .admin-sidebar--open {
    transform: translateX(0);
  }

  .admin-sidebar__overlay {
    display: block;
    position: fixed;
    top: 60px;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: calc(var(--z-index-fixed) - 1);
  }

  .admin-sidebar__content {
    box-shadow: 4px 0 12px rgba(0, 0, 0, 0.1);
  }
}

/* Hide sidebar when closed on desktop */
@media (min-width: 769px) {
  .admin-sidebar:not(.admin-sidebar--open) {
    width: 0;
    overflow: hidden;
  }

  .admin-sidebar:not(.admin-sidebar--open) .admin-sidebar__content {
    display: none;
  }
}

/* Scrollbar styling */
.admin-sidebar__content::-webkit-scrollbar {
  width: 6px;
}

.admin-sidebar__content::-webkit-scrollbar-track {
  background-color: transparent;
}

.admin-sidebar__content::-webkit-scrollbar-thumb {
  background-color: var(--color-border-dark);
  border-radius: var(--border-radius-full);
}

.admin-sidebar__content::-webkit-scrollbar-thumb:hover {
  background-color: var(--color-gray-500);
}
</style>
