<template>
  <div class="h-[calc(100vh-8rem)] flex gap-4">
    <!-- Left: Product Catalog -->
    <div class="flex-1 flex flex-col gap-4 overflow-hidden">
      <!-- Search & Filters -->
      <div class="flex gap-3">
        <div class="relative flex-1">
          <Search class="absolute left-3 top-3 h-5 w-5 text-muted-foreground" />
          <Input
            v-model="searchQuery"
            placeholder="Search products..."
            class="pl-10"
          />
        </div>
        <Select v-model="selectedCategory">
          <SelectTrigger class="w-[180px]">
            <SelectValue placeholder="All Products" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem :value="null">All Products</SelectItem>
            <SelectItem value="screens">Screens</SelectItem>
            <SelectItem value="batteries">Batteries</SelectItem>
            <SelectItem value="accessories">Accessories</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <!-- Products Grid -->
      <div class="flex-1 overflow-y-auto">
        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          <Card
            v-for="item in filteredProducts"
            :key="item.id"
            class="cursor-pointer hover:border-primary/50 transition-all group"
            @click="addToCart(item)"
          >
            <CardContent class="p-4 space-y-3">
              <div class="aspect-square rounded-lg bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center group-hover:from-primary/20 group-hover:to-primary/10 transition-colors">
                <Package class="w-10 h-10 text-primary/50" />
              </div>
              <div class="space-y-1">
                <p class="font-medium truncate text-sm">{{ item.name }}</p>
                <p class="text-xs text-muted-foreground truncate">{{ item.sku }}</p>
                <div class="flex items-center justify-between">
                  <p class="text-lg font-bold text-primary">{{ formatCurrency(item.price) }}</p>
                  <Badge 
                    :class="item.stock > 0 ? 'bg-emerald-500/10 text-emerald-500' : 'bg-red-500/10 text-red-500'"
                    class="text-xs"
                  >
                    {{ item.stock }}
                  </Badge>
                </div>
              </div>
            </CardContent>
          </Card>

          <div v-if="filteredProducts.length === 0" class="col-span-full">
            <Card>
              <CardContent class="text-center py-12">
                <Package class="w-12 h-12 mx-auto mb-2 text-muted-foreground opacity-50" />
                <p class="text-muted-foreground">No products found</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>

    <!-- Right: Checkout Panel (Square-inspired) -->
    <div class="w-full lg:w-[400px] flex flex-col gap-4">
      <!-- Cart Items -->
      <Card class="flex-1 flex flex-col">
        <CardHeader class="pb-3">
          <div class="flex items-center justify-between">
            <CardTitle class="text-lg">Current Sale</CardTitle>
            <Button
              v-if="cart.length > 0"
              variant="ghost"
              size="sm"
              @click="clearCart"
              class="h-8 text-xs"
            >
              <Trash2 class="w-3 h-3 mr-1" />
              Clear
            </Button>
          </div>
        </CardHeader>

        <CardContent class="flex-1 overflow-y-auto space-y-2 pb-3">
          <div v-if="cart.length > 0" class="space-y-2">
            <div
              v-for="(item, index) in cart"
              :key="index"
              class="flex items-center gap-3 p-3 rounded-lg bg-muted/30 hover:bg-muted/50 transition-colors"
            >
              <div class="flex-1 min-w-0">
                <p class="font-medium truncate text-sm">{{ item.name }}</p>
                <p class="text-xs text-muted-foreground">{{ formatCurrency(item.price) }}</p>
              </div>
              <div class="flex items-center gap-1">
                <Button
                  variant="outline"
                  size="icon"
                  class="h-7 w-7"
                  @click="decreaseQuantity(index)"
                >
                  <Minus class="w-3 h-3" />
                </Button>
                <span class="w-8 text-center font-medium text-sm">{{ item.quantity }}</span>
                <Button
                  variant="outline"
                  size="icon"
                  class="h-7 w-7"
                  @click="increaseQuantity(index)"
                >
                  <Plus class="w-3 h-3" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  class="h-7 w-7 text-destructive"
                  @click="removeFromCart(index)"
                >
                  <X class="w-3 h-3" />
                </Button>
              </div>
            </div>
          </div>

          <div v-else class="flex-1 flex flex-col items-center justify-center text-center py-12">
            <ShoppingCart class="w-16 h-16 text-muted-foreground opacity-30 mb-3" />
            <p class="text-sm text-muted-foreground">Cart is empty</p>
            <p class="text-xs text-muted-foreground mt-1">Add products to start a sale</p>
          </div>
        </CardContent>
      </Card>

      <!-- Checkout Section -->
      <Card v-if="cart.length > 0">
        <CardContent class="p-4 space-y-4">
          <!-- Totals -->
          <div class="space-y-2">
            <div class="flex justify-between text-sm">
              <span class="text-muted-foreground">Subtotal</span>
              <span class="font-medium">{{ formatCurrency(subtotal) }}</span>
            </div>
            
            <div class="flex justify-between text-sm">
              <span class="text-muted-foreground">Tax ({{ settings.taxRate }}%)</span>
              <span class="font-medium">{{ formatCurrency(tax) }}</span>
            </div>
            
            <div class="flex justify-between text-lg font-bold pt-2 border-t">
              <span>Total</span>
              <span class="text-primary">{{ formatCurrency(total) }}</span>
            </div>
          </div>

          <!-- Payment Method (Square-style) -->
          <div class="space-y-2">
            <Label class="text-xs text-muted-foreground uppercase tracking-wide">Payment Method</Label>
            <div class="grid grid-cols-3 gap-2">
              <Button
                v-for="method in paymentMethods"
                :key="method.value"
                :variant="paymentMethod === method.value ? 'default' : 'outline'"
                class="flex flex-col items-center gap-1 h-auto py-3"
                @click="paymentMethod = method.value"
              >
                <component :is="method.icon" class="w-5 h-5" />
                <span class="text-xs">{{ method.label }}</span>
              </Button>
            </div>
          </div>

          <!-- Square Integration Section -->
          <div v-if="paymentMethod === 'card'" class="p-3 rounded-lg bg-blue-500/5 border border-blue-500/20">
            <div class="flex items-start gap-2">
              <CreditCard class="w-5 h-5 text-blue-500 mt-0.5" />
              <div class="flex-1">
                <p class="text-sm font-medium text-blue-500">Square Terminal Ready</p>
                <p class="text-xs text-blue-500/70 mt-1">Tap "Charge Card" to process payment</p>
              </div>
            </div>
          </div>

          <!-- Customer Selection -->
          <div class="space-y-2">
            <Label for="customer" class="text-xs text-muted-foreground uppercase tracking-wide">Customer (Optional)</Label>
            <Select v-model="selectedCustomer">
              <SelectTrigger id="customer">
                <SelectValue placeholder="Walk-in Customer" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem :value="null">Walk-in Customer</SelectItem>
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

          <!-- Charge Button (Square-inspired) -->
          <Button
            class="w-full h-14 text-lg font-semibold"
            size="lg"
            @click="checkout"
          >
            <component :is="paymentMethod === 'card' ? CreditCard : paymentMethod === 'cash' ? Banknote : DollarSign" class="w-5 h-5 mr-2" />
            {{ paymentMethod === 'card' ? 'Charge Card' : paymentMethod === 'cash' ? 'Cash Payment' : 'Complete Sale' }}
            <span class="ml-2">·</span>
            <span class="ml-2">{{ formatCurrency(total) }}</span>
          </Button>
        </CardContent>
      </Card>

      <!-- Quick Sale Card -->
      <Card>
        <CardHeader class="pb-3">
          <CardTitle class="text-sm">Quick Sale</CardTitle>
        </CardHeader>
        <CardContent class="space-y-2">
          <Input
            v-model="quickSaleDescription"
            placeholder="Description"
            class="h-9 text-sm"
          />
          <Input
            v-model.number="quickSaleAmount"
            type="number"
            placeholder="Amount"
            class="h-9 text-sm"
            step="0.01"
          />
          <Button
            variant="secondary"
            class="w-full"
            size="sm"
            @click="addQuickSale"
          >
            <Plus class="w-4 h-4 mr-1" />
            Add Quick Sale
          </Button>
        </CardContent>
      </Card>
    </div>
  </div>

  <!-- Recent Sales (Below) -->
  <Card class="mt-6">
    <CardHeader>
      <CardTitle>Recent Transactions</CardTitle>
    </CardHeader>
    <CardContent class="p-0">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Description</TableHead>
            <TableHead>Amount</TableHead>
            <TableHead>Payment</TableHead>
            <TableHead>Date</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="sale in recentSales" :key="sale.id">
            <TableCell>
              <span class="text-sm">{{ sale.description }}</span>
            </TableCell>

            <TableCell>
              <span class="text-emerald-500 font-medium">{{ formatCurrency(sale.amount) }}</span>
            </TableCell>

            <TableCell>
              <Badge variant="secondary" class="text-xs">
                {{ sale.paymentMethod }}
              </Badge>
            </TableCell>

            <TableCell>
              <span class="text-xs text-muted-foreground">{{ formatDateTime(sale.date) }}</span>
            </TableCell>
          </TableRow>

          <TableRow v-if="recentSales.length === 0">
            <TableCell colspan="4" class="h-24 text-center">
              <div class="flex flex-col items-center justify-center py-8">
                <Receipt class="w-12 h-12 text-muted-foreground opacity-50 mb-2" />
                <p class="text-muted-foreground">No recent transactions</p>
              </div>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import type { QuickSale } from '~/types'
