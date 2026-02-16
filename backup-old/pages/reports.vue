<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
      <div>
        <h2 class="text-2xl font-bold">Reports & Analytics</h2>
        <p class="text-sm text-muted-foreground mt-1">Business insights and performance metrics</p>
      </div>
      <div class="flex gap-2">
        <Select v-model="dateRange">
          <SelectTrigger class="w-[180px]">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="7">Last 7 Days</SelectItem>
            <SelectItem value="30">Last 30 Days</SelectItem>
            <SelectItem value="90">Last 90 Days</SelectItem>
            <SelectItem value="365">Last Year</SelectItem>
          </SelectContent>
        </Select>
        <Button variant="outline">
          <Download class="w-4 h-4 mr-2" />
          Export
        </Button>
      </div>
    </div>

    <!-- Key Metrics -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <Card>
        <CardContent class="p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-muted-foreground">Total Revenue</p>
              <p class="text-3xl font-bold mt-2">{{ formatCurrency(totalRevenue) }}</p>
              <p class="text-xs text-emerald-500 mt-2 flex items-center gap-1">
                <TrendingUp class="w-3 h-3" />
                +12.5% vs last period
              </p>
            </div>
            <div class="w-12 h-12 rounded-lg bg-emerald-500/10 flex items-center justify-center">
              <DollarSign class="w-6 h-6 text-emerald-500" />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent class="p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-muted-foreground">Total Tickets</p>
              <p class="text-3xl font-bold mt-2">{{ tickets.length }}</p>
              <p class="text-xs text-blue-500 mt-2 flex items-center gap-1">
                <TrendingUp class="w-3 h-3" />
                +8.2% vs last period
              </p>
            </div>
            <div class="w-12 h-12 rounded-lg bg-blue-500/10 flex items-center justify-center">
              <Ticket class="w-6 h-6 text-blue-500" />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent class="p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-muted-foreground">Avg Ticket Value</p>
              <p class="text-3xl font-bold mt-2">{{ formatCurrency(avgTicketValue) }}</p>
              <p class="text-xs text-purple-500 mt-2 flex items-center gap-1">
                <TrendingUp class="w-3 h-3" />
                +5.1% vs last period
              </p>
            </div>
            <div class="w-12 h-12 rounded-lg bg-purple-500/10 flex items-center justify-center">
              <Receipt class="w-6 h-6 text-purple-500" />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent class="p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-muted-foreground">Total Customers</p>
              <p class="text-3xl font-bold mt-2">{{ customers.length }}</p>
              <p class="text-xs text-amber-500 mt-2 flex items-center gap-1">
                <TrendingUp class="w-3 h-3" />
                +15.3% vs last period
              </p>
            </div>
            <div class="w-12 h-12 rounded-lg bg-amber-500/10 flex items-center justify-center">
              <Users class="w-6 h-6 text-amber-500" />
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Revenue Trend -->
      <Card>
        <CardHeader>
          <CardTitle class="flex items-center gap-2">
            <TrendingUp class="w-5 h-5" />
            Revenue Trend
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div class="h-[300px] flex items-center justify-center text-muted-foreground">
            <div class="text-center">
              <BarChart3 class="w-16 h-16 mx-auto mb-4 opacity-30" />
              <p>Revenue chart visualization</p>
              <p class="text-xs mt-2">Chart library integration needed</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Ticket Status Distribution -->
      <Card>
        <CardHeader>
          <CardTitle class="flex items-center gap-2">
            <PieChart class="w-5 h-5" />
            Ticket Status
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div class="space-y-4">
            <div v-for="status in ticketStatusBreakdown" :key="status.name" class="space-y-2">
              <div class="flex items-center justify-between text-sm">
                <span class="flex items-center gap-2">
                  <div class="w-3 h-3 rounded-full" :class="status.color"></div>
                  {{ status.name }}
                </span>
                <span class="font-medium">{{ status.count }} ({{ status.percentage }}%)</span>
              </div>
              <div class="w-full bg-muted rounded-full h-2">
                <div 
                  class="h-2 rounded-full transition-all" 
                  :class="status.color"
                  :style="{ width: `${status.percentage}%` }"
                ></div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Top Devices & Inventory Status -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Top Devices -->
      <Card>
        <CardHeader>
          <CardTitle>Top Devices</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="space-y-3">
            <div v-for="device in topDevices" :key="device.name" class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                  <Smartphone class="w-5 h-5 text-primary" />
                </div>
                <div>
                  <p class="font-medium text-sm">{{ device.name }}</p>
                  <p class="text-xs text-muted-foreground">{{ device.count }} repairs</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm font-medium">{{ formatCurrency(device.revenue) }}</p>
              </div>
            </div>

            <div v-if="topDevices.length === 0" class="text-center py-8 text-muted-foreground">
              <Smartphone class="w-12 h-12 mx-auto mb-2 opacity-50" />
              <p>No device data yet</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Inventory Alerts -->
      <Card>
        <CardHeader>
          <CardTitle class="flex items-center gap-2">
            <AlertTriangle class="w-5 h-5" />
            Inventory Alerts
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div class="space-y-3">
            <div v-for="item in lowStockItems" :key="item.id" class="flex items-center justify-between p-3 rounded-lg bg-amber-500/5 border border-amber-500/20">
              <div class="flex items-center gap-3">
                <AlertTriangle class="w-5 h-5 text-amber-500" />
                <div>
                  <p class="font-medium text-sm">{{ item.name }}</p>
                  <p class="text-xs text-muted-foreground">SKU: {{ item.sku }}</p>
                </div>
              </div>
              <Badge class="bg-amber-500/10 text-amber-500">
                {{ item.stock }} left
              </Badge>
            </div>

            <div v-if="lowStockItems.length === 0" class="text-center py-8">
              <CheckCircle class="w-12 h-12 mx-auto mb-2 text-emerald-500 opacity-50" />
              <p class="text-sm text-muted-foreground">All items well stocked</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Recent Activity -->
    <Card>
      <CardHeader>
        <CardTitle>Recent Transactions</CardTitle>
      </CardHeader>
      <CardContent class="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Date</TableHead>
              <TableHead>Customer</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Description</TableHead>
              <TableHead class="text-right">Amount</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="sale in recentActivity" :key="sale.id">
              <TableCell class="text-sm text-muted-foreground">
                {{ formatDate(sale.date) }}
              </TableCell>
              <TableCell class="text-sm">Walk-in</TableCell>
              <TableCell>
                <Badge variant="outline" class="text-xs">{{ sale.paymentMethod }}</Badge>
              </TableCell>
              <TableCell class="text-sm">{{ sale.description }}</TableCell>
              <TableCell class="text-right font-medium text-emerald-500">
                {{ formatCurrency(sale.amount) }}
              </TableCell>
            </TableRow>

            <TableRow v-if="recentActivity.length === 0">
              <TableCell colspan="5" class="h-24 text-center">
                <div class="flex flex-col items-center justify-center py-8">
                  <Receipt class="w-12 h-12 text-muted-foreground opacity-50 mb-2" />
                  <p class="text-muted-foreground">No recent activity</p>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { 
  Download, 
  TrendingUp, 
  DollarSign, 
  Ticket as Ticket,
  Receipt,
  Users,
  BarChart3,
  PieChart,
  Smartphone,
  AlertTriangle,
  CheckCircle
} from 'lucide-vue-next'
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'
import { Button } from '~/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '~/components/ui/select'
import { Badge } from '~/components/ui/badge'
import { Table, TableHeader, TableBody, TableHead, TableRow, TableCell } from '~/components/ui/table'

