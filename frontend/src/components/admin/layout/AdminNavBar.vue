<template>
  <nav class="admin-navbar">
    <div class="admin-navbar__container">
      <!-- Left: Logo and Menu Toggle -->
      <div class="admin-navbar__left">
        <button
          class="admin-navbar__menu-toggle"
          @click="$emit('toggle-sidebar')"
          aria-label="Toggle sidebar"
        >
          <i class="pi pi-bars"></i>
        </button>

        <router-link to="/admin" class="admin-navbar__logo">
          <i class="pi pi-fire"></i>
          <span class="admin-navbar__brand">Ember</span>
          <span class="admin-navbar__badge">{{ $t('navigation.admin') }}</span>
        </router-link>
      </div>

      <!-- Right: Language Switcher and User Menu -->
      <div class="admin-navbar__right">
        <!-- Language Switcher -->
        <LanguageSwitcher />

        <!-- User Menu -->
        <div class="admin-navbar__user">
          <button
            class="admin-navbar__user-btn"
            @click="toggleUserMenu"
            aria-label="User menu"
          >
            <div class="admin-navbar__avatar">
              {{ userInitials }}
            </div>
            <span class="admin-navbar__user-name hide-mobile">{{ userName }}</span>
            <i class="pi pi-angle-down hide-mobile"></i>
          </button>

          <!-- User Dropdown Menu -->
          <div v-if="userMenuOpen" class="admin-navbar__dropdown">
            <div class="admin-navbar__dropdown-header">
              <div class="admin-navbar__user-info">
                <strong>{{ userName }}</strong>
                <small>{{ userEmail }}</small>
              </div>
            </div>
            <div class="admin-navbar__dropdown-divider"></div>
            <router-link to="/admin/profile" class="admin-navbar__dropdown-item">
              <i class="pi pi-user"></i>
              <span>{{ $t('navigation.profile') }}</span>
            </router-link>
            <router-link to="/admin/settings" class="admin-navbar__dropdown-item">
              <i class="pi pi-cog"></i>
              <span>{{ $t('navigation.settings') }}</span>
            </router-link>
            <div class="admin-navbar__dropdown-divider"></div>
            <button class="admin-navbar__dropdown-item" @click="handleLogout">
              <i class="pi pi-sign-out"></i>
              <span>{{ $t('navigation.logout') }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useUserStore } from '@/stores/userStore'
import LanguageSwitcher from '@/components/shared/LanguageSwitcher.vue'

const { t } = useI18n()

interface Emits {
  (e: 'toggle-sidebar'): void
}

defineEmits<Emits>()

const router = useRouter()
const userStore = useUserStore()

const userMenuOpen = ref(false)

const userName = computed(() => userStore.currentUser?.name || 'Admin User')
const userEmail = computed(() => userStore.currentUser?.email || 'admin@ember.app')
const userInitials = computed(() => {
  const name = userName.value
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
})

const toggleUserMenu = () => {
  userMenuOpen.value = !userMenuOpen.value
}

const handleLogout = async () => {
  await userStore.logout()
  router.push('/login')
}

// Close dropdowns when clicking outside
const closeDropdowns = () => {
  userMenuOpen.value = false
}

// Close dropdowns on window click
if (typeof window !== 'undefined') {
  window.addEventListener('click', (e) => {
    const target = e.target as HTMLElement
    if (!target.closest('.admin-navbar__user')) {
      closeDropdowns()
    }
  })
}
</script>

<style scoped>
.admin-navbar {
  background-color: var(--color-background);
  border-bottom: var(--border-width-thin) solid var(--color-border);
  height: 64px;
  position: sticky;
  top: 0;
  z-index: var(--z-index-sticky);
  box-shadow: var(--shadow-sm);
}

.admin-navbar__container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  padding: 0 var(--spacing-lg);
  max-width: 100%;
}

.admin-navbar__left {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
}

.admin-navbar__menu-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border: none;
  background: none;
  color: var(--color-text);
  cursor: pointer;
  border-radius: var(--border-radius-md);
  transition: background-color var(--transition-fast);
}

.admin-navbar__menu-toggle:hover {
  background-color: var(--color-background-secondary);
}

.admin-navbar__logo {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  text-decoration: none;
  color: var(--color-text);
  font-weight: var(--font-weight-semibold);
}

.admin-navbar__logo i {
  font-size: var(--font-size-xl);
  color: var(--color-primary);
}

.admin-navbar__brand {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-bold);
}

.admin-navbar__badge {
  padding: var(--spacing-xs) var(--spacing-sm);
  background-color: var(--color-primary-pale);
  color: var(--color-primary-dark);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  border-radius: var(--border-radius-full);
}

.admin-navbar__right {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.admin-navbar__icon-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border: none;
  background: none;
  color: var(--color-text);
  cursor: pointer;
  border-radius: var(--border-radius-md);
  transition: background-color var(--transition-fast);
}

.admin-navbar__icon-btn:hover {
  background-color: var(--color-background-secondary);
}

.admin-navbar__user {
  position: relative;
}

.admin-navbar__user-btn {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-xs) var(--spacing-sm);
  border: none;
  background: none;
  color: var(--color-text);
  cursor: pointer;
  border-radius: var(--border-radius-md);
  transition: background-color var(--transition-fast);
}

.admin-navbar__user-btn:hover {
  background-color: var(--color-background-secondary);
}

.admin-navbar__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background-color: var(--color-primary);
  color: var(--color-white);
  border-radius: var(--border-radius-full);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
}

.admin-navbar__user-name {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
}

.admin-navbar__dropdown {
  position: absolute;
  top: calc(100% + var(--spacing-sm));
  right: 0;
  min-width: 240px;
  background-color: var(--color-background);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-md);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  z-index: var(--z-index-dropdown);
}

.admin-navbar__dropdown-header {
  padding: var(--spacing-md);
}

.admin-navbar__user-info {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.admin-navbar__user-info strong {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.admin-navbar__user-info small {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}

.admin-navbar__dropdown-divider {
  height: 1px;
  background-color: var(--color-border);
  margin: var(--spacing-xs) 0;
}

.admin-navbar__dropdown-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  border: none;
  background: none;
  color: var(--color-text);
  text-decoration: none;
  text-align: left;
  cursor: pointer;
  transition: background-color var(--transition-fast);
  font-size: var(--font-size-sm);
}

.admin-navbar__dropdown-item:hover {
  background-color: var(--color-background-secondary);
}

.admin-navbar__dropdown-item i {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
}

/* Responsive */
@media (max-width: 768px) {
  .admin-navbar__container {
    padding: 0 var(--spacing-md);
  }

  .hide-mobile {
    display: none;
  }

  .admin-navbar__brand {
    font-size: var(--font-size-base);
  }
}
</style>
