<template>
  <div class="login-view">
    <div class="login-container">
      <div class="login-card">
        <!-- Logo and Branding -->
        <div class="login-header">
          <div class="login-icon">
            <i class="pi pi-fire"></i>
          </div>
          <h1 class="login-title">Ember</h1>
          <p class="login-subtitle">{{ $t('auth.signInSubtitle') }}</p>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="login-form">
          <ErrorMessage v-if="error" :message="error" />

          <div class="form-group">
            <label for="email" class="form-label">{{ $t('forms.user.email') }}</label>
            <input
              id="email"
              v-model="email"
              type="email"
              class="form-input"
              :placeholder="$t('forms.user.emailPlaceholder')"
              required
              autocomplete="email"
              :disabled="loading"
            />
          </div>

          <div class="form-group">
            <label for="password" class="form-label">{{ $t('forms.user.password') }}</label>
            <input
              id="password"
              v-model="password"
              type="password"
              class="form-input"
              :placeholder="$t('forms.user.passwordPlaceholder')"
              required
              autocomplete="current-password"
              :disabled="loading"
            />
          </div>

          <button
            type="submit"
            class="btn btn-primary btn-block"
            :disabled="loading"
          >
            <LoadingSpinner v-if="loading" size="sm" />
            <span v-else>{{ $t('auth.signIn') }}</span>
          </button>
        </form>

        <!-- Footer Links -->
        <div class="login-footer">
          <router-link to="/" class="login-link">
            <i class="pi pi-arrow-left"></i>
            {{ $t('auth.backToHome') }}
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuth } from '@/composables/useAuth'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const { t } = useI18n()

const router = useRouter()
const route = useRoute()
const { login, isAdmin } = useAuth()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  error.value = ''
  loading.value = true

  try {
    await login(email.value, password.value)

    // Redirect to intended page or admin dashboard if admin, otherwise home
    const redirect = route.query.redirect as string
    if (redirect) {
      router.push(redirect)
    } else if (isAdmin.value) {
      router.push('/admin')
    } else {
      router.push('/')
    }
  } catch (e: any) {
    error.value = e.response?.data?.error || e.message || t('auth.loginError')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-view {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-primary-pale) 0%, var(--color-background-secondary) 100%);
  padding: var(--spacing-lg);
}

.login-container {
  width: 100%;
  max-width: 440px;
}

.login-card {
  background: var(--color-background);
  border-radius: var(--border-radius-xl);
  box-shadow: var(--shadow-xl);
  padding: var(--spacing-2xl);
}

.login-header {
  text-align: center;
  margin-bottom: var(--spacing-2xl);
}

.login-icon {
  font-size: 64px;
  color: var(--color-primary);
  margin-bottom: var(--spacing-md);
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.login-title {
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0 0 var(--spacing-xs) 0;
}

.login-subtitle {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.form-label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
}

.form-input {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  font-size: var(--font-size-base);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-md);
  background: var(--color-background);
  color: var(--color-text);
  transition: border-color var(--transition-fast);
}

.form-input:focus {
  outline: none;
  border-color: var(--color-primary);
}

.form-input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-block {
  width: 100%;
  justify-content: center;
}

.login-footer {
  margin-top: var(--spacing-xl);
  text-align: center;
}

.login-link {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-text-secondary);
  text-decoration: none;
  font-size: var(--font-size-sm);
  transition: color var(--transition-fast);
}

.login-link:hover {
  color: var(--color-primary);
}

/* Responsive */
@media (max-width: 768px) {
  .login-view {
    padding: var(--spacing-md);
  }

  .login-card {
    padding: var(--spacing-xl);
  }

  .login-icon {
    font-size: 48px;
  }

  .login-title {
    font-size: var(--font-size-2xl);
  }
}
</style>