import { 
  Search, 
  Package, 
  ShoppingCart, 
  Minus, 
  Plus, 
  X,
  Trash2,
  CreditCard,
  Banknote,
  DollarSign,
  Receipt
} from 'lucide-vue-next'
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
import { Label } from '~/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '~/components/ui/select'
import { Badge } from '~/components/ui/badge'
import { Table, TableHeader, TableBody, TableHead, TableRow, TableCell } from '~/components/ui/table'

definePageMeta({
  middleware: ['auth']
})

const appStore = useAppStore()
const { inventory, customers, quickSales, settings, saveAll, trackRevenue } = appStore

const searchQuery = ref('')
const selectedCategory = ref<string | null>(null)
const cart = ref<Array<{ id: number; name: string; sku: string; price: number; quantity: number; stock: number }>>([])
const paymentMethod = ref('card')
const selectedCustomer = ref<number | null>(null)
const quickSaleDescription = ref('')
const quickSaleAmount = ref(0)

const paymentMethods = [
  { label: 'Card', value: 'card', icon: CreditCard },
  { label: 'Cash', value: 'cash', icon: Banknote },
  { label: 'Other', value: 'other', icon: DollarSign }
]

const filteredProducts = computed(() => {
  return inventory.value.filter(item => {
    const query = searchQuery.value.toLowerCase()
    const matchesSearch = item.name.toLowerCase().includes(query) || item.sku.toLowerCase().includes(query)
    
    let matchesCategory = true
    if (selectedCategory.value) {
      matchesCategory = item.name.toLowerCase().includes(selectedCategory.value)
    }
    
    return matchesSearch && matchesCategory
  })
})

