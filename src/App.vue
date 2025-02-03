<script setup>
import { NResult, NSpace, NTag, NConfigProvider, useOsTheme, darkTheme, NTime } from 'naive-ui'
import { ref, onMounted, onUnmounted } from 'vue'

const osTheme = useOsTheme()

// Maintenance time settings
const maintenanceStart = new Date('2025-02-03T16:30:00')
const maintenanceEnd = new Date('2025-02-03T17:00:00')

const remainingTime = ref('')
const countdown = ref(null)

const updateRemainingTime = () => {
  const now = new Date()
  const diff = maintenanceEnd - now

  if (diff <= 0) {
    remainingTime.value = 'Maintenance completed'
    if (countdown.value) {
      clearInterval(countdown.value)
    }
    return
  }

  const hours = Math.floor(diff / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((diff % (1000 * 60)) / 1000)

  remainingTime.value = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
}

onMounted(() => {
  updateRemainingTime()
  countdown.value = setInterval(updateRemainingTime, 1000)
})

onUnmounted(() => {
  if (countdown.value) {
    clearInterval(countdown.value)
  }
})
</script>

<template>
  <NConfigProvider :theme="osTheme === 'dark' ? darkTheme : null">
    <div class="maintenance-container">
      <NSpace justify="center" align="center" :size="48" class="content-wrapper">
        <img 
          src="./assets/mantainance_plantscience_ai.png" 
          alt="Maintenance" 
          class="maintenance-image animate-float"
        />
        <NResult
          status="warning"
          title="Plantscience.ai System Maintenance"
          description=""
          class="result-card animate-fade-in"
        >
          <template #description>
            <div class="description-text">
              is currently updating its AI models.
            </div>
          </template>
          <template #footer>
            <NSpace vertical align="center" :size="24">
              <div class="maintenance-time animate-fade-up">
                <p>Maintenance Start: <NTime :time="maintenanceStart" format="yyyy-MM-dd HH:mm:ss" /></p>
                <p>Expected Completion: <NTime :time="maintenanceEnd" format="yyyy-MM-dd HH:mm:ss" /></p>
                <div class="countdown-wrapper">
                  <p class="countdown-label">Time Remaining</p>
                  <div class="countdown-display">{{ remainingTime }}</div>
                </div>
              </div>
              <NTag 
                :bordered="false"
                type="info"
                size="large"
                round
                class="waiting-tag animate-fade-up"
              >
                Please check back later
              </NTag>
              <p class="patience-text animate-fade-up">
                We appreciate your patience while we improve our services
              </p>
            </NSpace>
          </template>
        </NResult>
      </NSpace>
    </div>
  </NConfigProvider>
</template>

<style scoped>
/* Animation keyframes */
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Animation classes */
.animate-float {
  animation: float 3s ease-in-out infinite;
}

.animate-fade-in {
  animation: fadeIn 0.8s ease-out forwards;
}

.animate-fade-up {
  animation: fadeUp 0.8s ease-out forwards;
  animation-delay: 0.3s;
  opacity: 0;
}

/* Enhanced existing styles */
.maintenance-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
  background: var(--n-color);
  transition: background-color 0.3s ease;
}

.content-wrapper {
  max-width: 1200px;
  width: 100%;
  flex-wrap: nowrap !important;
}

.maintenance-image {
  max-width: 500px;
  height: auto;
  filter: drop-shadow(0 4px 16px rgba(0, 0, 0, 0.1));
  transition: filter 0.3s ease;
}

.maintenance-image:hover {
  filter: drop-shadow(0 8px 24px rgba(0, 0, 0, 0.15));
}

.result-card {
  background: var(--n-card-color);
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  min-width: 400px;
  transition: all 0.3s ease;
}

.result-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.maintenance-time p {
  transition: color 0.3s ease;
}

.maintenance-time p:hover {
  color: var(--n-primary-color);
}

.maintenance-time {
  text-align: center;
  font-size: 16px;
  color: var(--n-text-color-2);
  line-height: 1.8;
}

:deep(.n-result-header) {
  margin-bottom: 32px;
}

:deep(.n-result-icon) {
  font-size: 72px !important;
}

:deep(.n-result-title) {
  font-size: 32px !important;
  margin-top: 24px !important;
  background-color: var(--n-primary-color-suppl);
  color: var(--n-primary-color) !important;
  padding: 8px 16px;
  border-radius: 8px;
  display: inline-block;
}

:deep(.n-result-content) {
  font-size: 18px !important;
  margin-top: 12px !important;
  color: var(--n-text-color-2);
}

:deep(.n-result-footer) {
  margin-top: 32px;
}

@media (max-width: 1024px) {
  .content-wrapper {
    flex-direction: column !important;
  }

  .result-card {
    min-width: unset;
    width: 100%;
  }
}

@media (max-width: 768px) {
  .maintenance-image {
    max-width: 320px;
  }
  
  .maintenance-time {
    font-size: 14px;
  }
  
  :deep(.n-result-icon) {
    font-size: 56px !important;
  }
  
  :deep(.n-result-title) {
    font-size: 24px !important;
  }
  
  :deep(.n-result-content) {
    font-size: 16px !important;
  }
}

/* Add new styles */
.waiting-tag {
  padding: 12px 24px;
  font-size: 16px;
  background: var(--n-primary-color-suppl);
  color: var(--n-primary-color);
}

.patience-text {
  color: var(--n-text-color-3);
  font-size: 14px;
  margin-top: -8px;
  font-style: italic;
}

.countdown-wrapper {
  margin-top: 16px;
  padding: 12px;
  background: var(--n-primary-color-suppl);
  border-radius: 12px;
  text-align: center;
}

.countdown-label {
  font-size: 14px;
  color: var(--n-text-color-2);
  margin-bottom: 8px;
}

.countdown-display {
  font-family: monospace;
  font-size: 28px;
  font-weight: 700;
  color: var(--n-primary-color);
  letter-spacing: 2px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

@media (max-width: 768px) {
  .countdown-display {
    font-size: 24px;
  }
}
</style>
