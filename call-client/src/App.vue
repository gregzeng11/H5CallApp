<template>
  <div id="app">
    <router-view/>
    <!-- <button @click="testClick">test</button> -->
  </div>
</template>

<script>
export default {
  name: 'App',
  methods: {
    testClick () {
      this.$router.push('/a')
    }
  }
}
</script>

<style scoped>
/* #app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
} */
</style>
