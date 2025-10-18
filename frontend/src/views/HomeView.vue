<template>
  <div class="home">
    <div class="language-switcher-container">
      <LanguageSwitcher />
    </div>
    <div class="hero">
      <div class="hero__content">
        <div class="hero__icon">
          <i class="pi pi-fire"></i>
        </div>
        <h1 class="hero__title">{{ $t('common.messages.welcome') }}</h1>
        <p class="hero__subtitle">{{ $t('common.messages.subtitle') }}</p>
        <div class="hero__actions">
          <router-link to="/admin" class="btn btn-primary btn-lg">
            {{ $t('navigation.admin') }} {{ $t('navigation.dashboard') }}
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import LanguageSwitcher from '@/components/shared/LanguageSwitcher.vue'
</script>

<style scoped>
.home {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-primary-pale) 0%, var(--color-background-secondary) 100%);
  position: relative;
}

.language-switcher-container {
  position: absolute;
  top: var(--spacing-lg);
  right: var(--spacing-lg);
}

.hero {
  text-align: center;
  padding: var(--spacing-2xl);
}

.hero__content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-xl);
}

.hero__icon {
  font-size: 80px;
  color: var(--color-primary);
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.hero__title {
  font-size: var(--font-size-5xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0;
}

.hero__subtitle {
  font-size: var(--font-size-xl);
  color: var(--color-text-secondary);
  margin: 0;
}

.hero__actions {
  margin-top: var(--spacing-lg);
}

@media (max-width: 768px) {
  .hero__icon {
    font-size: 60px;
  }

  .hero__title {
    font-size: var(--font-size-3xl);
  }

  .hero__subtitle {
    font-size: var(--font-size-lg);
  }
}
</style>
