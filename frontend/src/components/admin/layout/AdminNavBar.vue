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
          <span class="admin-navbar__brand">Provisions</span>
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
import { ref, computed, onMounted, onUnmounted } from 'vue'
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
const userEmail = computed(() => userStore.currentUser?.email || '')
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
  router.push({ name: 'login' })
}

// Close dropdowns when clicking outside
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.admin-navbar__user')) {
    userMenuOpen.value = false
  }
}

onMounted(() => {
  window.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  window.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.admin-navbar {
  background-color: var(--color-provisions-bg);
  border-bottom: 1px solid var(--color-provisions-border);
  height: 60px;
  position: sticky;
  top: 0;
  z-index: var(--z-index-sticky);
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
  color: var(--color-provisions-border);
  cursor: pointer;
  border-radius: 0;
  transition: background-color var(--transition-fast);
}

.admin-navbar__menu-toggle:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.admin-navbar__logo {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  text-decoration: none;
  color: var(--color-provisions-border);
}

.admin-navbar__brand {
  font-family: 'Cormorant Garamond', serif;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.admin-navbar__badge {
  padding: 4px 10px;
  background-color: var(--color-provisions-border);
  color: var(--color-provisions-bg);
  font-family: var(--font-family-heading);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.admin-navbar__right {
  display: flex;
  align-items: center;
  gap: var(--spacing-lg);
}

.admin-navbar__user {
  position: relative;
}

.admin-navbar__user-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 0;
  border: none;
  background: none;
  color: var(--color-provisions-border);
  cursor: pointer;
  font-family: var(--font-family-heading);
  font-weight: 600;
  font-size: 16px;
}

.admin-navbar__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  background-color: var(--color-provisions-border);
  color: var(--color-provisions-bg);
  border-radius: 50%;
  font-size: 12px;
  font-weight: 600;
}

.admin-navbar__user-name {
  font-size: 16px;
  font-weight: 600;
}

.admin-navbar__dropdown {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  min-width: 200px;
  background-color: var(--color-provisions-bg);
  border: 1px solid var(--color-provisions-border);
  z-index: var(--z-index-dropdown);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.admin-navbar__dropdown-header {
  padding: 12px 16px;
  border-bottom: 1px solid var(--color-provisions-border);
}

.admin-navbar__user-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.admin-navbar__user-info strong {
  font-family: var(--font-family-heading);
  font-size: 14px;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
}

.admin-navbar__user-info small {
  font-size: 12px;
  color: var(--color-provisions-text-muted);
}

.admin-navbar__dropdown-divider {
  height: 1px;
  background-color: var(--color-provisions-border);
  margin: 0;
}

.admin-navbar__dropdown-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  width: 100%;
  padding: 12px 16px;
  border: none;
  background: none;
  color: var(--color-provisions-text-dark);
  text-decoration: none;
  text-align: left;
  cursor: pointer;
  font-family: var(--font-family-heading);
  font-size: 14px;
}

.admin-navbar__dropdown-item:hover {
  background-color: var(--color-provisions-border);
  color: var(--color-provisions-bg);
}

.admin-navbar__dropdown-item i {
  font-size: 14px;
  color: inherit;
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
    font-size: 18px;
  }

  .admin-navbar__badge {
    font-size: 10px;
    padding: 3px 8px;
  }
}
</style>
