# NovaOps - shadcn/ui Migration

## 🎨 Theme Configuration

This project uses the **Nova theme** from shadcn/ui with the following settings:
- **Style:** Nova
- **Base Color:** Zinc
- **Theme:** Zinc
- **Font:** Outfit
- **Icon Library:** Lucide
- **Menu Color:** Inverted
- **Menu Accent:** Subtle
- **Radius:** Default

## 📦 Installation

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build
```

## 🔄 Migration Overview

### From Nuxt UI → shadcn/ui

| Component | Nuxt UI | shadcn/ui |
|-----------|---------|-----------|
| Cards | `<UCard>` | `<Card>`, `<CardHeader>`, `<CardContent>` |
| Buttons | `<UButton>` | `<Button>` |
| Inputs | `<UInput>` | `<Input>` |
| Icons | `<UIcon name="i-heroicons-*">` | `<ComponentName>` from lucide-vue-next |
| Modals | `<UModal>` | `<Dialog>`, `<Sheet>`, or `<Drawer>` |
| Forms | `<UFormGroup>` | `<Label>` + shadcn components |
| Select | `<USelectMenu>` | `<Select>` |
| Textarea | `<UTextarea>` | `<Textarea>` |

### Icon Migration

All Heroicons have been replaced with Lucide icons:

```vue
<!-- Old (Nuxt UI) -->
<UIcon name="i-heroicons-wrench-screwdriver" />

<!-- New (shadcn/ui) -->
<Wrench class="w-6 h-6" />
```

Common icon mappings:
- `i-heroicons-banknotes` → `Banknotes`
- `i-heroicons-ticket` → `Ticket`
- `i-heroicons-users` → `Users`
- `i-heroicons-wrench-screwdriver` → `Wrench`
- `i-heroicons-shopping-cart` → `ShoppingCart`
- `i-heroicons-calendar` → `Calendar`

## 🎯 Key Features

### Nova Theme Styling
- Deep dark backgrounds with zinc-based color palette
- Subtle border styling with proper contrast
- Outfit font family throughout
- Smooth transitions and hover states
- Professional POS-style cards

### Component Architecture
All components follow shadcn/ui's composition pattern:
- Radix Vue primitives for accessibility
- CVA (class-variance-authority) for variants
- Tailwind CSS for styling
- Full TypeScript support

## 📁 Project Structure

```
novaops-shadcn/
├── assets/
│   └── css/
│       └── main.css              # Nova theme CSS variables
├── components/
│   └── ui/                       # shadcn/ui components
│       ├── button/
│       ├── card/
│       ├── input/
│       └── ...
├── composables/
│   ├── useAppStore.ts            # Application state
│   └── useWeather.ts             # Weather integration
├── layouts/
│   ├── default.vue               # Main app layout with sidebar
│   └── auth.vue                  # Authentication layout
├── lib/
│   └── utils.ts                  # cn() utility for class merging
├── middleware/
│   └── auth.ts                   # Route protection
├── pages/
│   ├── dashboard.vue             # Main dashboard (migrated)
│   ├── login.vue                 # Login page
│   └── index.vue                 # Root redirect
├── types/
│   └── index.ts                  # TypeScript definitions
├── components.json               # shadcn/ui configuration
├── nuxt.config.ts                # Nuxt configuration
├── package.json                  # Dependencies
├── tailwind.config.js            # Tailwind + Nova theme
└── tsconfig.json                 # TypeScript config
```

## 🔧 Configuration Files

### `components.json`
shadcn/ui configuration with Nova theme settings and path aliases.

### `tailwind.config.js`
Extended Tailwind configuration with:
- Nova theme colors using CSS variables
- Outfit font family
- Custom animations
- shadcn/ui plugin

### `assets/css/main.css`
CSS variables for light and dark modes following Nova theme specification.

## 🚀 Next Steps

### Remaining Pages to Migrate

The following pages still need migration from Nuxt UI to shadcn/ui:

1. **tickets.vue** - Ticket management
2. **customers.vue** - Customer database
3. **inventory.vue** - Inventory tracking
4. **calendar.vue** - Appointment scheduling
5. **pos.vue** - Point of sale
6. **reports.vue** - Analytics and reports

### Components to Create

Additional shadcn/ui components needed:

- `Dialog` - For modals
- `Select` - For dropdowns
- `Textarea` - For multiline inputs
- `Label` - For form labels
- `Badge` - For status indicators
- `Table` - For data tables
- `Tabs` - For tabbed interfaces
- `Drawer` - For mobile-friendly panels
- `DropdownMenu` - For action menus
- `Calendar` - For date selection
- `Avatar` - For user profiles
- `Toast/Sonner` - For notifications

### Migration Pattern

For each page, follow this pattern:

1. **Import shadcn components:**
```vue
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'
import { Button } from '~/components/ui/button'
import { Input } from '~/components/ui/input'
```

2. **Import Lucide icons:**
```vue
import { Users, Package, Calendar } from 'lucide-vue-next'
```

3. **Replace Nuxt UI components:**
```vue
<!-- Old -->
<UCard>
  <template #header>Title</template>
  Content
