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
        @click="openTicket(ticket)"
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
            <p v-if="ticket.signature" class="text-xs text-emerald-500 flex items-center gap-1">
              <CheckCircle class="w-3 h-3" />
              Signed
            </p>
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
      <DialogContent class="sm:max-w-2xl max-h-[90vh] overflow-y-auto">
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
            <Label for="device-desc">Device Description</Label>
            <Textarea 
              id="device-desc" 
              v-model="newTicket.deviceDescription" 
              placeholder="Condition, color, visible damage, scratches, etc." 
              :rows="2" 
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

          <!-- Customer Signature -->
          <SignaturePad
            v-model="newTicket.signature"
            label="Customer Signature *"
            :width="550"
            :height="150"
          />
          
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
          <!-- Status & Priority -->
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

          <!-- Customer Info -->
          <div class="space-y-2">
            <Label>Customer</Label>
            <Card>
              <CardContent class="p-3">
                <p class="font-medium">{{ getCustomerName(selectedTicket.customerId) }}</p>
                <p class="text-sm text-muted-foreground">{{ getCustomerPhone(selectedTicket.customerId) }}</p>
                <p class="text-sm text-muted-foreground">{{ getCustomerEmail(selectedTicket.customerId) }}</p>
                <p v-if="getCustomerDL(selectedTicket.customerId)" class="text-sm text-muted-foreground">
                  DL: {{ getCustomerDL(selectedTicket.customerId) }}
                </p>
              </CardContent>
            </Card>
          </div>

          <!-- Device Info -->
          <div class="space-y-2">
            <Label>Device & Serial</Label>
            <div class="grid grid-cols-2 gap-4">
              <Input v-model="selectedTicket.device" @input="updateTicket" />
              <Input v-model="selectedTicket.serialNumber" placeholder="Serial #" @input="updateTicket" />
            </div>
          </div>

          <!-- Device Description -->
          <div class="space-y-2">
            <Label for="edit-device-desc">Device Description</Label>
            <Textarea
              id="edit-device-desc"
              v-model="selectedTicket.deviceDescription"
              :rows="2"
              placeholder="Condition, color, visible damage, scratches, etc."
              @input="updateTicket"
            />
          </div>

          <!-- Issue Description -->
          <div class="space-y-2">
            <Label for="edit-issue">Issue Description</Label>
            <Textarea
              id="edit-issue"
              v-model="selectedTicket.issue"
              :rows="3"
              @input="updateTicket"
            />
          </div>

          <!-- Price -->
          <div class="space-y-2">
            <Label for="price">Price</Label>
            <Input
              id="price"
              v-model.number="selectedTicket.price"
              type="number"
              step="0.01"
              @input="updateTicket"
            />
          </div>

          <!-- Signature -->
          <div class="space-y-2">
            <Label>Customer Signature</Label>
            <div v-if="selectedTicket.signature" class="border border-border rounded-lg p-4 bg-muted/20">
              <img :src="selectedTicket.signature" alt="Signature" class="max-w-full h-auto" />
              <Button variant="outline" size="sm" class="mt-2" @click="clearSignature">
                Clear Signature
              </Button>
            </div>
            <SignaturePad
              v-else
              v-model="selectedTicket.signature"
              label="Add Signature"
              :width="600"
              :height="150"
              @update:model-value="updateTicket"
            />
          </div>

          <!-- Notes -->
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

          <!-- Actions -->
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
            <Button variant="outline" class="flex-1" @click="skipEmail">
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
  Mail,
  CheckCircle
} from 'lucide-vue-next'
import { Card, CardContent } from '~/components/ui/card'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '~/components/ui/dialog'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
import { Label } from '~/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '~/components/ui/select'
import { Textarea } from '~/components/ui/textarea'
import { Badge } from '~/components/ui/badge'
import SignaturePad from '~/components/SignaturePad.vue'

definePageMeta({
  middleware: ['auth']
})

const appStore = useAppStore()
const { customers, tickets, settings, saveAll, trackDevice } = appStore
const { addNotification } = useNotifications()

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
  deviceDescription: '',
  issue: '',
  serialNumber: '',
  priority: 'normal',
  signature: ''
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

