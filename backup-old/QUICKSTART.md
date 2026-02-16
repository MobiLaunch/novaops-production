# Quick Start Guide

## 🚀 Getting Started

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

Visit `http://localhost:3000` to see your app!

### Default Login

The app uses demo authentication:
- **Email:** Any email
- **Password:** Any password

Just enter any credentials to access the dashboard.

## 📂 Project Structure

```
novaops-shadcn/
├── components/
│   └── ui/              # shadcn/ui components
│       ├── button/
│       ├── card/
│       ├── input/
│       ├── dialog/
│       ├── select/
│       ├── textarea/
│       ├── label/
│       └── badge/
├── pages/
│   ├── dashboard.vue    # ✅ Fully migrated
│   ├── login.vue        # ✅ Fully migrated
│   ├── tickets.vue      # ⏳ Needs migration
│   ├── customers.vue    # ⏳ Needs migration
│   ├── inventory.vue    # ⏳ Needs migration
│   ├── calendar.vue     # ⏳ Needs migration
│   ├── pos.vue          # ⏳ Needs migration
│   └── reports.vue      # ⏳ Needs migration
├── layouts/
│   ├── default.vue      # Main layout with sidebar
│   └── auth.vue         # Login layout
├── composables/
│   ├── useAppStore.ts   # App state management
│   └── useWeather.ts    # Weather API
├── lib/
│   └── utils.ts         # cn() utility
└── assets/css/
    └── main.css         # Nova theme styles
```

## 🎨 Nova Theme

This project uses the **Nova theme** from shadcn/ui:

- **Dark Mode First** - Optimized for dark backgrounds
- **Outfit Font** - Modern, clean typography
- **Zinc Color Palette** - Professional grey-scale
- **Lucide Icons** - Consistent iconography
- **Inverted Menu** - High contrast sidebar

### Theme Colors

The app uses CSS variables for theming:

```vue
<div class="bg-background">        <!-- Main background -->
<div class="bg-card">              <!-- Card background -->
<div class="bg-muted">             <!-- Subtle background -->
<p class="text-foreground">        <!-- Primary text -->
<p class="text-muted-foreground">  <!-- Secondary text -->
<div class="border-border">        <!-- Borders -->
```

## 🛠️ Adding a New Component

### 1. Install via CLI (Recommended)

If you have the shadcn CLI:

```bash
npx shadcn-vue@latest add [component-name]
```

### 2. Manual Installation

Create the component in `components/ui/[component-name]/`:

```vue
<!-- components/ui/my-component/MyComponent.vue -->
<script setup lang="ts">
import { cn } from '~/lib/utils'

const props = defineProps<{
  variant?: 'default' | 'outline'
  class?: string
}>()
</script>

<template>
  <div :class="cn('base-styles', props.class)">
    <slot />
  </div>
</template>
```

Export it:

```ts
// components/ui/my-component/index.ts
export { default as MyComponent } from './MyComponent.vue'
```

## 📝 Creating a New Page

### 1. Create the Page File

```bash
touch pages/my-page.vue
```

### 2. Add the Page Template

```vue
<template>
  <div class="space-y-6">
    <Card>
      <CardHeader>
        <CardTitle>My Page</CardTitle>
      </CardHeader>
      <CardContent>
        Content here
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'

definePageMeta({
  middleware: ['auth'] // Protect with auth
})
</script>
```

### 3. Add to Navigation

Edit `layouts/default.vue`:

```ts
const navigation = [
  // ... existing items
  { name: 'My Page', path: '/my-page', icon: YourIcon },
]
```

## 🎯 Common Patterns

### Creating a Form

