import Vue from 'vue'
import Router from 'vue-router'
import HelloWorld from '@/components/HelloWorld'
import CallClient from '@/components/CallClient'
import Index from '@/components/Index'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Index',
      component: Index
    },
    {
      path: '/home',
      name: 'CallClient',
      component: CallClient
    },
    {
      path: '/a',
      name: 'HelloWorld',
      component: HelloWorld
    },
  ]
})
