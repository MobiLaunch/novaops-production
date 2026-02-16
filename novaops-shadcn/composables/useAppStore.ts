import type { AppData, Customer, Ticket, InventoryItem, Settings, Analytics } from '~/types'

const defaultSettings: Settings = {
  shopName: 'NovaOps',
  waiver: 'I authorize the repair of my device. I understand that NovaOps is not responsible for data loss.',
  accentColor: '#8B5CF6',
  bgMode: 'oled',
  currency: '$',
  taxRate: 0,
  statuses: 'Open, In Progress, Waiting for Parts, Completed, Delivered',
  pin: '1234',
  darkModeEnabled: true,
  autoBackup: true,
  notifications: true
}

export const useAppStore = () => {
  const customers = useState<Customer[]>('customers', () => [])
  const inventory = useState<InventoryItem[]>('inventory', () => [])
  const tickets = useState<Ticket[]>('tickets', () => [])
  const todos = useState('todos', () => [])
  const quickSales = useState('quickSales', () => [])
  const appointments = useState('appointments', () => [])
  const protectionPlans = useState('protectionPlans', () => [])
  const settings = useState<Settings>('settings', () => ({ ...defaultSettings }))
  const analytics = useState<Analytics>('analytics', () => ({
    dailyRevenue: [],
    popularDevices: {},
    customerLifetime: {},
    avgRepairTime: 0
  }))

  const isAuthenticated = useState('isAuthenticated', () => false)
  const currentView = useState('currentView', () => 'dashboard')

  // Initialize data from localStorage
  const initializeData = () => {
    if (process.client) {
      try {
        const stored = localStorage.getItem('nova_customers')
        if (stored) customers.value = JSON.parse(stored)
        
        const storedInventory = localStorage.getItem('nova_inventory')
        if (storedInventory) inventory.value = JSON.parse(storedInventory)
        
        const storedTickets = localStorage.getItem('nova_tickets')
        if (storedTickets) tickets.value = JSON.parse(storedTickets)
        
        const storedTodos = localStorage.getItem('nova_todos')
        if (storedTodos) todos.value = JSON.parse(storedTodos)
        
        const storedQuickSales = localStorage.getItem('nova_quicksales')
        if (storedQuickSales) quickSales.value = JSON.parse(storedQuickSales)
        
        const storedAppointments = localStorage.getItem('nova_appointments')
        if (storedAppointments) appointments.value = JSON.parse(storedAppointments)
        
        const storedProtection = localStorage.getItem('nova_protection')
        if (storedProtection) protectionPlans.value = JSON.parse(storedProtection)
        
        const storedSettings = localStorage.getItem('nova_settings')
        if (storedSettings) {
          settings.value = { ...defaultSettings, ...JSON.parse(storedSettings) }
        }
        
        const storedAnalytics = localStorage.getItem('nova_analytics')
        if (storedAnalytics) analytics.value = JSON.parse(storedAnalytics)

        // Add default data if empty
        if (customers.value.length === 0) {
          customers.value = [
            { id: 1, name: 'Alex Mercer', phone: '555-0101', email: 'alex@example.com', tags: [], notes: '' }
          ]
        }

        if (inventory.value.length === 0) {
          inventory.value = [
            { id: 1, name: 'iPhone 13 Screen', sku: 'SCR-IP13', stock: 12, low: 5, cost: 45, price: 129 }
          ]
        }

        if (tickets.value.length === 0) {
          tickets.value = [
            {
              id: 101,
              customerId: 1,
              device: 'Pixel 7 Pro',
              issue: 'Cracked Screen',
              status: 'Open',
              tracking: null,
              price: 0,
              serialNumber: '',
              warrantyDays: 0,
              warrantyStart: null,
              photos: [],
              signature: null,
              notes: [],
              parts: [],
              payments: [],
              timeLog: [],
              priority: 'normal'
            }
          ]
        }
      } catch (e) {
        console.error('Error loading data:', e)
      }
    }
  }

  // Save all data
  const saveAll = () => {
    if (process.client) {
      try {
        localStorage.setItem('nova_customers', JSON.stringify(customers.value))
        localStorage.setItem('nova_inventory', JSON.stringify(inventory.value))
        localStorage.setItem('nova_tickets', JSON.stringify(tickets.value))
        localStorage.setItem('nova_todos', JSON.stringify(todos.value))
        localStorage.setItem('nova_quicksales', JSON.stringify(quickSales.value))
        localStorage.setItem('nova_appointments', JSON.stringify(appointments.value))
        localStorage.setItem('nova_protection', JSON.stringify(protectionPlans.value))
        localStorage.setItem('nova_settings', JSON.stringify(settings.value))
        localStorage.setItem('nova_analytics', JSON.stringify(analytics.value))
      } catch (e) {
        console.error('Error saving data:', e)
      }
    }
  }

  // Export data
  const exportData = () => {
    const data: AppData = {
      customers: customers.value,
      inventory: inventory.value,
      tickets: tickets.value,
      todos: todos.value,
      quickSales: quickSales.value,
      appointments: appointments.value,
      protectionPlans: protectionPlans.value,
      settings: settings.value,
      analytics: analytics.value
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `novaops_backup_${Date.now()}.json`
    a.click()
    URL.revokeObjectURL(url)
  }

  // Analytics functions
  const trackRevenue = (amount: number) => {
    const today = new Date().toISOString().split('T')[0]
    const existing = analytics.value.dailyRevenue.find(d => d.date === today)
    
    if (existing) {
      existing.amount += amount
    } else {
      analytics.value.dailyRevenue.push({ date: today, amount })
    }
    
    analytics.value.dailyRevenue = analytics.value.dailyRevenue.slice(-90)
    saveAll()
  }

  const trackDevice = (device: string) => {
    if (!analytics.value.popularDevices[device]) {
      analytics.value.popularDevices[device] = 0
    }
    analytics.value.popularDevices[device]++
    saveAll()
  }

  return {
    // State
    customers,
    inventory,
    tickets,
    todos,
    quickSales,
    appointments,
    protectionPlans,
    settings,
    analytics,
    isAuthenticated,
    currentView,
    
    // Methods
    initializeData,
    saveAll,
    exportData,
    trackRevenue,
    trackDevice
  }
}

// Error handling wrapper
const safeLocalStorage = {
  getItem: (key: string) => {
    try {
      return process.client ? localStorage.getItem(key) : null
    } catch (e) {
      console.error('localStorage.getItem failed:', e)
      return null
    }
  },
  setItem: (key: string, value: string) => {
    try {
      if (process.client) localStorage.setItem(key, value)
    } catch (e) {
      console.error('localStorage.setItem failed:', e)
    }
  }
}
