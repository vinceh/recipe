<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
        <div class="modal-content">
          <button class="modal-close" @click="$emit('close')" :aria-label="$t('common.buttons.close')">
            <i class="pi pi-times"></i>
          </button>

          <div class="modal-body">
            <h1 class="modal-logo">Provisions</h1>

            <!-- Login Form -->
            <form v-if="mode === 'login'" @submit.prevent="handleLogin" class="auth-form">
              <ErrorMessage v-if="error" :message="error" />

              <div class="form-group">
                <label for="modal-email" class="form-label">{{ $t('forms.user.email') }}</label>
                <input
                  id="modal-email"
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
                <label for="modal-password" class="form-label">{{ $t('forms.user.password') }}</label>
                <input
                  id="modal-password"
                  v-model="password"
                  type="password"
                  class="form-input"
                  :placeholder="$t('forms.user.passwordPlaceholder')"
                  required
                  autocomplete="current-password"
                  :disabled="loading"
                />
              </div>

              <button type="button" class="forgot-link" @click="mode = 'forgot'">
                {{ $t('auth.forgotPassword') }}
              </button>

              <div class="auth-form__buttons">
                <button type="submit" class="btn-submit" :disabled="loading">
                  <LoadingSpinner v-if="loading" size="sm" />
                  <span v-else>{{ $t('auth.signIn') }}</span>
                </button>
                <button type="button" class="btn-secondary" @click="mode = 'signup'" :disabled="loading">
                  {{ $t('auth.signUp') }}
                </button>
              </div>
            </form>

            <!-- Signup Form -->
            <form v-else-if="mode === 'signup'" @submit.prevent="handleSignup" class="auth-form">
              <ErrorMessage v-if="error" :message="error" />

              <div class="form-group">
                <label for="signup-email" class="form-label">{{ $t('forms.user.email') }}</label>
                <input
                  id="signup-email"
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
                <label for="signup-password" class="form-label">{{ $t('forms.user.password') }}</label>
                <input
                  id="signup-password"
                  v-model="password"
                  type="password"
                  class="form-input"
                  :placeholder="$t('forms.user.passwordPlaceholder')"
                  required
                  autocomplete="new-password"
                  :disabled="loading"
                />
              </div>

              <div class="form-group">
                <label for="signup-password-confirm" class="form-label">{{ $t('forms.user.passwordConfirmation') }}</label>
                <input
                  id="signup-password-confirm"
                  v-model="passwordConfirm"
                  type="password"
                  class="form-input"
                  :placeholder="$t('forms.user.passwordConfirmPlaceholder')"
                  required
                  autocomplete="new-password"
                  :disabled="loading"
                />
              </div>

              <div class="auth-form__buttons">
                <button type="submit" class="btn-submit" :disabled="loading">
                  <LoadingSpinner v-if="loading" size="sm" />
                  <span v-else>{{ $t('auth.signUp') }}</span>
                </button>
                <button type="button" class="btn-secondary" @click="mode = 'login'" :disabled="loading">
                  {{ $t('auth.signIn') }}
                </button>
              </div>
            </form>

            <!-- Forgot Password Form -->
            <form v-else-if="mode === 'forgot'" @submit.prevent="handleForgotPassword" class="auth-form">
              <ErrorMessage v-if="error" :message="error" />

              <p class="form-description">{{ $t('auth.forgotPasswordDescription') }}</p>

              <div class="form-group">
                <label for="forgot-email" class="form-label">{{ $t('forms.user.email') }}</label>
                <input
                  id="forgot-email"
                  v-model="email"
                  type="email"
                  class="form-input"
                  :placeholder="$t('forms.user.emailPlaceholder')"
                  required
                  autocomplete="email"
                  :disabled="loading"
                />
              </div>

              <div class="auth-form__buttons">
                <button type="submit" class="btn-submit" :disabled="loading">
                  <LoadingSpinner v-if="loading" size="sm" />
                  <span v-else>{{ $t('auth.sendResetLink') }}</span>
                </button>
                <button type="button" class="btn-secondary" @click="mode = 'login'" :disabled="loading">
                  {{ $t('auth.backToSignIn') }}
                </button>
              </div>
            </form>

            <!-- Reset Sent Confirmation -->
            <div v-else-if="mode === 'resetSent'" class="auth-form">
              <p class="form-description form-description--success">{{ $t('auth.resetEmailSent') }}</p>

              <div class="auth-form__buttons">
                <button type="button" class="btn-submit" @click="mode = 'login'">
                  {{ $t('auth.backToSignIn') }}
                </button>
              </div>
            </div>

            <!-- Reset Password Form (when user clicks link from email) -->
            <form v-else-if="mode === 'reset'" @submit.prevent="handleResetPassword" class="auth-form">
              <ErrorMessage v-if="error" :message="error" />

              <p class="form-description">{{ $t('auth.enterNewPassword') }}</p>

              <div class="form-group">
                <label for="reset-password" class="form-label">{{ $t('forms.user.newPassword') }}</label>
                <input
                  id="reset-password"
                  v-model="password"
                  type="password"
                  class="form-input"
                  :placeholder="$t('forms.user.newPasswordPlaceholder')"
                  required
                  autocomplete="new-password"
                  :disabled="loading"
                />
              </div>

              <div class="form-group">
                <label for="reset-password-confirm" class="form-label">{{ $t('forms.user.passwordConfirmation') }}</label>
                <input
                  id="reset-password-confirm"
                  v-model="passwordConfirm"
                  type="password"
                  class="form-input"
                  :placeholder="$t('forms.user.passwordConfirmPlaceholder')"
                  required
                  autocomplete="new-password"
                  :disabled="loading"
                />
              </div>

              <div class="auth-form__buttons">
                <button type="submit" class="btn-submit" :disabled="loading">
                  <LoadingSpinner v-if="loading" size="sm" />
                  <span v-else>{{ $t('auth.savePassword') }}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuth } from '@/composables/useAuth'
