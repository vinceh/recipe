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
  width: 260px;
  flex-shrink: 0;
  transition: transform var(--transition-base);
}

.admin-sidebar__overlay {
  display: none;
}

.admin-sidebar__content {
  height: calc(100vh - 64px);
  background-color: var(--color-background);
  border-right: var(--border-width-thin) solid var(--color-border);
  overflow-y: auto;
  padding: var(--spacing-md) 0;
}

.admin-sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
  padding: 0 var(--spacing-md);
}

.admin-sidebar__link {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-sm) var(--spacing-md);
  color: var(--color-text);
  text-decoration: none;
  border-radius: var(--border-radius-md);
  transition: all var(--transition-fast);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  position: relative;
}

.admin-sidebar__link i {
  font-size: var(--font-size-lg);
  color: var(--color-text-secondary);
  transition: color var(--transition-fast);
  width: 20px;
  text-align: center;
}

.admin-sidebar__link span {
  flex: 1;
}

.admin-sidebar__link:hover {
  background-color: var(--color-background-secondary);
  color: var(--color-primary);
}

.admin-sidebar__link:hover i {
  color: var(--color-primary);
}

.admin-sidebar__link--active {
  background-color: var(--color-primary-pale);
  color: var(--color-primary-dark);
  font-weight: var(--font-weight-semibold);
}

.admin-sidebar__link--active i {
  color: var(--color-primary);
}

.admin-sidebar__divider {
  height: 1px;
  background-color: var(--color-border);
  margin: var(--spacing-lg) var(--spacing-md);
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .admin-sidebar {
    position: fixed;
    top: 64px;
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
    top: 64px;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: calc(var(--z-index-fixed) - 1);
  }

  .admin-sidebar__content {
    box-shadow: var(--shadow-xl);
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
