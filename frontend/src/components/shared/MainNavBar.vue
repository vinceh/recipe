<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores'
import LanguageSwitcher from '@/components/shared/LanguageSwitcher.vue'
import LoginModal from '@/components/shared/LoginModal.vue'

const props = withDefaults(defineProps<{
  showSearch?: boolean
  pageTitle?: string
  searchPlaceholder?: string
}>(), {
  showSearch: false,
  pageTitle: '',
  searchPlaceholder: ''
})

const emit = defineEmits<{
  search: [query: string]
}>()

const router = useRouter()
const userStore = useUserStore()
const { isAuthenticated, isAdmin } = storeToRefs(userStore)

const searchQuery = ref('')
const showUserMenu = ref(false)
const showLoginModal = ref(false)
const userMenuRef = ref<HTMLElement | null>(null)

function handleSearch() {
  emit('search', searchQuery.value)
}

function goToSearch() {
  if (searchQuery.value.trim()) {
    router.push({ name: 'home', query: { q: searchQuery.value } })
  }
}

function toggleUserMenu() {
  showUserMenu.value = !showUserMenu.value
}

function handleClickOutside(event: MouseEvent) {
  if (userMenuRef.value && !userMenuRef.value.contains(event.target as Node)) {
    showUserMenu.value = false
  }
}

async function handleLogout() {
  showUserMenu.value = false
  await userStore.logout()
  router.push('/')
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

defineExpose({ searchQuery })
</script>

<template>
  <nav class="navbar navbar--top">
    <div class="navbar-left">
      <router-link to="/" class="navbar__title">Provisions</router-link>
    </div>

    <div class="navbar-center">
      <input
        v-if="showSearch"
        v-model="searchQuery"
        type="text"
        class="navbar__search"
        :placeholder="searchPlaceholder || $t('home.searchPlaceholder')"
        @input="handleSearch"
        @keyup.enter="goToSearch"
      />
      <h1 v-else-if="pageTitle" class="page-title">{{ pageTitle }}</h1>
    </div>

    <div class="navbar-right">
      <LanguageSwitcher />

      <template v-if="isAuthenticated">
        <div ref="userMenuRef" class="user-menu">
          <button class="user-menu__trigger" @click="toggleUserMenu">
            {{ $t('navigation.menu') }}
            <svg class="user-menu__chevron" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12"><path fill="currentColor" d="M6 9L1 4h10z"/></svg>
          </button>
          <div v-if="showUserMenu" class="user-menu__dropdown">
            <router-link
              v-if="isAdmin"
              to="/admin"
              class="user-menu__item"
              @click="showUserMenu = false"
            >
              {{ $t('navigation.admin') }}
            </router-link>
            <router-link to="/profile" class="user-menu__item" @click="showUserMenu = false">
              {{ $t('navigation.profile') }}
            </router-link>
            <router-link to="/favorites" class="user-menu__item" @click="showUserMenu = false">
              {{ $t('navigation.favorites') }}
            </router-link>
            <button class="user-menu__item" @click="handleLogout">
              {{ $t('navigation.logout') }}
            </button>
          </div>
        </div>
      </template>

      <button v-else class="navbar__link navbar__link--button" @click="showLoginModal = true">
        {{ $t('navigation.login') }}
      </button>
    </div>
  </nav>

  <LoginModal :show="showLoginModal" @close="showLoginModal = false" />
</template>

<style scoped>
.navbar--top {
  height: 60px;
  background: var(--color-provisions-bg);
  border-bottom: 1px solid var(--color-provisions-border);
  display: flex;
  align-items: center;
  gap: 0;
  position: sticky;
  top: 0;
  z-index: 20;
  flex-shrink: 0;
}

.navbar-left {
  flex: 1;
  padding: 0 var(--spacing-lg);
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.navbar-center {
  flex: 0 0 600px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-right: 1px solid var(--color-provisions-border);
  border-left: 1px solid var(--color-provisions-border);
  height: 100%;
}

.navbar-right {
  flex: 1;
  padding: 0 var(--spacing-lg);
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: var(--spacing-lg);
}

.navbar__title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 22px;
  font-weight: 700;
  margin: 0;
  color: var(--color-provisions-border);
  letter-spacing: -0.5px;
  text-decoration: none;
}

.navbar__link {
  font-family: var(--font-family-heading);
  font-weight: 600;
  color: var(--color-provisions-border);
  text-decoration: none;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  padding: 0;
}

.navbar__link--button {
  background: none;
  border: none;
}

.navbar__search {
  width: 100%;
  height: 100%;
  padding: 0 25px;
  border: none;
  background: transparent;
  font-family: var(--font-family-heading);
  font-size: 16px;
  color: var(--color-provisions-text-dark);
}

.navbar__search::placeholder {
  color: var(--color-provisions-text-muted);
}

.navbar__search:focus {
  outline: none;
}

.page-title {
  font-family: var(--font-family-heading);
  font-size: 20px;
  font-weight: 600;
  color: var(--color-provisions-border);
  margin: 0;
}

.user-menu {
  position: relative;
}

.user-menu__trigger {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 0;
  background: none;
  border: none;
  color: var(--color-provisions-border);
  font-family: var(--font-family-heading);
  font-weight: 600;
  font-size: 16px;
  cursor: pointer;
}

.user-menu__dropdown {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  background: var(--color-provisions-bg);
  border: 1px solid var(--color-provisions-border);
  min-width: 160px;
  z-index: 100;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.user-menu__item {
  display: block;
  width: 100%;
  padding: 12px 16px;
  background: none;
  border: none;
  color: var(--color-provisions-text-dark);
  font-family: var(--font-family-heading);
  font-size: 14px;
  text-decoration: none;
  cursor: pointer;
  text-align: left;
}

.user-menu__item:hover {
  background: var(--color-provisions-border);
  color: var(--color-provisions-bg);
}

@media (max-width: 1000px) {
  .navbar--top {
    flex-wrap: wrap;
    height: auto;
  }

  .navbar-left {
    order: 1;
    flex: 0 0 auto;
    justify-content: flex-start;
    height: 60px;
  }

  .navbar-right {
    order: 2;
    flex: 1;
    justify-content: flex-end;
    height: 60px;
  }

  .navbar-center {
    order: 3;
    flex: 0 0 100%;
    border-left: none;
    border-right: none;
    border-top: 1px solid var(--color-provisions-border);
    height: 50px;
  }
}
</style>
