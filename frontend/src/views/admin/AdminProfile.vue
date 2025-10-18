<template>
  <div class="admin-profile">
    <PageHeader
      title="Profile"
      subtitle="Manage your account information"
    />

    <div class="profile-sections">
      <div class="profile-card">
        <div class="profile-avatar">
          <div class="profile-avatar__circle">
            {{ userInitials }}
          </div>
          <button class="btn btn-outline btn-sm">Change Photo</button>
        </div>

        <div class="profile-info">
          <h3 class="profile-info__title">Personal Information</h3>
          <div class="profile-field">
            <label>Name</label>
            <p>{{ userName }}</p>
          </div>
          <div class="profile-field">
            <label>Email</label>
            <p>{{ userEmail }}</p>
          </div>
          <div class="profile-field">
            <label>Role</label>
            <p>Administrator</p>
          </div>
          <button class="btn btn-primary">Edit Profile</button>
        </div>
      </div>

      <div class="profile-card">
        <h3 class="profile-card__title">Security</h3>
        <div class="profile-field">
          <label>Password</label>
          <p>••••••••</p>
        </div>
        <button class="btn btn-outline">Change Password</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useUserStore } from '@/stores/userStore'
import PageHeader from '@/components/shared/PageHeader.vue'

const userStore = useUserStore()

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
</script>

<style scoped>
.admin-profile {
  width: 100%;
}

.profile-sections {
  display: grid;
  gap: var(--spacing-lg);
  max-width: 800px;
}

.profile-card {
  background-color: var(--color-background);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
}

.profile-card__title {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
}

.profile-avatar {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-xl);
}

.profile-avatar__circle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 96px;
  height: 96px;
  background-color: var(--color-primary);
  color: var(--color-white);
  border-radius: var(--border-radius-full);
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
}

.profile-info {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.profile-info__title {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
}

.profile-field {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.profile-field label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-secondary);
}

.profile-field p {
  font-size: var(--font-size-base);
  color: var(--color-text);
}
</style>