</UCard>

<!-- New -->
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>
    Content
  </CardContent>
</Card>
```

4. **Update styling classes:**
- Replace `text-gray-400` with `text-muted-foreground`
- Replace `text-white` with default (inherits foreground)
- Replace `bg-[#1a2332]` with `bg-card`
- Use theme-aware color variables

## 🎨 Styling Guidelines

### Using Theme Colors

```vue
<!-- Backgrounds -->
<div class="bg-background">       <!-- Main background -->
<div class="bg-card">             <!-- Card background -->
<div class="bg-muted">            <!-- Muted background -->

<!-- Text -->
<p class="text-foreground">       <!-- Primary text -->
<p class="text-muted-foreground"> <!-- Secondary text -->

<!-- Borders -->
<div class="border-border">       <!-- Standard border -->

<!-- Interactive -->
<button class="bg-primary text-primary-foreground">
```

### Custom Classes

The project retains these custom utility classes:

```css
.pos-card          /* POS-style card with border */
.pos-card-hover    /* Hover effects for cards */
.stat-card         /* Gradient stat cards */
.glass-effect      /* Glassmorphism effect */
```

## 🔐 Authentication

The app uses localStorage for demo authentication:
- Default credentials: any email/password
- Protected routes use the `auth` middleware
- Login redirects to `/dashboard`

## 📊 State Management

The application uses Nuxt composables for state:
- `useAppStore()` - Main application state
- `useWeather()` - Weather API integration

All state persists to localStorage.

## 🌐 API Integration

Weather API example in `composables/useWeather.ts` shows how to integrate external APIs while maintaining the Nova theme styling.

## 💡 Tips

1. **Always use the `cn()` utility** for combining classes:
```vue
<div :class="cn('base-class', props.class, conditional && 'extra-class')">
```

2. **Leverage Radix Vue primitives** for complex components
3. **Use Lucide icons** consistently - they're tree-shakeable
4. **Follow the dark mode color scheme** - Nova theme is optimized for dark UIs
5. **Test on mobile** - responsive design is built-in

## 📚 Resources

- [shadcn/ui Documentation](https://ui.shadcn.com)
- [Radix Vue](https://www.radix-vue.com)
- [Lucide Icons](https://lucide.dev)
- [Tailwind CSS](https://tailwindcss.com)
- [Nuxt 3](https://nuxt.com)

## 🐛 Troubleshooting

### Icons not showing
Make sure to import from `lucide-vue-next`:
```vue
import { IconName } from 'lucide-vue-next'
```

### Styles not applying
Ensure dark mode is enabled in `nuxt.config.ts`:
```ts
htmlAttrs: {
  class: 'dark'
}
```

### Components not found
Run postinstall to generate Nuxt types:
```bash
npm run postinstall
```

## 📝 License

Private - NovaOps Repair Shop Management System