```vue
<template>
  <div class="space-y-4">
    <div class="space-y-2">
      <Label for="name">Name</Label>
      <Input id="name" v-model="form.name" />
    </div>
    
    <div class="space-y-2">
      <Label for="email">Email</Label>
      <Input id="email" type="email" v-model="form.email" />
    </div>
    
    <Button @click="handleSubmit">Submit</Button>
  </div>
</template>

<script setup lang="ts">
import { Input } from '~/components/ui/input'
import { Label } from '~/components/ui/label'
import { Button } from '~/components/ui/button'

const form = ref({
  name: '',
  email: ''
})

const handleSubmit = () => {
  // Handle form submission
}
</script>
```

### Creating a Modal

```vue
<template>
  <div>
    <Button @click="isOpen = true">Open Dialog</Button>
    
    <Dialog v-model:open="isOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Dialog Title</DialogTitle>
        </DialogHeader>
        
        <div class="py-4">
          Content here
        </div>
        
        <div class="flex gap-3">
          <Button variant="outline" @click="isOpen = false">
            Cancel
          </Button>
          <Button @click="handleConfirm">
            Confirm
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '~/components/ui/dialog'
import { Button } from '~/components/ui/button'

const isOpen = ref(false)

const handleConfirm = () => {
  // Handle confirmation
  isOpen.value = false
}
</script>
```

### Using Icons

```vue
<template>
  <div class="flex items-center gap-2">
    <User class="w-5 h-5" />
    <span>Profile</span>
  </div>
</template>

<script setup lang="ts">
import { User } from 'lucide-vue-next'
</script>
```

### Creating Status Badges

```vue
<template>
  <div class="flex gap-2">
    <span class="px-2 py-1 rounded text-xs font-medium bg-emerald-500/10 text-emerald-500">
      Active
    </span>
    <span class="px-2 py-1 rounded text-xs font-medium bg-amber-500/10 text-amber-500">
      Pending
    </span>
    <span class="px-2 py-1 rounded text-xs font-medium bg-red-500/10 text-red-500">
      Inactive
    </span>
  </div>
</template>
```

## 🔍 Debugging Tips

### Check if Dark Mode is Active

```vue
<script setup lang="ts">
onMounted(() => {
  console.log('Dark mode:', document.documentElement.classList.contains('dark'))
})
</script>
```

### Verify Component Imports

```vue
<script setup lang="ts">
import { Button } from '~/components/ui/button'
console.log('Button component:', Button)
</script>
```

### Tailwind CSS Not Working?

1. Check `tailwind.config.js` content paths
2. Ensure `@tailwindcss` is in `nuxt.config.ts` modules
3. Restart dev server after config changes

## 📚 Next Steps

1. **Migrate Remaining Pages** - See `MIGRATION.md` for component mapping
2. **Add More Components** - Install additional shadcn components as needed
3. **Customize Theme** - Modify `assets/css/main.css` for custom colors
4. **Add Features** - Build on the existing foundation

## 🐛 Common Issues

### Icons Not Showing

Make sure to import from `lucide-vue-next`:

```vue
import { IconName } from 'lucide-vue-next'
```

### Styles Not Applying

Ensure dark mode class is set in `nuxt.config.ts`:

```ts
app: {
  head: {
    htmlAttrs: {
      class: 'dark'
    }
  }
}
```

### Dialog Not Closing

Use `v-model:open` (not just `v-model`):

```vue
<Dialog v-model:open="isOpen">
```

### Select Not Working

Make sure to use all required components:

```vue
<Select v-model="value">
  <SelectTrigger>
    <SelectValue />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="1">Option 1</SelectItem>
  </SelectContent>
</Select>
```

## 📖 Resources

- [shadcn/ui Docs](https://ui.shadcn.com)
- [Radix Vue Docs](https://www.radix-vue.com)
- [Lucide Icons](https://lucide.dev)
- [Tailwind CSS Docs](https://tailwindcss.com)
- [Nuxt 3 Docs](https://nuxt.com)

## 💡 Pro Tips

1. Use the `cn()` utility for conditional classes
2. Leverage the theme color variables for consistency
3. Keep components small and focused
4. Use Radix Vue primitives for complex interactions
5. Test on mobile - the theme is fully responsive!

Happy coding! 🎉
