<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h2 class="text-2xl font-bold">Settings</h2>
      <p class="text-sm text-muted-foreground mt-1">Configure your business and integrations</p>
    </div>

    <!-- Settings Tabs -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Business Settings -->
      <Card class="lg:col-span-2">
        <CardHeader>
          <CardTitle>Business Information</CardTitle>
        </CardHeader>
        <CardContent class="space-y-4">
          <div class="space-y-2">
            <Label for="business-name">Business Name</Label>
            <Input id="business-name" v-model="form.businessName" placeholder="Your Repair Shop" />
          </div>

          <div class="space-y-2">
            <Label for="email">Email</Label>
            <Input id="email" v-model="form.email" type="email" placeholder="contact@yourshop.com" />
          </div>

          <div class="space-y-2">
            <Label for="phone">Phone</Label>
            <Input id="phone" v-model="form.phone" placeholder="(555) 123-4567" />
          </div>

          <div class="space-y-2">
            <Label for="address">Address</Label>
            <Textarea id="address" v-model="form.address" :rows="3" placeholder="123 Main St, City, State ZIP" />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="currency">Currency</Label>
              <Input id="currency" v-model="form.currency" placeholder="$" />
            </div>

            <div class="space-y-2">
              <Label for="tax-rate">Tax Rate (%)</Label>
              <Input id="tax-rate" v-model.number="form.taxRate" type="number" step="0.01" />
            </div>
          </div>

          <div class="space-y-2">
            <Label for="statuses">Ticket Statuses (comma separated)</Label>
            <Input id="statuses" v-model="form.statuses" placeholder="Open, In Progress, Completed" />
          </div>

          <Button @click="saveSettings">
            <Save class="w-4 h-4 mr-2" />
            Save Business Settings
          </Button>
        </CardContent>
      </Card>

      <!-- Quick Actions -->
      <div class="space-y-6">
        <!-- Square Integration -->
        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2">
              <CreditCard class="w-5 h-5" />
              Square Integration
            </CardTitle>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="p-4 rounded-lg bg-blue-500/5 border border-blue-500/20">
              <div class="flex items-start gap-3">
                <Info class="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" />
                <div class="text-sm text-blue-500">
                  <p class="font-medium mb-1">Square Setup</p>
                  <p class="text-xs opacity-80">Enter your Square credentials to enable card payments</p>
                </div>
              </div>
            </div>

            <div class="space-y-2">
              <Label for="square-app-id">Application ID</Label>
              <Input 
                id="square-app-id" 
                v-model="squareSettings.applicationId" 
                placeholder="sq0idp-..."
                type="password"
              />
            </div>

            <div class="space-y-2">
              <Label for="square-location-id">Location ID</Label>
              <Input 
                id="square-location-id" 
                v-model="squareSettings.locationId" 
                placeholder="L..."
              />
            </div>

            <div class="space-y-2">
              <Label for="square-access-token">Access Token</Label>
              <Input 
                id="square-access-token" 
                v-model="squareSettings.accessToken" 
                placeholder="EAAAl..."
                type="password"
              />
            </div>

            <div class="flex items-center justify-between p-3 rounded-lg bg-muted/30">
              <div class="flex items-center gap-2">
                <div class="w-2 h-2 rounded-full" :class="squareSettings.enabled ? 'bg-emerald-500' : 'bg-gray-500'"></div>
                <span class="text-sm font-medium">{{ squareSettings.enabled ? 'Connected' : 'Disconnected' }}</span>
              </div>
              <Button 
                variant="outline" 
                size="sm"
                @click="toggleSquare"
              >
                {{ squareSettings.enabled ? 'Disable' : 'Enable' }}
              </Button>
            </div>

            <Button 
              variant="outline" 
              class="w-full"
              @click="testSquareConnection"
            >
              <Zap class="w-4 h-4 mr-2" />
              Test Connection
            </Button>

            <div class="pt-2 border-t space-y-2">
              <p class="text-xs text-muted-foreground">Need Square credentials?</p>
              <a 
                href="https://developer.squareup.com/apps" 
                target="_blank"
                class="text-xs text-primary hover:underline flex items-center gap-1"
              >
                Get them from Square Developer Dashboard
                <ExternalLink class="w-3 h-3" />
              </a>
            </div>
          </CardContent>
        </Card>

        <!-- Data Management -->
        <Card>
          <CardHeader>
            <CardTitle>Data Management</CardTitle>
          </CardHeader>
          <CardContent class="space-y-3">
            <Button variant="outline" class="w-full" @click="exportData">
              <Download class="w-4 h-4 mr-2" />
              Export All Data
            </Button>

            <Button variant="outline" class="w-full" @click="clearCache">
              <RefreshCw class="w-4 h-4 mr-2" />
              Clear Cache
            </Button>

            <Button variant="destructive" class="w-full" @click="resetData">
              <Trash2 class="w-4 h-4 mr-2" />
              Reset All Data
            </Button>
          </CardContent>
        </Card>

        <!-- Account -->
        <Card>
          <CardHeader>
            <CardTitle>Account</CardTitle>
          </CardHeader>
          <CardContent class="space-y-3">
            <div class="flex items-center gap-3 p-3 rounded-lg bg-muted/30">
              <div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                <User class="w-5 h-5 text-primary" />
              </div>
              <div>
                <p class="text-sm font-medium">Demo Account</p>
                <p class="text-xs text-muted-foreground">admin@novaops.com</p>
              </div>
            </div>

            <Button variant="outline" class="w-full" @click="logout">
              <LogOut class="w-4 h-4 mr-2" />
              Sign Out
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { 
  Save, 
  CreditCard, 
  Info, 
  Zap, 
  ExternalLink,
  Download,
  RefreshCw,
  Trash2,
  User,
  LogOut
} from 'lucide-vue-next'
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
import { Label } from '~/components/ui/label'
import { Textarea } from '~/components/ui/textarea'

