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
            <NotificationsPanel />
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
import NotificationsPanel from "~/components/NotificationsPanel.vue"

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

const accountName = ref('Demo User')
const accountInitials = ref('DU')

onMounted(() => {
  if (process.client) {
    const saved = localStorage.getItem('accountData')
    if (saved) {
      const data = JSON.parse(saved)
      accountName.value = data.name || 'Demo User'
      const parts = accountName.value.split(' ')
      if (parts.length === 1) {
        accountInitials.value = parts[0].charAt(0).toUpperCase()
      } else {
        accountInitials.value = (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
      }
    }
  }
})
