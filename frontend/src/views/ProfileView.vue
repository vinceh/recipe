<template>
  <PageLayout class="profile">
    <template #navbar>
      <MainNavBar :page-title="$t('navigation.profile')" />
    </template>

    <div class="profile-content">
      <div class="profile-header">
        <div class="profile-avatar">
          <i class="pi pi-user"></i>
        </div>
        <h2 class="profile-email">{{ currentUser?.email }}</h2>
      </div>

      <div class="profile-section">
        <h3 class="profile-section__title">{{ $t('profile.accountInfo') }}</h3>
        <div class="profile-field">
          <span class="profile-field__label">{{ $t('common.labels.email') }}</span>
          <span class="profile-field__value">{{ currentUser?.email }}</span>
        </div>
      </div>

      <div class="profile-section profile-section--coming-soon">
        <p class="coming-soon-text">{{ $t('profile.comingSoon') }}</p>
      </div>
    </div>
  </PageLayout>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores'
import PageLayout from '@/components/layout/PageLayout.vue'
import MainNavBar from '@/components/shared/MainNavBar.vue'

const userStore = useUserStore()
const { currentUser } = storeToRefs(userStore)
</script>

<style scoped>
/* Profile Content */
.profile-content {
  padding: 40px;
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40px;
}

.profile-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: var(--color-provisions-border);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.profile-avatar i {
  font-size: 36px;
  color: var(--color-provisions-bg);
}

.profile-email {
  font-family: var(--font-family-heading);
  font-size: 20px;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
  margin: 0;
}

.profile-section {
  margin-bottom: 32px;
}

.profile-section__title {
  font-family: var(--font-family-heading);
  font-size: 14px;
  font-weight: 600;
  color: var(--color-provisions-border);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin: 0 0 16px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--color-provisions-border);
}

.profile-field {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
}

.profile-field__label {
  font-size: 14px;
  color: var(--color-provisions-text-muted);
}

.profile-field__value {
  font-size: 14px;
  color: var(--color-provisions-text-dark);
  font-weight: 500;
}

.profile-section--coming-soon {
  text-align: center;
  padding: 40px 20px;
  background: rgba(0, 0, 0, 0.02);
  border-radius: 8px;
}

.coming-soon-text {
  font-family: var(--font-family-heading);
  font-size: 16px;
  color: var(--color-provisions-text-muted);
  margin: 0;
  font-style: italic;
}

</style>