definePageMeta({
  middleware: ['auth']
})

const appStore = useAppStore()
const { settings, saveAll } = appStore

const form = ref({
  businessName: settings.value.businessName,
  email: settings.value.email,
  phone: settings.value.phone || '',
  address: settings.value.address || '',
  currency: settings.value.currency,
  taxRate: settings.value.taxRate,
  statuses: settings.value.statuses
})

const squareSettings = ref({
  enabled: false,
  applicationId: '',
  locationId: '',
  accessToken: ''
})

// Load Square settings from localStorage
onMounted(() => {
  if (process.client) {
    const saved = localStorage.getItem('squareSettings')
    if (saved) {
      squareSettings.value = JSON.parse(saved)
    }
  }
})

const saveSettings = () => {
  settings.value.businessName = form.value.businessName
  settings.value.email = form.value.email
  settings.value.phone = form.value.phone
  settings.value.address = form.value.address
  settings.value.currency = form.value.currency
  settings.value.taxRate = form.value.taxRate
  settings.value.statuses = form.value.statuses
  
  saveAll()
  alert('Settings saved!')
}

const toggleSquare = () => {
  squareSettings.value.enabled = !squareSettings.value.enabled
  if (process.client) {
    localStorage.setItem('squareSettings', JSON.stringify(squareSettings.value))
  }
  alert(squareSettings.value.enabled ? 'Square enabled!' : 'Square disabled')
}

const testSquareConnection = () => {
  if (!squareSettings.value.applicationId || !squareSettings.value.locationId) {
    alert('Please enter Square credentials first')
    return
  }
  
  alert('Testing Square connection...\n\nNote: This is a demo. In production, this would:\n1. Validate credentials\n2. Test API connection\n3. Verify location access')
}

const exportData = () => {
  const data = {
    settings: settings.value,
    tickets: appStore.tickets,
    customers: appStore.customers,
    inventory: appStore.inventory,
    appointments: appStore.appointments,
    quickSales: appStore.quickSales
  }
  
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `novaops-backup-${new Date().toISOString().split('T')[0]}.json`
  a.click()
  URL.revokeObjectURL(url)
}

const clearCache = () => {
  if (confirm('Clear cache? This will refresh the app.')) {
    if (process.client) {
      localStorage.removeItem('squareSettings')
      location.reload()
    }
  }
}

const resetData = () => {
  if (confirm('⚠️ WARNING: This will delete ALL data (tickets, customers, inventory, etc). This cannot be undone!\n\nAre you sure?')) {
    if (process.client) {
      localStorage.clear()
      location.href = '/login'
    }
  }
}

const logout = () => {
  if (process.client) {
    localStorage.removeItem('isAuthenticated')
    location.href = '/login'
  }
}
</script>
