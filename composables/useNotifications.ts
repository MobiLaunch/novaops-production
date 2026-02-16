import { ref } from 'vue'

interface Notification {
  id: string
  title: string
  message: string
  type: 'info' | 'success' | 'warning' | 'error'
  timestamp: Date
  read: boolean
}

const notifications = ref<Notification[]>([])

export const useNotifications = () => {
  const addNotification = (title: string, message: string, type: 'info' | 'success' | 'warning' | 'error' = 'info') => {
    const notification: Notification = {
      id: Date.now().toString(),
      title,
      message,
      type,
      timestamp: new Date(),
      read: false
    }
    
    notifications.value.unshift(notification)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      removeNotification(notification.id)
    }, 5000)
    
    // Save to localStorage
    if (process.client) {
      localStorage.setItem('notifications', JSON.stringify(notifications.value))
    }
  }

  const removeNotification = (id: string) => {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  }

  const markAsRead = (id: string) => {
    const notification = notifications.value.find(n => n.id === id)
    if (notification) {
      notification.read = true
    }
  }

  const clearAll = () => {
    notifications.value = []
    if (process.client) {
      localStorage.removeItem('notifications')
    }
  }

  const unreadCount = computed(() => {
    return notifications.value.filter(n => !n.read).length
  })

  // Load notifications on mount
  onMounted(() => {
    if (process.client) {
      const saved = localStorage.getItem('notifications')
      if (saved) {
        try {
          notifications.value = JSON.parse(saved)
        } catch (e) {
          console.error('Failed to load notifications')
        }
      }
    }
  })

  return {
    notifications,
    addNotification,
    removeNotification,
    markAsRead,
    clearAll,
    unreadCount
  }
}
