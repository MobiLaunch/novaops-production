<template>
  <Card class="w-full max-w-md">
    <CardHeader>
      <CardTitle class="text-3xl text-center">NovaOps</CardTitle>
      <p class="text-center text-muted-foreground">Repair Shop Management System</p>
    </CardHeader>
    
    <CardContent class="space-y-4">
      <div class="space-y-2">
        <label for="email" class="text-sm font-medium">Email</label>
        <Input 
          id="email" 
          v-model="email" 
          type="email" 
          placeholder="Enter your email"
          @keyup.enter="handleLogin"
        />
      </div>
      
      <div class="space-y-2">
        <label for="password" class="text-sm font-medium">Password</label>
        <Input 
          id="password" 
          v-model="password" 
          type="password" 
          placeholder="Enter your password"
          @keyup.enter="handleLogin"
        />
      </div>

      <Button 
        class="w-full" 
        size="lg"
        @click="handleLogin"
      >
        Sign In
      </Button>

      <p class="text-xs text-center text-muted-foreground">
        Demo: Use any email/password to login
      </p>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardContent } from '~/components/ui/card'
import { Input } from '~/components/ui/input'
import { Button } from '~/components/ui/button'

definePageMeta({
  layout: 'auth'
})

const email = ref('demo@novaops.com')
const password = ref('demo')

const handleLogin = () => {
  if (email.value && password.value) {
    // Set auth in localStorage
    if (process.client) {
      localStorage.setItem('isAuthenticated', 'true')
      // Force navigation
      window.location.href = '/dashboard'
    }
  } else {
    alert('Please enter email and password')
  }
}
</script>