const getCustomerDL = (customerId: number) => {
  const customer = customers.value.find(c => c.id === customerId)
  return customer?.driversLicense || ''
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

const openTicket = (ticket: Ticket) => {
  selectedTicket.value = { ...ticket }
}

const clearSignature = () => {
  if (selectedTicket.value) {
    selectedTicket.value.signature = null
    updateTicket()
  }
}

const onStatusChange = (newStatus: string) => {
  if (!selectedTicket.value) return
  
  const oldStatus = selectedTicket.value.status
  
  if ((newStatus === 'Completed' || newStatus === 'Delivered') && 
      (oldStatus !== 'Completed' && oldStatus !== 'Delivered')) {
    const customerEmail = getCustomerEmail(selectedTicket.value.customerId)
    if (customerEmail && customerEmail !== 'No email on file') {
      emailRecipient.value = customerEmail
      emailMessage.value = `Good news! Your ${selectedTicket.value.device} repair is complete and ready for pickup.`
      pendingStatusChange.value = newStatus
      emailDialogOpen.value = true
    } else {
      updateTicket()
      addNotification('Status Updated', `Ticket #${selectedTicket.value.id} marked as ${newStatus}`, 'success')
    }
  } else {
    updateTicket()
    addNotification('Status Updated', `Ticket #${selectedTicket.value.id} status changed to ${newStatus}`, 'info')
  }
}

const sendEmail = () => {
  addNotification('Email Sent', `Completion email sent to ${emailRecipient.value}`, 'success')
  alert(`Email sent to ${emailRecipient.value}!\n\nMessage: ${emailMessage.value}\n\n(In production, this would integrate with SendGrid, Mailgun, or your email service)`)
  
  emailDialogOpen.value = false
  if (pendingStatusChange.value && selectedTicket.value) {
    selectedTicket.value.status = pendingStatusChange.value
    pendingStatusChange.value = null
  }
  updateTicket()
}

const skipEmail = () => {
  emailDialogOpen.value = false
  if (pendingStatusChange.value && selectedTicket.value) {
    selectedTicket.value.status = pendingStatusChange.value
    pendingStatusChange.value = null
  }
  updateTicket()
}

const createTicket = () => {
  if (!newTicket.value.customerId || !newTicket.value.device || !newTicket.value.issue) {
    addNotification('Missing Information', 'Please fill in all required fields', 'warning')
    return
  }

  if (!newTicket.value.signature) {
    addNotification('Signature Required', 'Customer signature is required', 'warning')
    return
  }

  const ticket: Ticket = {
    id: Math.max(...tickets.value.map(t => t.id), 100) + 1,
    customerId: newTicket.value.customerId,
    device: newTicket.value.device,
    deviceDescription: newTicket.value.deviceDescription,
    issue: newTicket.value.issue,
    status: 'Open',
    tracking: null,
    price: 0,
    serialNumber: newTicket.value.serialNumber,
    warrantyDays: 0,
    warrantyStart: null,
    photos: [],
    signature: newTicket.value.signature,
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

  addNotification('Ticket Created', `Ticket #${ticket.id} created successfully`, 'success')

  newTicketOpen.value = false
  newTicket.value = { 
    customerId: null, 
    device: '', 
    deviceDescription: '',
    issue: '', 
    serialNumber: '', 
    priority: 'normal',
    signature: ''
  }
}

const updateTicket = () => {
  if (selectedTicket.value) {
    selectedTicket.value.updatedAt = new Date().toISOString()
    const index = tickets.value.findIndex(t => t.id === selectedTicket.value?.id)
    if (index > -1) {
      tickets.value[index] = { ...selectedTicket.value }
    }
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
  addNotification('Note Added', 'Note added to ticket', 'info')
  newNote.value = ''
}

const deleteTicket = () => {
  if (!selectedTicket.value) return
  
  if (confirm(`Delete ticket #${selectedTicket.value.id}? This cannot be undone.`)) {
    const index = tickets.value.findIndex(t => t.id === selectedTicket.value?.id)
    if (index > -1) {
      tickets.value.splice(index, 1)
      saveAll()
      addNotification('Ticket Deleted', `Ticket #${selectedTicket.value.id} has been deleted`, 'info')
      showDetails.value = false
    }
  }
}
</script>