definePageMeta({
  middleware: ['auth']
})

const appStore = useAppStore()
const { tickets, customers, inventory, quickSales, settings } = appStore

const dateRange = ref('30')

const totalRevenue = computed(() => {
  return tickets.value.reduce((sum, ticket) => sum + (ticket.price || 0), 0) +
         quickSales.value.reduce((sum, sale) => sum + sale.amount, 0)
})

const avgTicketValue = computed(() => {
  if (tickets.value.length === 0) return 0
  return totalRevenue.value / tickets.value.length
})

const ticketStatusBreakdown = computed(() => {
  const statuses = ['Open', 'In Progress', 'Waiting for Parts', 'Completed', 'Delivered']
  const colors = [
    'bg-blue-500',
    'bg-yellow-500',
    'bg-orange-500',
    'bg-emerald-500',
    'bg-gray-500'
  ]
  
  return statuses.map((status, idx) => {
    const count = tickets.value.filter(t => t.status === status).length
    const percentage = tickets.value.length > 0 
      ? Math.round((count / tickets.value.length) * 100)
      : 0
    
    return {
      name: status,
      count,
      percentage,
      color: colors[idx]
    }
  })
})

const topDevices = computed(() => {
  const deviceMap = new Map<string, { count: number; revenue: number }>()
  
  tickets.value.forEach(ticket => {
    if (ticket.device) {
      const existing = deviceMap.get(ticket.device) || { count: 0, revenue: 0 }
      deviceMap.set(ticket.device, {
        count: existing.count + 1,
        revenue: existing.revenue + (ticket.price || 0)
      })
    }
  })
  
  return Array.from(deviceMap.entries())
    .map(([name, data]) => ({ name, ...data }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5)
})

const lowStockItems = computed(() => {
  return inventory.value
    .filter(item => item.stock <= item.low)
    .slice(0, 5)
})

const recentActivity = computed(() => {
  return [...quickSales.value]
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
    .slice(0, 10)
})

const formatCurrency = (amount: number) => {
  return `${settings.value.currency}${amount.toFixed(2)}`
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString()
}
</script>
