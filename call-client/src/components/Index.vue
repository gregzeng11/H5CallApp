<template>
  <div></div>
</template>

<script>
import { checkBrowser } from '../protocolCheck'

export default {
  name: 'Index',
  mounted() {
     console.log('Index hash params:', window.location.hash)
     if (window.location.search){
       let u = new URL(window.location.href);
       console.log('Index search params:', window.location.search)
       let search = window.location.search
       u.hash = '#/' + search
       u.search = '';
       console.log(u.href)
       window.location.replace(u.href);
       return
     }  

     let urlParams = window.location.search.substr(1) || window.location.hash.split("?")[1];
     let search = urlParams.split('&');
      console.log('Index params:', urlParams);
      var saveToken =false;
     if (isWeixin() || isQQ() || isWxWork() || isDingTalk()) {
        saveToken = true;
      }
      console.log("Index saveToken",saveToken);

      let paramsMap = {};
      for (let item of search) {
        let temp = item.split('=')
        if(temp[0]!='token' || saveToken){
         paramsMap[temp[0]] = temp[1]
        }else{
            localStorage.setItem('call_token', temp[1]);
        };
      }
     this.$router.replace({
       path: '/home',
       query: paramsMap,
     })
  }
}
</script>