import { authApi } from '@/services/authApi'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

type ModalMode = 'login' | 'signup' | 'forgot' | 'resetSent' | 'reset'

const props = defineProps<{
  show: boolean
  initialMode?: ModalMode
  resetToken?: string
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'success'): void
}>()

const { t } = useI18n()
const { login, signup } = useAuth()

const mode = ref<ModalMode>(props.initialMode || 'login')
const email = ref('')
const password = ref('')
const passwordConfirm = ref('')
const loading = ref(false)
const error = ref('')

function handleEscape(e: KeyboardEvent) {
  if (e.key === 'Escape' && props.show) {
    emit('close')
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
})

watch(() => props.show, (newVal) => {
  if (newVal) {
    email.value = ''
    password.value = ''
    passwordConfirm.value = ''
    error.value = ''
    mode.value = props.initialMode || 'login'
  }
})

watch(() => props.initialMode, (newMode) => {
  if (newMode) {
    mode.value = newMode
  }
})

async function handleLogin() {
  error.value = ''
  loading.value = true

  try {
    await login(email.value, password.value)
    emit('success')
    emit('close')
  } catch (e: any) {
    error.value = e.response?.data?.error || e.message || t('auth.loginError')
  } finally {
    loading.value = false
  }
}

async function handleSignup() {
  error.value = ''

  if (password.value !== passwordConfirm.value) {
    error.value = t('auth.passwordMismatch')
    return
  }

  loading.value = true

  try {
    await signup(email.value, password.value)
    emit('success')
    emit('close')
  } catch (e: any) {
    error.value = e.response?.data?.error || e.message || t('auth.signupError')
  } finally {
    loading.value = false
  }
}

async function handleForgotPassword() {
  error.value = ''
  loading.value = true

  try {
    await authApi.requestPasswordReset(email.value)
    mode.value = 'resetSent'
  } catch (e: any) {
    error.value = e.response?.data?.error || e.message || t('auth.resetError')
  } finally {
    loading.value = false
  }
}

