<template>
  <div class="signup-view">
    <div class="signup-container">
      <div class="signup-card">
        <!-- Logo and Branding -->
        <div class="signup-header">
          <div class="signup-icon">
            <i class="pi pi-fire"></i>
          </div>
          <h1 class="signup-title">Ember</h1>
          <p class="signup-subtitle">{{ $t('auth.signUpSubtitle') }}</p>
        </div>

        <!-- Signup Form -->
        <form @submit.prevent="handleSignup" class="signup-form">
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
              autocomplete="new-password"
              :disabled="loading"
              minlength="6"
            />
          </div>

          <div class="form-group">
            <label for="passwordConfirmation" class="form-label">{{ $t('forms.user.passwordConfirmation') }}</label>
            <input
              id="passwordConfirmation"
              v-model="passwordConfirmation"
              type="password"
              class="form-input"
              placeholder="Confirm your password"
              required
              autocomplete="new-password"
              :disabled="loading"
              minlength="6"
            />
          </div>

          <button
            type="submit"
            class="btn btn-primary btn-block"
            :disabled="loading || !isFormValid"
          >
            <LoadingSpinner v-if="loading" size="sm" />
            <span v-else>{{ $t('auth.signUp') }}</span>
          </button>
        </form>

        <!-- Footer Links -->
        <div class="signup-footer">
          <p class="signup-link-text">
            {{ $t('auth.alreadyHaveAccount') }}
            <router-link to="/login" class="signup-link">
              {{ $t('auth.signIn') }}
            </router-link>
          </p>
          <router-link to="/" class="back-link">
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
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useUserStore } from '@/stores/userStore'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const { t } = useI18n()
const router = useRouter()
const userStore = useUserStore()

const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const loading = ref(false)
const error = ref('')

const isFormValid = computed(() => {
  return email.value &&
         password.value.length >= 6 &&
         password.value === passwordConfirmation.value
})

const handleSignup = async () => {
  error.value = ''

  // Validate passwords match
  if (password.value !== passwordConfirmation.value) {
    error.value = t('errors.validation.passwordsDontMatch')
    return
  }

  // Validate password length
  if (password.value.length < 6) {
    error.value = t('errors.validation.passwordTooShort')
    return
  }

  loading.value = true

  try {
    await userStore.signup({
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value
    })

    // Redirect to home after successful signup
    router.push({ name: 'home' })
  } catch (e: any) {
    error.value = e.response?.data?.errors?.[0] ||
                  e.response?.data?.message ||
                  e.message ||
                  t('auth.signupError')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.signup-view {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-primary-pale) 0%, var(--color-background-secondary) 100%);
  padding: var(--spacing-lg);
}

.signup-container {
  width: 100%;
  max-width: 440px;
}

.signup-card {
  background: var(--color-background);
  border-radius: var(--border-radius-xl);
  box-shadow: var(--shadow-xl);
  padding: var(--spacing-2xl);
}

.signup-header {
  text-align: center;
  margin-bottom: var(--spacing-2xl);
}

.signup-icon {
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

.signup-title {
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0 0 var(--spacing-xs) 0;
}

.signup-subtitle {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  margin: 0;
}

.signup-form {
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

.signup-footer {
  margin-top: var(--spacing-xl);
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.signup-link-text {
  color: var(--color-text-secondary);
  font-size: var(--font-size-sm);
  margin: 0;
}

.signup-link {
  color: var(--color-primary);
  text-decoration: none;
  font-weight: var(--font-weight-medium);
  transition: color var(--transition-fast);
}

.signup-link:hover {
  color: var(--color-primary-dark);
  text-decoration: underline;
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-text-secondary);
  text-decoration: none;
  font-size: var(--font-size-sm);
  transition: color var(--transition-fast);
}

.back-link:hover {
  color: var(--color-primary);
}

/* Responsive */
@media (max-width: 768px) {
  .signup-view {
    padding: var(--spacing-md);
  }

  .signup-card {
    padding: var(--spacing-xl);
  }

  .signup-icon {
    font-size: 48px;
  }

  .signup-title {
    font-size: var(--font-size-2xl);
  }
}
</style>
