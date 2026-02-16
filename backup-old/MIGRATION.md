# Component Migration Guide - Nuxt UI to shadcn/ui

## Complete Component Mapping

### Basic Components

#### Button
```vue
<!-- OLD: Nuxt UI -->
<UButton color="primary" size="lg" @click="handler">
  Click me
</UButton>

<!-- NEW: shadcn/ui -->
<Button size="lg" @click="handler">
  Click me
</Button>

<!-- Available variants -->
<Button variant="default">Default</Button>
<Button variant="destructive">Delete</Button>
<Button variant="outline">Outline</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>

<!-- Available sizes -->
<Button size="xs">Extra Small</Button>
<Button size="sm">Small</Button>
<Button size="default">Default</Button>
<Button size="lg">Large</Button>
<Button size="xl">Extra Large</Button>
<Button size="icon">Icon Only</Button>
```

#### Card
```vue
<!-- OLD: Nuxt UI -->
<UCard>
  <template #header>
    <h3>Title</h3>
  </template>
  Content here
</UCard>

<!-- NEW: shadcn/ui -->
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>
    Content here
  </CardContent>
</Card>
```

#### Input
```vue
<!-- OLD: Nuxt UI -->
<UInput v-model="value" placeholder="Enter text" />

<!-- NEW: shadcn/ui -->
<Input v-model="value" placeholder="Enter text" />
```

#### Textarea
```vue
<!-- OLD: Nuxt UI -->
<UTextarea v-model="text" :rows="3" />

<!-- NEW: shadcn/ui -->
<Textarea v-model="text" :rows="3" />
```

### Form Components

#### Form Group → Label
```vue
<!-- OLD: Nuxt UI -->
<UFormGroup label="Email" required>
  <UInput v-model="email" />
</UFormGroup>

<!-- NEW: shadcn/ui -->
<div class="space-y-2">
  <Label for="email">Email *</Label>
  <Input id="email" v-model="email" />
</div>
```

#### Select Menu → Select
```vue
<!-- OLD: Nuxt UI -->
<USelectMenu
  v-model="selected"
  :options="options"
  placeholder="Select option"
/>

<!-- NEW: shadcn/ui -->
<Select v-model="selected">
  <SelectTrigger>
    <SelectValue placeholder="Select option" />
  </SelectTrigger>
  <SelectContent>
    <SelectItem 
      v-for="option in options" 
      :key="option.value"
      :value="option.value"
    >
      {{ option.label }}
    </SelectItem>
  </SelectContent>
</Select>
```

### Dialog/Modal Components

#### Modal → Dialog
```vue
<!-- OLD: Nuxt UI -->
<UModal v-model="isOpen" :ui="{ width: 'sm:max-w-2xl' }">
  <UCard>
    <template #header>
      <h3>Dialog Title</h3>
    </template>
    Content here
  </UCard>
</UModal>

<!-- NEW: shadcn/ui -->
<Dialog v-model:open="isOpen">
  <DialogContent class="sm:max-w-2xl">
    <DialogHeader>
      <DialogTitle>Dialog Title</DialogTitle>
    </DialogHeader>
    <div class="py-4">
      Content here
    </div>
  </DialogContent>
</Dialog>
```

### Icon Migration

All icons now use Lucide instead of Heroicons:

```vue
<!-- OLD: Nuxt UI -->
<UIcon name="i-heroicons-user" class="w-5 h-5" />
<UIcon name="i-heroicons-shopping-cart" class="w-5 h-5" />
<UIcon name="i-heroicons-cog" class="w-5 h-5" />

<!-- NEW: shadcn/ui -->
<script setup>
import { User, ShoppingCart, Settings } from 'lucide-vue-next'
</script>

<User class="w-5 h-5" />
<ShoppingCart class="w-5 h-5" />
<Settings class="w-5 h-5" />
```

#### Common Icon Mappings

| Heroicon (Nuxt UI) | Lucide (shadcn/ui) |
|--------------------|--------------------|
| `i-heroicons-user` | `User` |
| `i-heroicons-users` | `Users` |
| `i-heroicons-cog` | `Settings` |
| `i-heroicons-bell` | `Bell` |
| `i-heroicons-home` | `Home` |
| `i-heroicons-ticket` | `Ticket` |
| `i-heroicons-calendar` | `Calendar` |
| `i-heroicons-shopping-cart` | `ShoppingCart` |
| `i-heroicons-wrench-screwdriver` | `Wrench` |
| `i-heroicons-cube` | `Package` |
| `i-heroicons-banknotes` | `Banknotes` |
| `i-heroicons-chart-bar` | `BarChart` |
| `i-heroicons-currency-dollar` | `DollarSign` |
| `i-heroicons-arrow-trending-up` | `TrendingUp` |
| `i-heroicons-clipboard-document-check` | `ClipboardCheck` |
| `i-heroicons-user-plus` | `UserPlus` |
| `i-heroicons-sun` | `Sun` |
| `i-heroicons-cloud` | `Cloud` |
| `i-heroicons-exclamation-triangle` | `AlertTriangle` |
| `i-heroicons-check-circle` | `CheckCircle` |
| `i-heroicons-x-mark` | `X` |
| `i-heroicons-chevron-down` | `ChevronDown` |
| `i-heroicons-chevron-right` | `ChevronRight` |

## Color System Migration

### From Nuxt UI Classes → shadcn/ui Theme Variables

