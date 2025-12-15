<template>
  <div class="admin-login-view">
    <div class="login-container">
      <div class="login-card">
        <!-- Logo and Branding -->
        <div class="login-header">
          <h1 class="login-brand">Provisions</h1>
          <div class="admin-badge">{{ $t('navigation.admin') }}</div>
          <p class="login-subtitle">{{ $t('auth.adminSignInSubtitle') }}</p>
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
              :class="{ 'is-invalid': emailError }"
              :placeholder="$t('forms.user.emailPlaceholder')"
              required
              autocomplete="email"
              :disabled="loading"
              @blur="validateEmail"
              data-testid="admin-email-input"
            />
            <span v-if="emailError" class="form-error">{{ emailError }}</span>
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
              data-testid="admin-password-input"
            />
          </div>

          <button
            type="submit"
            class="btn btn-primary btn-block"
            :disabled="loading || !isFormValid"
            data-testid="admin-login-button"
          >
            <LoadingSpinner v-if="loading" size="sm" />
            <span v-else>{{ $t('auth.signIn') }}</span>
          </button>
        </form>

        <!-- Footer Links -->
        <div class="login-footer">
          <router-link to="/" class="login-link" data-testid="back-to-home-link">
            <i class="pi pi-arrow-left"></i>
            {{ $t('auth.backToHome') }}
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
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
const emailError = ref('')
const loading = ref(false)
const error = ref('')

const isFormValid = computed(() => {
  return email.value.trim() !== '' && password.value.trim() !== '' && !emailError.value
})

const validateEmail = () => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (email.value && !emailRegex.test(email.value)) {
    emailError.value = t('forms.validation.invalidEmail')
  } else {
    emailError.value = ''
  }
}

const handleLogin = async () => {
  error.value = ''
  loading.value = true

  try {
    await login(email.value, password.value)

    // Check if user is admin
    if (!isAdmin.value) {
      error.value = t('auth.adminAccessRequired')
      loading.value = false
      return
    }

    // Redirect to intended page or admin dashboard if admin, otherwise home
    const redirect = route.query.redirect as string
    if (redirect) {
      router.push(redirect)
    } else {
      router.push({ name: 'admin-dashboard' })
    }
  } catch (e: any) {
    error.value = e.response?.data?.error || e.message || t('auth.loginError')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.admin-login-view {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-provisions-bg);
  padding: var(--spacing-lg);
}

.login-container {
  width: 100%;
  max-width: 400px;
}

.login-card {
  background: var(--color-provisions-bg);
  border: 1px solid var(--color-provisions-border);
  padding: var(--spacing-2xl);
}

.login-header {
  text-align: center;
  margin-bottom: var(--spacing-2xl);
}

.login-brand {
  font-family: 'Cormorant Garamond', serif;
  font-size: 32px;
  font-weight: 700;
  color: var(--color-provisions-border);
  letter-spacing: -0.5px;
  margin: 0 0 var(--spacing-sm) 0;
}

.login-subtitle {
  font-family: var(--font-family-heading);
  font-size: 14px;
  color: var(--color-provisions-text-muted);
  margin: var(--spacing-md) 0 0 0;
}

.admin-badge {
  display: inline-block;
  background: var(--color-provisions-border);
  color: var(--color-provisions-bg);
  padding: 4px 12px;
  font-family: var(--font-family-heading);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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
  font-family: var(--font-family-heading);
  font-size: 12px;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-input {
  width: 100%;
  padding: 12px 14px;
  font-family: var(--font-family-heading);
  font-size: 14px;
  border: 1px solid var(--color-provisions-border);
  background: var(--color-provisions-bg);
  color: var(--color-provisions-text-dark);
  transition: border-color var(--transition-fast);
}

.form-input:focus {
  outline: none;
  border-color: var(--color-provisions-text-dark);
}

.form-input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.form-input.is-invalid {
  border-color: var(--color-error);
}

.form-error {
  font-family: var(--font-family-heading);
  font-size: 12px;
  color: var(--color-error);
  margin-top: var(--spacing-xs);
}

.btn-block {
  width: 100%;
  justify-content: center;
  background-color: var(--color-provisions-border);
  color: var(--color-provisions-bg);
  border: none;
  padding: 12px 20px;
  font-family: var(--font-family-heading);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: opacity var(--transition-fast);
}

.btn-block:hover:not(:disabled) {
  opacity: 0.9;
}

.btn-block:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.login-footer {
  margin-top: var(--spacing-xl);
  text-align: center;
}

.login-link {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-provisions-text-muted);
  text-decoration: none;
  font-family: var(--font-family-heading);
  font-size: 14px;
  transition: color var(--transition-fast);
}

.login-link:hover {
  color: var(--color-provisions-border);
}

/* Responsive */
@media (max-width: 768px) {
  .admin-login-view {
    padding: var(--spacing-md);
  }

  .login-card {
    padding: var(--spacing-xl);
  }

  .login-brand {
    font-size: 28px;
  }
}
</style>
