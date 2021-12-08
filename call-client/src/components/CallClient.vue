<template>
  <div id="app">
    <div
      class="detail-wrapper"
      :class="{ [env]: env }"
    >
      <!-- 基本信息 -->
      <div
        v-if="!isDownloadShow"
        class="detail-container"
      >
        <div class="detail-content">
          <div class="detail-body">
            <div class="detail-roomName">{{ classInfo.class_name }}</div>
            <div class="detail-teacherName">主讲：{{ classInfo.teacher_name }}</div>
            <div class="detail-duration">
              <div class="detail-duration_body">
                <div class="duration_timeBox">
                  <div class="time">{{ classInfo.start_time }}</div>
                  <div class="detailtime">{{ classInfo.start_date }}</div>
                </div>
                <div class="duration_countTime">
                  <div class="duration_time">
                    <div class="duration_txt">{{ classInfo.duration }}分钟</div>
                  </div>
                  <div class="duration_line"></div>
                </div>
                <div class="duration_timeBox">
                  <div class="time">{{ classInfo.end_time }}</div>
                  <div class="detailtime">{{ classInfo.end_date }}</div>
                </div>
              </div>
            </div>
          </div>
          <div class="detail-footer">
            <template v-if="classInfo.status === 2 || classInfo.status === 3">
              <div class="detail-operationBtn disabled">
                <div class="detail-operationBtn-text">{{ classInfo.class_status_desc }}</div>
              </div>
            </template>
            <template v-else>
              <div
                class="detail-operationBtn"
                @click="handleJoinRoom"
              >
                <div class="detail-operationBtn-text">加入课堂</div>
                <div class="detail-operationBtn-status">({{ classInfo.class_status_desc }})</div>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- 下载页面 -->
      <div
        v-if="isDownloadShow"
        class="detail-container"
      >
        <div class="download_content">
          <img
            class="download_logo"
            :src="schoolInfo.logo_url"
          />
          <div class="download_title">该页面会唤起{{ schoolInfo.name }}</div>
          <div class="download_lineTxt">若无法正常跳转请先点击<span>【立即下载】</span>按钮。</div>
          <div
            v-if="deviceType === 'ios' || deviceType === 'android'"
            class="download_lineTxt"
          >
            若您已经安装了{{ schoolInfo.name }}，请点击右上角，<br />用浏览器打开。</div>
          <div
            v-else
            class="download_lineTxt"
          >若您已经安装了{{ schoolInfo.name }}，请
            <span
              class="clickSpan"
              @click="handleJoinRoom"
            >点击此处</span><br />如果浏览器对话框弹出，<br />请点击【打开{{ schoolInfo.name }}】按钮
          </div>
          <div
            class="download_Btn"
            @click="handleDownload"
          >立即下载</div>
        </div>
      </div>

      <!-- 在微信环境内部引导打开浏览器 -->
      <div
        v-if="isBrowserMarkShow"
        class="browser_mark"
      >
        <div class="browser_content">
          <div class="browser_arrows">
            <img src="../assets/image/h5/arrowsImg.png" />
          </div>
          <div class="browser_text">点击“···”选择在浏览器打开</div>
          <div
            class="browser_know"
            @click="handleCloseMark"
          >
            <img src="../assets/image/h5/knowImg.png" />
          </div>
        </div>
      </div>

      <iframe
        v-show="false"
        :src="loadUrl"
      ></iframe>

    </div>
  </div>
</template>

<script>
import { checkBrowser } from '../protocolCheck'
import { LogReport } from '../log_report'
import CallApp from 'callapp-lib'
import defaultLogImg from '../assets/image/downloadLogo.png'

