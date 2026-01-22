<script setup>
import { NResult, NSpace, NTag, NConfigProvider, useOsTheme, darkTheme, NButton } from 'naive-ui'
import { ref, computed, onMounted, onUnmounted } from 'vue'

const osTheme = useOsTheme()

// ==================== i18n ====================
const messages = {
  en: {
    title: 'Plantscience.ai System Maintenance',
    description: 'is currently updating its AI models.',
    maintenanceStart: 'Maintenance Start:',
    expectedCompletion: 'Expected Completion:',
    ukTime: 'UK Time',
    timeRemaining: 'Time Remaining',
    completed: 'Maintenance completed',
    checkBackLater: 'Please check back later',
    patience: 'We appreciate your patience while we improve our services'
  },
  zh: {
    title: 'Plantscience.ai 系统维护',
    description: '正在更新 AI 模型。',
    maintenanceStart: '维护开始时间：',
    expectedCompletion: '预计完成时间：',
    ukTime: '英国时间',
    timeRemaining: '剩余时间',
    completed: '维护已完成',
    checkBackLater: '请稍后再访问',
    patience: '感谢您的耐心等待，我们正在努力提升服务质量'
  }
}

// Detect browser language
const getBrowserLang = () => {
  const lang = navigator.language || navigator.userLanguage
  return lang.startsWith('zh') ? 'zh' : 'en'
}

const currentLang = ref(getBrowserLang())

const t = computed(() => messages[currentLang.value])

const toggleLang = () => {
  currentLang.value = currentLang.value === 'en' ? 'zh' : 'en'
}

const langButtonText = computed(() => currentLang.value === 'en' ? '中文' : 'English')

// ==================== Time Settings ====================
// Maintenance time settings (UK Time - GMT/UTC+0)
// Using ISO format with timezone offset for UK winter time (GMT)
const maintenanceStart = new Date('2026-01-22T22:30:00Z') // UK Time
const maintenanceEnd = new Date('2026-01-23T06:00:00Z') // UK Time

// Format time for UK timezone
const formatUKTime = (date) => {
  return date.toLocaleString('en-GB', {
    timeZone: 'Europe/London',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  })
}

// Format time for user's local timezone
const formatLocalTime = (date) => {
  return date.toLocaleString(undefined, {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  })
}

// Get user's timezone name
const userTimezone = computed(() => {
  return Intl.DateTimeFormat().resolvedOptions().timeZone
})

// Check if user is in UK timezone
const isUKTimezone = computed(() => {
  return userTimezone.value === 'Europe/London'
})

// Formatted times
const startTimeUK = computed(() => formatUKTime(maintenanceStart))
const endTimeUK = computed(() => formatUKTime(maintenanceEnd))
const startTimeLocal = computed(() => formatLocalTime(maintenanceStart))
const endTimeLocal = computed(() => formatLocalTime(maintenanceEnd))

// ==================== Countdown ====================
const remainingTime = ref('')
const countdown = ref(null)

const updateRemainingTime = () => {
  const now = new Date()
  const diff = maintenanceEnd - now

  if (diff <= 0) {
    remainingTime.value = t.value.completed
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
      <!-- Language Switch Button -->
      <NButton
        class="lang-switch"
        size="small"
        quaternary
        @click="toggleLang"
      >
        {{ langButtonText }}
      </NButton>

      <NSpace justify="center" align="center" :size="48" class="content-wrapper">
        <img
          src="./assets/mantainance_plantscience_ai.png"
          alt="Maintenance"
          class="maintenance-image animate-float"
        />
        <NResult
          status="warning"
          :title="t.title"
          description=""
          class="result-card animate-fade-in"
        >
          <template #description>
            <div class="description-text">
              {{ t.description }}
            </div>
          </template>
          <template #footer>
            <NSpace vertical align="center" :size="24">
              <div class="maintenance-time animate-fade-up">
                <div class="time-section">
                  <p class="time-label">{{ t.maintenanceStart }}</p>
                  <p class="time-value">{{ startTimeUK }} <span class="timezone-tag">({{ t.ukTime }})</span></p>
                  <p v-if="!isUKTimezone" class="time-local">{{ startTimeLocal }} <span class="timezone-tag">({{ userTimezone }})</span></p>
                </div>
                <div class="time-section">
                  <p class="time-label">{{ t.expectedCompletion }}</p>
                  <p class="time-value">{{ endTimeUK }} <span class="timezone-tag">({{ t.ukTime }})</span></p>
                  <p v-if="!isUKTimezone" class="time-local">{{ endTimeLocal }} <span class="timezone-tag">({{ userTimezone }})</span></p>
                </div>
                <div class="countdown-wrapper">
                  <p class="countdown-label">{{ t.timeRemaining }}</p>
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
                {{ t.checkBackLater }}
              </NTag>
              <p class="patience-text animate-fade-up">
                {{ t.patience }}
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

/* Language switch button */
.lang-switch {
  position: fixed;
  top: 16px;
  right: 16px;
  z-index: 100;
  font-weight: 500;
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
  position: relative;
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

.time-section {
  margin-bottom: 12px;
}

.time-label {
  font-weight: 600;
  color: var(--n-text-color-1);
  margin-bottom: 4px;
}

.time-value {
  font-size: 15px;
  color: var(--n-text-color-2);
}

.time-local {
  font-size: 14px;
  color: var(--n-primary-color);
  margin-top: 2px;
}

.timezone-tag {
  font-size: 12px;
  color: var(--n-text-color-3);
  font-weight: normal;
}

@media (max-width: 768px) {
  .countdown-display {
    font-size: 24px;
  }

  .time-value, .time-local {
    font-size: 13px;
  }

  .timezone-tag {
    font-size: 11px;
  }
}
</style>