```vue
<!-- OLD: Nuxt UI -->
<div class="bg-gray-900 text-white">
<p class="text-gray-400">Muted text</p>
<div class="bg-emerald-500">Success</div>
<div class="border-gray-700">Bordered</div>

<!-- NEW: shadcn/ui -->
<div class="bg-background text-foreground">
<p class="text-muted-foreground">Muted text</p>
<div class="bg-emerald-500">Success (can keep color)</div>
<div class="border-border">Bordered</div>
```

### Theme Color Variables

| Purpose | CSS Variable | Usage |
|---------|--------------|-------|
| Main background | `bg-background` | Page/app background |
| Card background | `bg-card` | Cards, panels |
| Muted background | `bg-muted` | Subtle backgrounds |
| Accent background | `bg-accent` | Hover states |
| Primary text | `text-foreground` | Main text |
| Secondary text | `text-muted-foreground` | Labels, captions |
| Borders | `border-border` | All borders |
| Primary action | `bg-primary text-primary-foreground` | Buttons, CTAs |

### Status Colors

You can still use Tailwind's color palette for status indicators:

```vue
<!-- Success -->
<div class="bg-emerald-500/10 text-emerald-500">Success</div>

<!-- Warning -->
<div class="bg-amber-500/10 text-amber-500">Warning</div>

<!-- Error -->
<div class="bg-red-500/10 text-red-500">Error</div>

<!-- Info -->
<div class="bg-blue-500/10 text-blue-500">Info</div>
```

## Custom Class Utilities

The project maintains these custom utility classes:

```css
/* POS-style cards */
.pos-card {
  @apply bg-card border border-border rounded-xl shadow-sm;
}

.pos-card-hover {
  @apply hover:border-primary/50 transition-all duration-200;
}

/* Stat cards with gradient */
.stat-card {
  @apply bg-gradient-to-br from-card to-muted/30 border border-border rounded-xl p-6 shadow-sm;
}

/* Glass effect */
.glass-effect {
  @apply bg-background/80 backdrop-blur-xl border border-border/50;
}
```

## Import Patterns

### Before (Nuxt UI)
```vue
<script setup lang="ts">
// No imports needed - auto-imported by @nuxt/ui
</script>
```

### After (shadcn/ui)
```vue
<script setup lang="ts">
// Import components explicitly
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
import { Users, Package } from 'lucide-vue-next'
</script>
```

## Spacing and Layout

shadcn/ui uses Tailwind's default spacing. Common patterns:

```vue
<!-- Form spacing -->
<div class="space-y-4">
  <div class="space-y-2">
    <Label>Field 1</Label>
    <Input />
  </div>
  <div class="space-y-2">
    <Label>Field 2</Label>
    <Input />
  </div>
</div>

<!-- Card spacing -->
<Card>
  <CardHeader class="pb-3">
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent class="space-y-4">
    Content with spacing
  </CardContent>
</Card>

<!-- Button groups -->
<div class="flex gap-3">
  <Button variant="outline">Cancel</Button>
  <Button>Confirm</Button>
</div>
```

## Responsive Design

shadcn/ui follows mobile-first design:

```vue
<!-- Mobile: stacked, Desktop: 3 columns -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  <!-- Cards -->
</div>

<!-- Mobile: full width, Desktop: max width -->
<DialogContent class="sm:max-w-2xl">
  <!-- Content -->
</DialogContent>

<!-- Responsive padding -->
<div class="p-4 sm:p-6 lg:p-8">
  <!-- Content -->
</div>
```

## Best Practices

1. **Always use the `cn()` utility** when combining classes:
```vue
<div :class="cn('base-classes', props.class, isActive && 'active-classes')">
```

2. **Use semantic color variables** instead of hardcoded colors:
```vue
<!-- Good -->
<div class="bg-card text-foreground border-border">

<!-- Avoid -->
<div class="bg-gray-900 text-white border-gray-700">
```

3. **Import icons at the top** for better tree-shaking:
```vue
<script setup lang="ts">
import { User, Settings, Bell } from 'lucide-vue-next'
</script>
```

4. **Group related form fields** with consistent spacing:
```vue
<div class="space-y-2">
  <Label for="field">Label</Label>
  <Input id="field" />
  <p class="text-xs text-muted-foreground">Helper text</p>
</div>
```

5. **Use proper dialog structure**:
```vue
<Dialog v-model:open="isOpen">
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Title</DialogTitle>
    </DialogHeader>
    <div class="space-y-4 py-4">
      <!-- Form fields -->
    </div>
    <div class="flex gap-3">
      <Button variant="outline">Cancel</Button>
      <Button>Submit</Button>
    </div>
  </DialogContent>
</Dialog>
```

## Migration Checklist

For each page/component:

- [ ] Replace `<UCard>` with `<Card>` + subcomponents
- [ ] Replace `<UButton>` with `<Button>`
- [ ] Replace `<UInput>` with `<Input>`
- [ ] Replace `<UTextarea>` with `<Textarea>`
- [ ] Replace `<UModal>` with `<Dialog>`
- [ ] Replace `<USelectMenu>` with `<Select>`
- [ ] Replace `<UFormGroup>` with `<Label>` + component
- [ ] Replace `<UIcon>` with Lucide components
- [ ] Update color classes to theme variables
- [ ] Add component imports at top of script
- [ ] Test responsive behavior
- [ ] Verify dark mode styling
