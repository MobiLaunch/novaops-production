export interface Customer {
  id: number
  name: string
  phone: string
  email: string
  driversLicense?: string
  address?: string
  tags: string[]
  notes: string
}

export interface Ticket {
  id: number
  customerId: number
  device: string
  deviceDescription?: string
  issue: string
  status: string
  tracking: string | null
  price: number
  serialNumber: string
  warrantyDays: number
  warrantyStart: string | null
  photos: string[]
  signature: string | null
  notes: Array<{
    id: string
    text: string
    timestamp: string
    author: string
  }>
  parts: any[]
  payments: any[]
  timeLog: any[]
  priority: 'low' | 'normal' | 'high'
  createdAt: string
  updatedAt: string
}

export interface InventoryItem {
  id: number
  name: string
  sku: string
  category?: string
  stock: number
  low: number
  cost: number
  price: number
}

export interface Appointment {
  id: string
  customerId: number
  description: string
  date: string
  time: string
  status: 'scheduled' | 'confirmed' | 'completed' | 'cancelled'
  notes: string
}

export interface QuickSale {
  id: string
  description: string
  amount: number
  date: string
  paymentMethod: string
}

export interface Settings {
  businessName: string
  email: string
  phone?: string
  address?: string
  currency: string
  taxRate: number
  statuses: string
}