export default {
  name: 'CallClient',
  data() {
    return {
      env: 'test', // 是否是浏览器pc环境

      userid: '',
      token:
        '',
      classid: '',
      schoolid: '',
      urlParams: '',
      paramsMap: {},
      schoolInfo: {
        schoolid: '',
        name: '',
        logo_url: defaultLogImg,
        home_url: '',
        js_url: '',
        css_url: '',
      },

      classInfo: {
        class_name: '',
        start_time: '',
        start_date: '',
        end_time: '',
        end_date: '',
        teacher_id: '',
        teacher_name: '',
        class_status: '',
        class_status_desc: '',
        duration: 0,
      },

      isDownloadShow: false, // 下载页面是否显示
      isBrowserMarkShow: false, // 引导打开浏览器页面是否显示
      isTeacherOpen: false, // 是否是教师打开
      deviceType: '', // 设备信息,
      browser: '', // 什么浏览器
      loadUrl: '', // 加载url
      version: '1.5.0',
      callTimer: null,
      callId: '',
      startEnterClassTime: 0,
      needReport: false,

      android: {
        scheme:'tcicdemo',
        package: 'com.tencent.tcicopenappdemo',
        url: 'https://docs.qcloudclass.com/1.4.0/#/',
      },
      ios: {
        scheme:'tcicdemo',
        package: 'com.tencent.tcicopenappdemo',
        url: '',
      },
      windows: {
        scheme:'tcic',
        package: 'com.tencent.tcicopenappdemo',
        url: 'https://docs.qcloudclass.com/1.4.0/#/',
      },
      mac: {
        scheme:'tcic',
        package: 'com.tencent.tcicopenappdemo',
        url: 'https://docs.qcloudclass.com/1.4.0/#/',
      },
    }
  },
  computed: {
    pcJoinRoom: function () {
      // 跳转域名:tcic://class.qcloudclass.com,后面拼接客户端需要的参数。
      var tempScheme = this.mac.scheme;
      if(this.deviceType == 'windows'){
          tempScheme = this.windows.scheme;
      }
      return `${tempScheme}://class.qcloudclass.com/${this.version}/class.html?${this.urlParams}&callid=${this.callId}`
    },

    androidJoinRoom: function () {
          if (this.browser.isChrome || this.browser.isQQbrowser) {
            return `intent://?${this.urlParams}#Intent;scheme=${this.android.scheme};package=${this.android.package};end`;
          }else {
            return `${this.android.scheme}://?${this.urlParams}`;

          }
        },
  },

  created() {
    this.startEnterClassTime = new Date().getTime()
    this.callId = this.randomNum()
    this.deviceType = this.getOsName()
    this.parseUrlParams()
    this.getCallClientParam()
    this.getSchoolInfo()
    this.getClassInfo()
    this.getTeacherInfo()
    this.initLogConfig()

   
    this.callTimer = setInterval(() => {
      this.queryCallStatus()
    }, 2000)
  },

  beforeDestroy() {
    clearInterval(this.callTimer)
  },

  methods: {
    randomNum() {
      var res = ''
      for (var i = 0; i < 10; i++) {
        res += Math.floor(Math.random() * 10)
      }
      return res
    },

    initLogConfig() {
      LogReport.init()
      LogReport.setPlatform(this.getOsName())
      LogReport.setVersion(this.version)
      LogReport.setSdkAppId(this.schoolid)
      LogReport.setUserId(this.userid)
      LogReport.setClassId(this.classid)

     LogReport.report('parseUrlParams', this.urlParams, 0)
    },

    parseUrlParams() {
     this.urlParams = window.location.search.substr(1) || window.location.hash.split("?")[1];

     let search = this.urlParams.split('&')
      console.log('getUrlParams params:', this.urlParams)

      for (let item of search) {
        let temp = item.split('=')
        this.paramsMap[temp[0]] = temp[1]
      }

      let token =localStorage.getItem("call_token");
      if(token && !this.paramsMap['token']){
        this.paramsMap['token']= token;
        this.urlParams += '&token='+token;
      }
      

      this.schoolid = this.paramsMap.schoolid ? this.paramsMap.schoolid : ''
      this.classid = this.paramsMap.classid ? this.paramsMap.classid : ''
      this.userid = this.paramsMap.userid ? this.paramsMap.userid : ''
      this.token = this.paramsMap.token ? this.paramsMap.token : ''

      this.env = this.paramsMap.env ? this.paramsMap.env : ''
      console.log('getUrlParams userid:', this.paramsMap.userid)
    },

    handleJoinRoom() {
      LogReport.report('handleJoinRoom', 'deviceType: '+this.deviceType, 0)
      console.log('handleJoinRoom','deviceType: '+this.deviceType);
       this.needReport = true;
       this.browser = checkBrowser();

      if (isWeixin() || isQQ() || isWxWork() || isDingTalk()) {
        this.isBrowserMarkShow = true;
      } else {
        if (this.deviceType === 'ios') {
          this.openApp()
        } else if (this.deviceType === 'android') {
        //  this.isDownloadShow = true
          // if (this.browser.isChrome || this.browser.isQQbrowser) {
          //     const link = document.createElement('a');
          //     link.href = this.androidJoinRoom
          //     console.log("link.href: ",this.androidJoinRoom);
          //     link.click();
          //   }else{
          //     this.openApp();
          //   } 
          this.isDownloadShow = true;
          const link = document.createElement('a');
          link.href = this.androidJoinRoom
          console.log("link.href: ",this.androidJoinRoom);
          link.click();
        } else if (this.deviceType === 'windows' || this.deviceType === 'mac') {
          this.isDownloadShow = true;
          this.loadUrl = '';
          setTimeout(() => {
              this.loadUrl = this.pcJoinRoom;
              console.log('pcJoin 300 later url:', this.loadUrl)
           }, 300)
          
          console.log('pcJoin url:', this.loadUrl)
        }
      }
    },

    openApp() {
      var postPara = {
        schoolId: this.schoolid,
        classId: this.classid,
        userId: this.userid,
        token: this.token,
        env: this.env,
      }

      var callScheme = this.android.scheme;
      var callPackage = this.android.package;

      var yingyongbaoUrl = 'https://docs.qcloudclass.com/1.3.5/#/Preview'
      var fallbackUrl = 'http://www.tencent.com/zh-cn'

      if (this.deviceType === 'ios') {
        yingyongbaoUrl = 'https://docs.qcloudclass.com/1.3.5/#/Preview'
        fallbackUrl = 'https://docs.qcloudclass.com/1.3.5/#/Preview'

        callScheme = this.ios.scheme;
        callPackage = this.ios.package
      }
     
      const options = {
        scheme: { protocol: callScheme },
        intent: {
          package: callPackage, 
          scheme: callScheme, 
        },
        //apple store
        // appstore: 'https://itunes.apple.com/cn/app//id414478124?mt=8',
        //应用宝
        yinyongbao: yingyongbaoUrl,
        //唤端失败后跳转的地址
        fallback: fallbackUrl,
        timeout: 2000,
      }
      const callLib = new CallApp(options)
      callLib.open({
        path: '',
        param: this.paramsMap, //postPara,
        callback: () => {
          console.log('callLib i has error')
        },
      })
    },

    getBaseUrl(callStr) {
      var baseUrl = 'https://tcic-api.qcloudclass.com/';
      var url = baseUrl + callStr
      const requestData = {
        token: this.token,
      }
      let paramsArray = []
      //拼接参数
      Object.keys(requestData).forEach((key) =>
        paramsArray.push(key + '=' + requestData[key])
      )
      if (url.search(/\?/) === -1) {
        url += '?' + paramsArray.join('&')
      } else {
        url += '&' + paramsArray.join('&')
      }
      return url
    },

    getSchoolInfo() {
      let url = this.getBaseUrl('v1/school/getInfo')

      const requestBody = { scene: 'default' }
      fetch(url, {
        method: 'POST', // or 'PUT'
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      })
        .then((response) => response.json())
        .then((data) => {
            console.log('getSchoolInfo',data);
          if (data.error_code == 0) {
            this.schoolInfo.schoolid = data.school_id

            if(data.name && data.name.length!=0){
               this.schoolInfo.name = data.name;
            }
          
            let custom_content = data.custom_content
            if (
              custom_content.logo_url &&
              custom_content.logo_url.length != 0
            ) {
              this.schoolInfo.logo_url = custom_content.logo_url
            }

            this.schoolInfo.home_url = custom_content.home_url
            this.schoolInfo.js_url = custom_content.js_url
            this.schoolInfo.css_url = custom_content.css_url
           
          }
        })
        .catch((error) => {
          console.error('getSchoolInfo Error:', error);
          LogReport.report('getSchoolInfo', 'Exception: '+error, 0);

        })
    },

    getClassInfo() {
      let url = this.getBaseUrl('v1/class/getInfo')

      const requestBody = { class_id: this.classid }

      fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.error_code == 0) {
            console.log('getClassInfo Success:', data)
            var class_Info = data.class_info
            var classType = class_Info.class_type
            var startSecond = 0
            var endSecond = 0

            if (classType == 1) {
              var liveClassInfo = class_Info.live_class_info
              this.classInfo.class_name = liveClassInfo.name
              startSecond = liveClassInfo.start_time
              endSecond = liveClassInfo.end_time
              this.classInfo.teacher_id = liveClassInfo.teacher_id
              this.classInfo.class_status = liveClassInfo.status
            } else {
              var rtcClassInfo = class_Info.rtc_class_info
              this.classInfo.class_name = rtcClassInfo.name
              startSecond = rtcClassInfo.start_time
              endSecond = rtcClassInfo.end_time
              this.classInfo.teacher_id = rtcClassInfo.teacher_id
              this.classInfo.class_status = rtcClassInfo.status
            }

            if (startSecond > 0 && endSecond > 0) {
              var startDate = new Date(startSecond * 1000);
              var startMinute = startDate.getMinutes() < 10 ? '0'+startDate.getMinutes():startDate.getMinutes();
              var endDate = new Date(endSecond * 1000);
              var endMinute = endDate.getMinutes() < 10 ? '0'+endDate.getMinutes():endDate.getMinutes();

              this.classInfo.start_time =
                startDate.getHours() + ':' + startMinute;

              this.classInfo.start_date =
                startDate.getFullYear() +
                '年' +
                (startDate.getMonth() + 1) +
                '月' +
                startDate.getDate() +
                '日'

              this.classInfo.end_time =
                endDate.getHours() + ':' + endMinute;

              this.classInfo.end_date =
                endDate.getFullYear() +
                '年' +
                (endDate.getMonth() + 1) +
                '月' +
                endDate.getDate() +
                '日'

              this.classInfo.duration = (endSecond - startSecond) / 60
            }

            if (this.classInfo.class_status == 0) {
              this.classInfo.class_status_desc = '未开始'
            } else if (this.classInfo.class_status == 1) {
              this.classInfo.class_status_desc = '正在上课'
            } else if (this.classInfo.class_status == 2) {
              this.classInfo.class_status_desc = '已结束'
            } else {
              this.classInfo.class_status_desc = '已过期'
            }
          }
        })
        .catch((error) => {
          console.error('getClassInfo Error:', error)
          LogReport.report('getClassInfo', 'Exception: '+error, 0);
        })
    },

    getTeacherInfo() {
      let url = this.getBaseUrl('v1/user/list')

      const requestBody = { user_ids: [this.userid] }
      fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.error_code == 0) {
            console.log('getTeacherInfo Success:', data)
            var teacherInfo = data.users[0]
            this.classInfo.teacher_name = teacherInfo.nickname
          }
        })
        .catch((error) => {
          console.error('getTeacherInfo Error:', error);
          LogReport.report('getTeacherInfo', 'Exception: '+error, 0);
        })
    },

    getCallClientParam() {
     let url = this.getBaseUrl('v1/school/getCallClientParam');

     const requestBody = { school_id: this.schoolid };

     fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.error_code == 0) {
            console.log('getCallClientParam Success:', data)
            if(data.android!= null){
              this.android.scheme = data.android.scheme;
              this.android.package = data.android.package;
              if(data.android.url != null && data.android.url.length >0){
                  this.android.url = data.android.url;
              }
               console.log('getCallClientParam android:',  this.android.scheme, this.android.package)
            }
            if(data.ios != null){
              if(data.ios.scheme!=null && data.ios.scheme.length >0 ){
                  this.ios.scheme = data.ios.scheme;
              }
              this.ios.package = data.ios.package;
              if(data.ios.url != null && data.ios.url.length >0){
                  this.ios.url = data.ios.url;
              }
            }
            if(data.windows != null){
              this.windows.scheme = data.windows.scheme != null ? data.windows.scheme:'tcic';
              this.windows.package = data.windows.package;
              if(data.windows.url != null && data.windows.url.length >0){
                  this.windows.url = data.windows.url;
              }
            }
            if(data.mac != null){
              this.mac.scheme = data.mac.scheme != null ? data.mac.scheme:'tcic';
              this.mac.package = data.mac.package;
              if(data.mac.url != null && data.mac.url.length >0){
                  this.mac.url = data.mac.url;
              }
              console.log('getCallClientParam mac:',  this.mac.scheme,this.mac.url)
            }
          }
        })
        .catch((error) => {
          console.error('getCallClientParam Error:', error)
          LogReport.report('getCallClientParam', 'Exception: '+error, 0)
        });

    },

    queryCallStatus() {
      let url = this.getBaseUrl('v1/status/caller')

      const requestBody = { call_id: this.callId }
      console.log('queryCallStatus randomNum:', this.callId)
      fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.error_code == 0) {
            console.log('queryCallStatus Success:', data)
            let error_msg = ''
            let request_id = ''
            let status = ''
            error_msg = data.error_msg
            request_id = data.request_id
            status = data.status
            if (status == 1) {
              this.needReport = false
              clearInterval(this.callTimer)
              var currentTime = new Date().getTime()
              var costTime = currentTime - this.startEnterClassTime
              // LogReport.setNetType(this.getNetworkType())
              LogReport.report('Call_status', 1, costTime)
            }
          }
        })
        .catch((error) => {
          console.error('queryCallStatus Error:', error)
          LogReport.report('queryCallStatus', 'Exception: '+error, 0)

        })

      if (this.needReport) {
        var currentTime = new Date().getTime()
        if (currentTime - this.startEnterClassTime > 10000) {
          this.needReport = false
          // LogReport.setNetType(this.getNetworkType())
          LogReport.report('Call_status', 0)
        }
      }
    },
    // 关闭引导弹窗
    handleCloseMark() {
      this.isBrowserMarkShow = false
    },
    handleCloseShareFirends() {
      this.isTeacherOpen = false
    },

    handleDownload() {
      if (this.deviceType === 'ios') {
         location.href = this.ios.url
      } else if (this.deviceType === 'android') {
        console.log("handleDownload url:",this.android.url)
          location.href = this.android.url
      } else if(this.deviceType === 'mac'){
          window.open(this.mac.url, '_blank')
      }else{
         window.open(this.windows.url, '_blank')
      }
    },

    /* 下面是获取设备信息相关代码，不用动。 */

    // 获取设备信息
    getOsName() {
      // 非主流浏览器_联想pad
      if (
        navigator.userAgent.includes('Win') &&
        navigator.maxTouchPoints &&
        navigator.maxTouchPoints > 1
      ) {
        if (navigator.platform.includes('Win')) {
          return 'windows'
        }
        getAndroidAddress()
        //  this.env = false
        return 'android'
      }
      if (navigator.appVersion.includes('Win')) {
        //  this.env = 'inPc'
        return 'windows'
      }
      if (navigator.appVersion.includes('Android')) {
        getAndroidAddress()
        //  this.env = false
        return 'android'
      }
      // iOS和Mac的顺序不能变，经测试发现Mac的浏览器里会有iOS的字样
      if (navigator.appVersion.includes('iPhone')) {
        //  this.env = false
        return 'ios'
      }
      if (navigator.appVersion.includes('iPad')) {
        //  this.env = 'iPad'
        return 'ios'
      }
      if (
        navigator.userAgent.match(/Macintosh/i) &&
        navigator.maxTouchPoints &&
        navigator.maxTouchPoints > 1
      ) {
        //   this.env = 'iPad'
        return 'ios'
      }
      if (navigator.appVersion.includes('Mac')) {
        //    this.env = 'inPc'
        return 'mac'
      }
      if (navigator.userAgent.includes('Linux')) {
        //   this.env = 'inPc'
        return 'linux'
      }
      return 'unknown'
    },

    getNetworkType() {
      var ua = navigator.userAgent
      var networkStr = ua.match(/NetType\/\w+/)
        ? ua.match(/NetType\/\w+/)[0]
        : 'NetType/other'
      networkStr = networkStr.toLowerCase().replace('nettype/', '')
      console.log('getNetworkType :', networkStr)
      var networkType
      switch (networkStr) {
        case 'wifi':
          networkType = 'wifi'
          break
        case '4g':
          networkType = '4g'
          break
        case '3g':
          networkType = '3g'
          break
        case '3gnet':
          networkType = '3g'
          break
        case '2g':
          networkType = '2g'
          break
        default:
          networkType = 'other'
      }
      return networkType
    },
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
@import url('../assets/css/reset.css');
@import url('../assets/css/main.css');
</style>
