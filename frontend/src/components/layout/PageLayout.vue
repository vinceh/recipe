<template>
  <div class="page-layout">
    <slot name="navbar"></slot>

    <div class="page-layout__container">
      <div class="page-layout__sidebar page-layout__sidebar--left">
        <slot name="left-sidebar"></slot>
      </div>

      <div class="page-layout__content">
        <slot></slot>
      </div>

      <div class="page-layout__sidebar page-layout__sidebar--right">
        <slot name="right-sidebar"></slot>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  hideBreakpoint?: '1000' | '1200'
}

withDefaults(defineProps<Props>(), {
  hideBreakpoint: '1000'
})
</script>

<style scoped>
.page-layout {
  min-height: 100vh;
  background: var(--color-provisions-bg);
  display: flex;
  flex-direction: column;
}

.page-layout__container {
  display: flex;
  flex: 1;
  overflow: hidden;
  padding: 0;
}

.page-layout__sidebar {
  flex: 1;
  background: var(--color-provisions-bg);
  display: flex;
  flex-direction: column;
}

.page-layout__sidebar--left {
  position: relative;
}

.page-layout__content {
  flex: 0 0 600px;
  background: var(--color-provisions-bg);
  border-left: 1px solid var(--color-provisions-border);
  border-right: 1px solid var(--color-provisions-border);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
}

@media (max-width: 1000px) {
  .page-layout__sidebar {
    display: none;
  }

  .page-layout__container {
    flex-direction: column;
  }

  .page-layout__content {
    flex: 1;
    border-left: none;
    border-right: none;
  }
}
</style>