const subtotal = computed(() => {
  return cart.value.reduce((sum, item) => sum + (item.price * item.quantity), 0)
})

const tax = computed(() => {
  return subtotal.value * (settings.value.taxRate / 100)
})

const total = computed(() => {
  return subtotal.value + tax.value
})

const recentSales = computed(() => {
  return [...quickSales.value]
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
    .slice(0, 10)
})

const formatCurrency = (amount: number) => {
  return `${settings.value.currency}${amount.toFixed(2)}`
}

const formatDateTime = (dateStr: string) => {
  return new Date(dateStr).toLocaleString()
}

const addToCart = (item: any) => {
  if (item.stock <= 0) {
    alert(`${item.name} is out of stock`)
    return
  }

  const existing = cart.value.find(i => i.id === item.id)
  if (existing) {
    if (existing.quantity < item.stock) {
      existing.quantity++
    } else {
      alert(`Only ${item.stock} available`)
    }
  } else {
    cart.value.push({
      id: item.id,
      name: item.name,
      sku: item.sku,
      price: item.price,
      quantity: 1,
      stock: item.stock
    })
  }
}

const removeFromCart = (index: number) => {
  cart.value.splice(index, 1)
}

const increaseQuantity = (index: number) => {
  const item = cart.value[index]
  if (item.quantity < item.stock) {
    item.quantity++
  } else {
    alert(`Only ${item.stock} available`)
  }
}

const decreaseQuantity = (index: number) => {
  const item = cart.value[index]
  if (item.quantity > 1) {
    item.quantity--
  } else {
    removeFromCart(index)
  }
}

const clearCart = () => {
  if (confirm('Clear cart?')) {
    cart.value = []
  }
}

const checkout = () => {
  if (cart.value.length === 0) return

  // Simulate Square integration for card payments
  if (paymentMethod.value === 'card') {
    // In production, this would integrate with Square Web Payments SDK
    if (!confirm(`Process card payment of ${formatCurrency(total.value)} via Square Terminal?`)) {
      return
    }
  }

  // Update inventory
  cart.value.forEach(cartItem => {
    const invItem = inventory.value.find(i => i.id === cartItem.id)
    if (invItem) {
      invItem.stock -= cartItem.quantity
    }
  })

  // Create sale record
  const sale: QuickSale = {
    id: Date.now().toString(),
    description: cart.value.map(i => `${i.name} (x${i.quantity})`).join(', '),
    amount: total.value,
    date: new Date().toISOString(),
    paymentMethod: paymentMethod.value
  }

  quickSales.value.push(sale)
  trackRevenue(total.value)
  saveAll()

  alert(`Sale completed! Total: ${formatCurrency(total.value)}`)

  // Reset
  cart.value = []
  paymentMethod.value = 'card'
  selectedCustomer.value = null
}

const addQuickSale = () => {
  if (!quickSaleDescription.value || quickSaleAmount.value <= 0) {
    alert('Please enter description and amount')
    return
  }

  const sale: QuickSale = {
    id: Date.now().toString(),
    description: quickSaleDescription.value,
    amount: quickSaleAmount.value,
    date: new Date().toISOString(),
    paymentMethod: 'cash'
  }

  quickSales.value.push(sale)
  trackRevenue(quickSaleAmount.value)
  saveAll()

  quickSaleDescription.value = ''
  quickSaleAmount.value = 0
}
</script>
