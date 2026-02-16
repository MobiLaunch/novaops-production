#!/bin/bash

echo "🚀 Adding final features..."

# 1. Update tickets page with email prompt on close
cat > pages/tickets.vue << 'EOF'
<template>
  <div class="space-y-6">
    <!-- Header Actions -->
    <div class="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
      <div class="flex-1 w-full sm:w-auto relative">
        <Search class="absolute left-3 top-3 h-5 w-5 text-muted-foreground" />
        <Input
          v-model="searchQuery"
          placeholder="Search tickets..."
          class="pl-10 h-11"
        />
      </div>
      <div class="flex gap-2 w-full sm:w-auto">
        <Select v-model="filterStatus">
          <SelectTrigger class="w-full sm:w-[180px]">
            <SelectValue placeholder="All Statuses" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem :value="null">All Statuses</SelectItem>
            <SelectItem
              v-for="status in statusList"
              :key="status"
              :value="status"
            >
              {{ status }}
            </SelectItem>
          </SelectContent>
        </Select>
        <Button size="lg" @click="newTicketOpen = true">
          <Plus class="w-4 h-4 mr-2" />
          New Ticket
        </Button>
      </div>
    </div>

    <!-- Tickets Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4">
      <Card
        v-for="ticket in filteredTickets"
        :key="ticket.id"
        class="cursor-pointer hover:border-primary/50 transition-all"
        @click="selectedTicket = ticket"
      >
        <CardContent class="p-6 space-y-4">
          <div class="flex items-start justify-between">
            <div>
              <div class="flex items-center gap-2">
                <h3 class="font-semibold">#{{ ticket.id }}</h3>
                <Badge :variant="getPriorityVariant(ticket.priority)" class="text-xs">
                  {{ ticket.priority }}
                </Badge>
              </div>
              <p class="text-sm text-muted-foreground mt-1">{{ getCustomerName(ticket.customerId) }}</p>
            </div>
            <Badge :class="getStatusBadgeClass(ticket.status)">
              {{ ticket.status }}
            </Badge>
          </div>

          <div class="space-y-2">
            <div class="flex items-center gap-2">
              <Smartphone class="w-4 h-4 text-muted-foreground" />
              <span class="text-sm font-medium">{{ ticket.device }}</span>
            </div>
            <p class="text-sm text-muted-foreground line-clamp-2">{{ ticket.issue }}</p>
          </div>

          <div class="flex items-center justify-between pt-3 border-t">
            <span class="text-sm font-medium">
              {{ formatCurrency(ticket.price) }}
            </span>
            <span class="text-xs text-muted-foreground">
              {{ formatDate(ticket.createdAt) }}
            </span>
          </div>
        </CardContent>
      </Card>

      <div v-if="filteredTickets.length === 0" class="col-span-full">
        <Card>
          <CardContent class="text-center py-12">
            <Inbox class="w-16 h-16 mx-auto mb-4 text-muted-foreground opacity-50" />
            <h3 class="text-lg font-semibold mb-2">No tickets found</h3>
            <p class="text-muted-foreground mb-6">Get started by creating your first ticket</p>
            <Button @click="newTicketOpen = true">
              <Plus class="w-4 h-4 mr-2" />
              Create Ticket
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>

    <!-- New Ticket Dialog -->
    <Dialog v-model:open="newTicketOpen">
      <DialogContent class="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>Create New Ticket</DialogTitle>
        </DialogHeader>
        
        <div class="space-y-4 py-4">
          <div class="space-y-2">
            <Label for="customer">Customer *</Label>
            <Select v-model="newTicket.customerId">
              <SelectTrigger id="customer">
                <SelectValue placeholder="Select customer" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem
                  v-for="customer in customers"
                  :key="customer.id"
                  :value="customer.id"
                >
                  {{ customer.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div class="space-y-2">
            <Label for="device">Device *</Label>
            <Input 
              id="device" 
              v-model="newTicket.device" 
              placeholder="e.g., iPhone 14 Pro" 
            />
          </div>
          
          <div class="space-y-2">
            <Label for="issue">Issue *</Label>
            <Textarea 
              id="issue" 
              v-model="newTicket.issue" 
              placeholder="Describe the problem" 
              :rows="3" 
            />
          </div>

          <div class="space-y-2">
            <Label for="serial">Serial Number</Label>
            <Input 
              id="serial" 
              v-model="newTicket.serialNumber" 
              placeholder="Optional" 
            />
          </div>
          
          <div class="space-y-2">
            <Label for="priority">Priority</Label>
            <Select v-model="newTicket.priority">
              <SelectTrigger id="priority">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="low">Low</SelectItem>
                <SelectItem value="normal">Normal</SelectItem>
                <SelectItem value="high">High</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div class="flex gap-3 pt-4">
            <Button 
              variant="outline" 
              class="flex-1"
              @click="newTicketOpen = false"
            >
              Cancel
            </Button>
            <Button 
              class="flex-1"
              @click="createTicket"
            >
              Create Ticket
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Ticket Details Dialog -->
    <Dialog v-model:open="showDetails">
      <DialogContent class="sm:max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader v-if="selectedTicket">
          <div class="flex items-center justify-between pr-8">
            <div>
              <DialogTitle>Ticket #{{ selectedTicket.id }}</DialogTitle>
              <p class="text-sm text-muted-foreground mt-1">{{ selectedTicket.device }}</p>
            </div>
          </div>
        </DialogHeader>
        
        <div v-if="selectedTicket" class="space-y-6 py-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label>Status</Label>
              <Select v-model="selectedTicket.status" @update:model-value="onStatusChange">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="status in statusList"
                    :key="status"
                    :value="status"
                  >
                    {{ status }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Priority</Label>
              <Select v-model="selectedTicket.priority" @update:model-value="updateTicket">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="low">Low</SelectItem>
                  <SelectItem value="normal">Normal</SelectItem>
                  <SelectItem value="high">High</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div class="space-y-2">
            <Label>Customer</Label>
            <Card>
              <CardContent class="p-3">
                <p class="font-medium">{{ getCustomerName(selectedTicket.customerId) }}</p>
                <p class="text-sm text-muted-foreground">{{ getCustomerPhone(selectedTicket.customerId) }}</p>
                <p class="text-sm text-muted-foreground">{{ getCustomerEmail(selectedTicket.customerId) }}</p>
              </CardContent>
            </Card>
          </div>

          <div class="space-y-2">
            <Label>Issue Description</Label>
            <p class="text-sm">{{ selectedTicket.issue }}</p>
          </div>

          <div class="space-y-2">
            <Label for="price">Price</Label>
            <Input
              id="price"
              v-model.number="selectedTicket.price"
              type="number"
              @input="updateTicket"
            />
          </div>

          <div class="space-y-2">
            <Label>Notes</Label>
            <div class="space-y-2 mb-3">
              <Card
                v-for="(note, idx) in selectedTicket.notes"
                :key="idx"
              >
                <CardContent class="p-3">
                  <p class="text-sm">{{ note.text }}</p>
                  <p class="text-xs text-muted-foreground mt-1">{{ formatDateTime(note.timestamp) }}</p>
                </CardContent>
              </Card>
            </div>
            <div class="flex gap-2">
              <Input
                v-model="newNote"
                placeholder="Add a note..."
                class="flex-1"
                @keyup.enter="addNote"
              />
              <Button size="icon" @click="addNote">
                <Plus class="w-4 h-4" />
              </Button>
            </div>
          </div>

          <div class="flex gap-3 pt-4 border-t">
            <Button variant="destructive" class="flex-1" @click="deleteTicket">
              <Trash2 class="w-4 h-4 mr-2" />
              Delete Ticket
            </Button>
            <Button class="flex-1" @click="showDetails = false">
              Close
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Email Dialog -->
    <Dialog v-model:open="emailDialogOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Send Completion Email</DialogTitle>
        </DialogHeader>
        <div class="space-y-4 py-4">
          <div class="p-4 rounded-lg bg-blue-500/5 border border-blue-500/20">
            <p class="text-sm text-blue-500">
              Send notification to <strong>{{ emailRecipient }}</strong> that their repair is complete?
            </p>
          </div>

          <div class="space-y-2">
            <Label for="email-message">Message (optional)</Label>
            <Textarea
              id="email-message"
              v-model="emailMessage"
              :rows="4"
              placeholder="Your device is ready for pickup!"
            />
          </div>

          <div class="flex gap-3">
            <Button variant="outline" class="flex-1" @click="emailDialogOpen = false">
              Skip
            </Button>
            <Button class="flex-1" @click="sendEmail">
              <Mail class="w-4 h-4 mr-2" />
              Send Email
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import type { Ticket } from '~/types'
import { 
  Search, 
  Plus, 
  Smartphone, 
  Inbox,
  Trash2,
  Mail
} from 'lucide-vue-next'
import { Card, CardContent } from '~/components/ui/card'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '~/components/ui/dialog'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
import { Label } from '~/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '~/components/ui/select'
import { Textarea } from '~/components/ui/textarea'
import { Badge } from '~/components/ui/badge'

definePageMeta({
  middleware: ['auth']
})

const appStore = useAppStore()
const { customers, tickets, settings, saveAll, trackDevice } = appStore

const searchQuery = ref('')
const filterStatus = ref<string | null>(null)
const newTicketOpen = ref(false)
const showDetails = computed({
  get: () => selectedTicket.value !== null,
  set: (val) => { if (!val) selectedTicket.value = null }
})
const selectedTicket = ref<Ticket | null>(null)
const newNote = ref('')
const emailDialogOpen = ref(false)
const emailRecipient = ref('')
const emailMessage = ref('')
const pendingStatusChange = ref<string | null>(null)

const newTicket = ref({
  customerId: null as number | null,
  device: '',
  issue: '',
  serialNumber: '',
  priority: 'normal'
})

const statusList = computed(() => {
  return settings.value.statuses.split(',').map(s => s.trim())
})

const filteredTickets = computed(() => {
  return tickets.value.filter(ticket => {
    const matchesSearch = !searchQuery.value || 
      ticket.device.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      ticket.issue.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      ticket.id.toString().includes(searchQuery.value) ||
      getCustomerName(ticket.customerId).toLowerCase().includes(searchQuery.value.toLowerCase())
    
    const matchesStatus = !filterStatus.value || ticket.status === filterStatus.value
    
    return matchesSearch && matchesStatus
  }).sort((a, b) => (b.id || 0) - (a.id || 0))
})

const formatCurrency = (amount: number) => {
  return `${settings.value.currency}${amount.toFixed(2)}`
}

const formatDate = (date?: string) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString()
}

const formatDateTime = (date: string) => {
  return new Date(date).toLocaleString()
}

const getCustomerName = (customerId: number) => {
  const customer = customers.value.find(c => c.id === customerId)
  return customer?.name || 'Unknown'
}

const getCustomerPhone = (customerId: number) => {
  const customer = customers.value.find(c => c.id === customerId)
  return customer?.phone || 'N/A'
}

const getCustomerEmail = (customerId: number) => {
  const customer = customers.value.find(c => c.id === customerId)
  return customer?.email || 'No email on file'
}

const getStatusBadgeClass = (status: string) => {
  const classes: Record<string, string> = {
    'Open': 'bg-blue-500/10 text-blue-500 hover:bg-blue-500/20',
    'In Progress': 'bg-yellow-500/10 text-yellow-500 hover:bg-yellow-500/20',
    'Waiting for Parts': 'bg-orange-500/10 text-orange-500 hover:bg-orange-500/20',
    'Completed': 'bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20',
    'Delivered': 'bg-gray-500/10 text-gray-500 hover:bg-gray-500/20'
  }
  return classes[status] || 'bg-gray-500/10 text-gray-500'
}

const getPriorityVariant = (priority: string) => {
  const variants: Record<string, 'default' | 'secondary' | 'destructive' | 'outline'> = {
    'low': 'secondary',
    'normal': 'outline',
    'high': 'destructive'
  }
  return variants[priority] || 'outline'
}

const onStatusChange = (newStatus: string) => {
  if (!selectedTicket.value) return
  
  const oldStatus = selectedTicket.value.status
  
  // Check if changing to Completed or Delivered
  if ((newStatus === 'Completed' || newStatus === 'Delivered') && 
      (oldStatus !== 'Completed' && oldStatus !== 'Delivered')) {
    // Prompt for email
    const customerEmail = getCustomerEmail(selectedTicket.value.customerId)
    if (customerEmail && customerEmail !== 'No email on file') {
      emailRecipient.value = customerEmail
      emailMessage.value = `Good news! Your ${selectedTicket.value.device} repair is complete and ready for pickup.`
      pendingStatusChange.value = newStatus
      emailDialogOpen.value = true
    } else {
      // No email, just update
      updateTicket()
    }
  } else {
    updateTicket()
  }
}

const sendEmail = () => {
  // In production, this would call your email API
  alert(`Email sent to ${emailRecipient.value}!\n\nMessage: ${emailMessage.value}\n\n(In production, this would integrate with SendGrid, Mailgun, or your email service)`)
  
  emailDialogOpen.value = false
  if (pendingStatusChange.value) {
    selectedTicket.value!.status = pendingStatusChange.value
    pendingStatusChange.value = null
  }
  updateTicket()
}

const createTicket = () => {
  if (!newTicket.value.customerId || !newTicket.value.device || !newTicket.value.issue) {
    alert('Please fill in all required fields')
    return
  }

  const ticket: Ticket = {
    id: Math.max(...tickets.value.map(t => t.id), 100) + 1,
    customerId: newTicket.value.customerId,
    device: newTicket.value.device,
    issue: newTicket.value.issue,
    status: 'Open',
    tracking: null,
    price: 0,
    serialNumber: newTicket.value.serialNumber,
    warrantyDays: 0,
    warrantyStart: null,
    photos: [],
    signature: null,
    notes: [],
    parts: [],
    payments: [],
    timeLog: [],
    priority: newTicket.value.priority as 'low' | 'normal' | 'high',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  tickets.value.push(ticket)
  trackDevice(ticket.device)
  saveAll()

  newTicketOpen.value = false
  newTicket.value = { customerId: null, device: '', issue: '', serialNumber: '', priority: 'normal' }
}

const updateTicket = () => {
  if (selectedTicket.value) {
    selectedTicket.value.updatedAt = new Date().toISOString()
    saveAll()
  }
}

const addNote = () => {
  if (!newNote.value.trim() || !selectedTicket.value) return
  
  selectedTicket.value.notes.push({
    id: Date.now().toString(),
    text: newNote.value,
    timestamp: new Date().toISOString(),
    author: 'Admin'
  })
  
  updateTicket()
  newNote.value = ''
}

const deleteTicket = () => {
  if (!selectedTicket.value) return
  
  if (confirm(`Delete ticket #${selectedTicket.value.id}? This cannot be undone.`)) {
    const index = tickets.value.findIndex(t => t.id === selectedTicket.value?.id)
    if (index > -1) {
      tickets.value.splice(index, 1)
      saveAll()
      showDetails.value = false
    }
  }
}
</script>
EOF

echo "✅ Updated tickets.vue with email prompt"

# 2. Update inventory page with categories
cat > pages/inventory.vue << 'EOF_INV'
<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row gap-4 justify-between">
      <div class="flex-1 relative">
        <Search class="absolute left-3 top-3 h-5 w-5 text-muted-foreground" />
        <Input
          v-model="searchQuery"
          placeholder="Search inventory..."
          class="pl-10 h-11"
        />
      </div>
      <div class="flex gap-2">
        <Select v-model="filterCategory">
          <SelectTrigger class="w-[180px]">
            <SelectValue placeholder="All Categories" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem :value="null">All Categories</SelectItem>
            <SelectItem value="Parts">Parts</SelectItem>
            <SelectItem value="Tools">Tools</SelectItem>
            <SelectItem value="Accessories">Accessories</SelectItem>
          </SelectContent>
        </Select>
        <Button variant="outline" size="lg" @click="checkLowStock">
          <RefreshCw class="w-4 h-4 mr-2" />
          Check Stock
        </Button>
        <Button size="lg" @click="newItemOpen = true">
          <Plus class="w-4 h-4 mr-2" />
          Add Item
        </Button>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <Card>
        <CardContent class="p-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-blue-500/10 flex items-center justify-center">
              <Package class="w-6 h-6 text-blue-500" />
            </div>
            <div>
              <p class="text-sm text-muted-foreground">Total Items</p>
              <p class="text-2xl font-bold">{{ inventory.length }}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent class="p-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-amber-500/10 flex items-center justify-center">
              <AlertTriangle class="w-6 h-6 text-amber-500" />
            </div>
            <div>
              <p class="text-sm text-muted-foreground">Low Stock</p>
              <p class="text-2xl font-bold">{{ lowStockCount }}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent class="p-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-emerald-500/10 flex items-center justify-center">
              <DollarSign class="w-6 h-6 text-emerald-500" />
            </div>
            <div>
              <p class="text-sm text-muted-foreground">Total Value</p>
              <p class="text-2xl font-bold">{{ formatCurrency(totalValue) }}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent class="p-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-purple-500/10 flex items-center justify-center">
              <BarChart3 class="w-6 h-6 text-purple-500" />
            </div>
            <div>
              <p class="text-sm text-muted-foreground">In Stock</p>
              <p class="text-2xl font-bold">{{ totalStock }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Inventory Table -->
    <Card>
      <CardContent class="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Item</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Stock</TableHead>
              <TableHead>Cost</TableHead>
              <TableHead>Price</TableHead>
              <TableHead>Margin</TableHead>
              <TableHead class="w-[120px]"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="item in filteredInventory" :key="item.id">
              <TableCell>
                <div>
                  <p class="font-medium">{{ item.name }}</p>
                  <p class="text-sm text-muted-foreground">SKU: {{ item.sku }}</p>
                </div>
              </TableCell>

              <TableCell>
                <Badge variant="outline" class="text-xs">
                  {{ item.category || 'Uncategorized' }}
                </Badge>
              </TableCell>

              <TableCell>
                <Badge 
                  :class="item.stock <= item.low ? 'bg-red-500/10 text-red-500' : 
                         item.stock <= item.low * 2 ? 'bg-amber-500/10 text-amber-500' : 
                         'bg-emerald-500/10 text-emerald-500'"
                >
                  {{ item.stock }} units
                </Badge>
              </TableCell>

              <TableCell>
                <span>{{ formatCurrency(item.cost) }}</span>
              </TableCell>

              <TableCell>
                <span class="text-emerald-500 font-medium">{{ formatCurrency(item.price) }}</span>
              </TableCell>

              <TableCell>
                <span>{{ calculateMargin(item) }}%</span>
              </TableCell>

              <TableCell>
                <div class="flex gap-1">
                  <Button variant="ghost" size="icon" @click="editItem(item)">
                    <Pencil class="w-4 h-4" />
                  </Button>
                  <Button variant="ghost" size="icon" @click="adjustStock(item)">
                    <PlusCircle class="w-4 h-4 text-blue-500" />
                  </Button>
                  <Button variant="ghost" size="icon" @click="deleteItem(item.id)">
                    <Trash2 class="w-4 h-4 text-destructive" />
                  </Button>
                </div>
              </TableCell>
            </TableRow>

            <TableRow v-if="filteredInventory.length === 0">
              <TableCell colspan="7" class="h-24 text-center">
                <div class="flex flex-col items-center justify-center py-8">
                  <Package class="w-12 h-12 text-muted-foreground opacity-50 mb-2" />
                  <p class="text-muted-foreground">No inventory items found</p>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>

    <!-- New/Edit Item Dialog -->
    <Dialog v-model:open="newItemOpen">
      <DialogContent class="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>{{ editingItem ? 'Edit Item' : 'Add New Item' }}</DialogTitle>
        </DialogHeader>
        
        <div class="space-y-4 py-4">
          <div class="space-y-2">
            <Label for="item-name">Item Name *</Label>
            <Input id="item-name" v-model="itemForm.name" placeholder="e.g., iPhone 13 Screen" />
          </div>
          
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="sku">SKU *</Label>
              <Input id="sku" v-model="itemForm.sku" placeholder="e.g., SCR-IP13" />
            </div>

            <div class="space-y-2">
              <Label for="category">Category *</Label>
              <Select v-model="itemForm.category">
                <SelectTrigger id="category">
                  <SelectValue placeholder="Select category" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Parts">Parts</SelectItem>
                  <SelectItem value="Tools">Tools</SelectItem>
                  <SelectItem value="Accessories">Accessories</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="stock">Stock Quantity *</Label>
              <Input id="stock" v-model.number="itemForm.stock" type="number" min="0" />
            </div>
            
            <div class="space-y-2">
              <Label for="low">Low Stock Alert *</Label>
              <Input id="low" v-model.number="itemForm.low" type="number" min="0" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="cost">Cost Price *</Label>
              <Input id="cost" v-model.number="itemForm.cost" type="number" min="0" step="0.01" />
            </div>
            
            <div class="space-y-2">
              <Label for="price">Selling Price *</Label>
              <Input id="price" v-model.number="itemForm.price" type="number" min="0" step="0.01" />
            </div>
          </div>

          <Card>
            <CardContent class="p-3">
              <p class="text-sm text-muted-foreground">
                Profit Margin: 
                <span class="text-emerald-500 font-medium">
                  {{ calculateFormMargin() }}%
                </span>
              </p>
            </CardContent>
          </Card>
          
          <div class="flex gap-3 pt-4">
            <Button variant="outline" class="flex-1" @click="cancelEdit">
              Cancel
            </Button>
            <Button class="flex-1" @click="saveItem">
              {{ editingItem ? 'Update' : 'Add' }} Item
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Adjust Stock Dialog -->
    <Dialog v-model:open="adjustStockOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Adjust Stock: {{ selectedItem?.name }}</DialogTitle>
        </DialogHeader>
        
        <div class="space-y-4 py-4">
          <Card>
            <CardContent class="p-4">
              <p class="text-sm text-muted-foreground">Current Stock</p>
              <p class="text-2xl font-bold">{{ selectedItem?.stock }} units</p>
            </CardContent>
          </Card>

          <div class="space-y-2">
            <Label>Adjustment Type</Label>
            <Select v-model="adjustmentType">
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="add">Add Stock</SelectItem>
                <SelectItem value="remove">Remove Stock</SelectItem>
                <SelectItem value="set">Set Stock</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div class="space-y-2">
            <Label for="adj-qty">Quantity</Label>
            <Input id="adj-qty" v-model.number="adjustmentQty" type="number" min="0" />
          </div>

          <Card class="border-blue-500/20 bg-blue-500/5">
            <CardContent class="p-3">
              <p class="text-sm text-blue-500">
                New stock will be: 
                <span class="font-bold">{{ calculateNewStock() }} units</span>
              </p>
            </CardContent>
          </Card>
          
          <div class="flex gap-3 pt-4">
            <Button variant="outline" class="flex-1" @click="adjustStockOpen = false">
              Cancel
            </Button>
            <Button class="flex-1" @click="applyStockAdjustment">
              Apply
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import type { InventoryItem } from '~/types'
import { 
  Search, 
  RefreshCw, 
  Plus, 
  Package, 
  AlertTriangle, 
  DollarSign, 
  BarChart3,
  Pencil,
  PlusCircle,
  Trash2
} from 'lucide-vue-next'
import { Card, CardContent } from '~/components/ui/card'
import { Table, TableHeader, TableBody, TableHead, TableRow, TableCell } from '~/components/ui/table'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '~/components/ui/dialog'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
import { Label } from '~/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '~/components/ui/select'
import { Badge } from '~/components/ui/badge'

definePageMeta({
  middleware: ['auth']
})

const appStore = useAppStore()
const { inventory, settings, saveAll } = appStore

const searchQuery = ref('')
const filterCategory = ref<string | null>(null)
const newItemOpen = ref(false)
const adjustStockOpen = ref(false)
const editingItem = ref<InventoryItem | null>(null)
const selectedItem = ref<InventoryItem | null>(null)
const adjustmentType = ref('add')
const adjustmentQty = ref(0)

const itemForm = ref({
  name: '',
  sku: '',
  category: 'Parts',
  stock: 0,
  low: 5,
  cost: 0,
  price: 0
})

const filteredInventory = computed(() => {
  return inventory.value.filter(item => {
    const query = searchQuery.value.toLowerCase()
    const matchesSearch = item.name.toLowerCase().includes(query) || item.sku.toLowerCase().includes(query)
    const matchesCategory = !filterCategory.value || (item as any).category === filterCategory.value
    return matchesSearch && matchesCategory
  })
})

const lowStockCount = computed(() => inventory.value.filter(item => item.stock <= item.low).length)
const totalValue = computed(() => inventory.value.reduce((sum, item) => sum + (item.price * item.stock), 0))
const totalStock = computed(() => inventory.value.reduce((sum, item) => sum + item.stock, 0))

const formatCurrency = (amount: number) => `${settings.value.currency}${amount.toFixed(2)}`
const calculateMargin = (item: InventoryItem) => item.price === 0 ? 0 : Math.round(((item.price - item.cost) / item.price) * 100)
const calculateFormMargin = () => itemForm.value.price === 0 ? 0 : Math.round(((itemForm.value.price - itemForm.value.cost) / itemForm.value.price) * 100)
const calculateNewStock = () => {
  if (!selectedItem.value) return 0
  if (adjustmentType.value === 'add') return selectedItem.value.stock + adjustmentQty.value
  else if (adjustmentType.value === 'remove') return Math.max(0, selectedItem.value.stock - adjustmentQty.value)
  else return adjustmentQty.value
}

const saveItem = () => {
  if (!itemForm.value.name || !itemForm.value.sku) {
    alert('Name and SKU are required')
    return
  }
  if (editingItem.value) {
    const index = inventory.value.findIndex(i => i.id === editingItem.value!.id)
    if (index > -1) {
      inventory.value[index] = { ...editingItem.value, ...itemForm.value }
    }
  } else {
    const newItem: any = {
      id: Math.max(...inventory.value.map(i => i.id), 0) + 1,
      ...itemForm.value
    }
    inventory.value.push(newItem)
  }
  saveAll()
  cancelEdit()
}

const editItem = (item: InventoryItem) => {
  editingItem.value = item
  itemForm.value = { ...item, category: (item as any).category || 'Parts' }
  newItemOpen.value = true
}

const cancelEdit = () => {
  newItemOpen.value = false
  editingItem.value = null
  itemForm.value = { name: '', sku: '', category: 'Parts', stock: 0, low: 5, cost: 0, price: 0 }
}

const adjustStock = (item: InventoryItem) => {
  selectedItem.value = item
  adjustmentType.value = 'add'
  adjustmentQty.value = 0
  adjustStockOpen.value = true
}

const applyStockAdjustment = () => {
  if (!selectedItem.value) return
  const item = inventory.value.find(i => i.id === selectedItem.value!.id)
  if (item) {
    item.stock = calculateNewStock()
    saveAll()
  }
  adjustStockOpen.value = false
  selectedItem.value = null
}

const deleteItem = (id: number) => {
  const item = inventory.value.find(i => i.id === id)
  if (!item) return
  if (confirm(`Delete ${item.name}? This cannot be undone.`)) {
    const index = inventory.value.findIndex(i => i.id === id)
    if (index > -1) {
      inventory.value.splice(index, 1)
      saveAll()
    }
  }
}

const checkLowStock = () => {
  const lowItems = inventory.value.filter(item => item.stock <= item.low)
  if (lowItems.length === 0) {
    alert('All good! No low stock items')
  } else {
    alert(`Low stock alert: ${lowItems.length} item(s) need restocking`)
  }
}
</script>
EOF_INV

echo "✅ Updated inventory.vue with categories"

# 3. Add mobile menu to default layout
cat > layouts/default.vue << 'EOF_LAYOUT'
<template>
  <div class="min-h-screen bg-background">
    <!-- Mobile Menu Overlay -->
    <div 
      v-if="mobileMenuOpen"
      class="fixed inset-0 z-50 lg:hidden"
      @click="mobileMenuOpen = false"
    >
      <div class="fixed inset-0 bg-background/80 backdrop-blur-sm" />
      <aside class="fixed left-0 top-0 z-50 h-screen w-64 border-r border-border bg-card animate-in slide-in-from-left">
        <div class="flex h-full flex-col">
          <!-- Logo -->
          <div class="flex h-16 items-center justify-between border-b border-border px-6">
            <h1 class="text-xl font-bold">NovaOps</h1>
            <Button variant="ghost" size="icon" @click="mobileMenuOpen = false">
              <X class="w-5 h-5" />
            </Button>
          </div>

          <!-- Navigation -->
          <nav class="flex-1 space-y-1 px-3 py-4">
            <NuxtLink
              v-for="item in navigation"
              :key="item.path"
              :to="item.path"
              class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground"
              active-class="bg-accent text-accent-foreground"
              @click="mobileMenuOpen = false"
            >
              <component :is="item.icon" class="h-5 w-5" />
              {{ item.name }}
            </NuxtLink>
          </nav>

          <!-- User Section -->
          <div class="border-t border-border p-4">
            <div class="flex items-center gap-3">
              <div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-primary-foreground">
                <User class="h-5 w-5" />
              </div>
              <div class="flex-1">
                <p class="text-sm font-medium">{{ settings.businessName }}</p>
                <p class="text-xs text-muted-foreground">{{ settings.email }}</p>
              </div>
            </div>
          </div>
        </div>
      </aside>
    </div>

    <!-- Desktop Sidebar -->
    <aside class="hidden lg:block fixed left-0 top-0 z-40 h-screen w-64 border-r border-border bg-card">
      <div class="flex h-full flex-col">
        <!-- Logo -->
        <div class="flex h-16 items-center border-b border-border px-6">
          <h1 class="text-xl font-bold">NovaOps</h1>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 space-y-1 px-3 py-4">
          <NuxtLink
            v-for="item in navigation"
            :key="item.path"
            :to="item.path"
            class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground"
            active-class="bg-accent text-accent-foreground"
          >
            <component :is="item.icon" class="h-5 w-5" />
            {{ item.name }}
          </NuxtLink>
        </nav>

        <!-- User Section -->
        <div class="border-t border-border p-4">
          <div class="flex items-center gap-3">
            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-primary-foreground">
              <User class="h-5 w-5" />
            </div>
            <div class="flex-1">
              <p class="text-sm font-medium">{{ settings.businessName }}</p>
              <p class="text-xs text-muted-foreground">{{ settings.email }}</p>
            </div>
          </div>
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <div class="lg:pl-64">
      <!-- Top Bar -->
      <header class="sticky top-0 z-30 flex h-16 items-center gap-4 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 px-4 sm:px-6">
        <!-- Mobile Menu Button -->
        <Button 
          variant="ghost" 
          size="icon" 
          class="lg:hidden"
          @click="mobileMenuOpen = true"
        >
          <Menu class="h-5 w-5" />
        </Button>

        <h2 class="text-lg font-semibold">{{ currentPageTitle }}</h2>
        <div class="ml-auto flex items-center gap-2">
          <Button variant="ghost" size="icon">
            <Bell class="h-5 w-5" />
          </Button>
          <Button variant="ghost" size="icon" @click="navigateTo('/settings')">
            <Settings class="h-5 w-5" />
          </Button>
        </div>
      </header>

      <!-- Page Content -->
      <main class="p-4 sm:p-6">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  LayoutDashboard, 
  TicketCheck, 
  Users, 
  Package, 
  CalendarDays, 
  ShoppingCart, 
  FileText,
  Settings as SettingsIcon,
  User,
  Bell,
  Settings,
  Menu,
  X
} from 'lucide-vue-next'
import { Button } from '~/components/ui/button'

const appStore = useAppStore()
const { settings } = appStore
const route = useRoute()

const mobileMenuOpen = ref(false)

const navigation = [
  { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
  { name: 'Tickets', path: '/tickets', icon: TicketCheck },
  { name: 'Customers', path: '/customers', icon: Users },
  { name: 'Inventory', path: '/inventory', icon: Package },
  { name: 'Calendar', path: '/calendar', icon: CalendarDays },
  { name: 'POS', path: '/pos', icon: ShoppingCart },
  { name: 'Reports', path: '/reports', icon: FileText },
  { name: 'Settings', path: '/settings', icon: SettingsIcon },
]

const currentPageTitle = computed(() => {
  const current = navigation.find(item => item.path === route.path)
  return current?.name || 'Dashboard'
})

// Close mobile menu when route changes
watch(() => route.path, () => {
  mobileMenuOpen.value = false
})
</script>
EOF_LAYOUT

echo "✅ Updated default.vue with mobile menu"

echo ""
echo "🎉 All features added!"
echo ""
echo "Features added:"
echo "  ✅ Email prompt when tickets are marked Completed/Delivered"
echo "  ✅ Inventory categories (Parts, Tools, Accessories)"
echo "  ✅ Mobile menu with hamburger button and slide-out overlay"
echo ""
echo "Run: npm run dev"