async function handleResetPassword() {
  error.value = ''

  if (password.value !== passwordConfirm.value) {
    error.value = t('auth.passwordMismatch')
    return
  }

  if (!props.resetToken) {
    error.value = t('auth.invalidResetToken')
    return
  }

  loading.value = true

  try {
    await authApi.resetPassword(props.resetToken, password.value)
    mode.value = 'login'
    error.value = ''
    password.value = ''
    passwordConfirm.value = ''
  } catch (e: any) {
    error.value = e.response?.data?.error || e.message || t('auth.resetError')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: var(--spacing-lg);
  backdrop-filter: blur(2px);
}

.modal-content {
  background: var(--color-provisions-bg);
  border: 1px solid var(--color-provisions-border);
  padding: 28px;
  width: 100%;
  max-width: 410px;
  position: relative;
}

.modal-body {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  background: none;
  border: none;
  cursor: pointer;
  color: var(--color-provisions-border);
  font-size: 16px;
  padding: 4px;
  transition: color 0.15s;
}

.modal-close:hover {
  color: var(--color-provisions-text-dark);
}

.modal-logo {
  font-family: 'Cormorant Garamond', serif;
  font-size: 38px;
  font-weight: 700;
  color: var(--color-provisions-text-dark);
  letter-spacing: -0.5px;
  margin: 0 0 20px 0 !important;
  padding: 0;
  text-align: center;
  width: 100%;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
  width: 100%;
}

.form-description {
  font-family: var(--font-family-base);
  font-size: 14px;
  color: var(--color-provisions-text-muted);
  text-align: center;
  margin: 0;
  line-height: 1.5;
}

.form-description--success {
  color: var(--color-success);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-family: var(--font-family-heading);
  font-size: 14px;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
}

.form-input {
  width: 100%;
  padding: 12px 14px;
  font-family: var(--font-family-base);
  font-size: 15px;
  border: 1px solid var(--color-provisions-border);
  background: var(--color-provisions-bg);
  color: var(--color-provisions-text-dark);
  transition: border-color 0.15s;
}

.form-input:focus {
  outline: none;
  border-color: var(--color-provisions-text-dark);
}

.form-input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.form-input::placeholder {
  color: var(--color-provisions-text-muted);
}

.forgot-link {
  background: none;
  border: none;
  color: var(--color-provisions-text-muted);
  font-family: var(--font-family-base);
  font-size: 14px;
  cursor: pointer;
  padding: 0;
  margin-top: -12px;
  transition: color 0.15s;
  align-self: center;
}

.forgot-link:hover {
  color: var(--color-provisions-text-dark);
  text-decoration: underline;
}

.auth-form__buttons {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 4px;
}

.btn-submit {
  width: 100%;
  padding: 12px 16px;
  background: var(--color-error);
  color: white;
  border: none;
  font-family: var(--font-family-heading);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: background 0.15s;
}

.btn-submit:hover:not(:disabled) {
  background: #a84442;
}

.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  width: 100%;
  padding: 12px 16px;
  background: transparent;
  color: var(--color-provisions-text-dark);
  border: 1px solid var(--color-provisions-border);
  font-family: var(--font-family-heading);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s;
}

.btn-secondary:hover:not(:disabled) {
  border-color: var(--color-provisions-text-dark);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Modal transition */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}

.modal-enter-active .modal-content,
.modal-leave-active .modal-content {
  transition: transform 0.2s ease, opacity 0.2s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-content,
.modal-leave-to .modal-content {
  opacity: 0;
  transform: scale(0.95);
}

/* Mobile: full screen modal */
@media (max-width: 480px) {
  .modal-overlay {
    padding: 0;
    background: var(--color-provisions-bg);
  }

  .modal-content {
    width: 100%;
    height: 100%;
    max-width: none;
    border: none;
    padding: 24px;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .modal-body {
    width: 100%;
  }

  .modal-close {
    position: fixed;
    top: 16px;
    right: 16px;
    z-index: 10;
  }

  .modal-logo {
    font-size: 48px;
    margin-bottom: 40px !important;
  }

  .auth-form {
    width: 100%;
  }
}
</style>
