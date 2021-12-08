
const LogReport = {
    _sdk_app_id: 0,
    _user_id: '',
    _class_id: '',
    _action: 'tcic_call',
    _platform: process.platform,
    _version: '',
    _random: '12345678',
    _netType: 'wifi',
    init: function () {
        this._random = Date.now().toString() + Math.round(Math.random() * 10000).toString();
    },


    setPlatform: function (platform) {
        this._platform = platform
    },

    setSdkAppId: function (sdkappid) {
        this._sdk_app_id = sdkappid;
    },
    setUserId: function (userId) {
        this._user_id = userId;
    },
    setClassId: function (classId) {
        this._class_id = classId
    },

    setVersion: function (version) {
        this._version = version;
    },

    setNetType: function (netType) {
        this._netType = netType
    },

    report: function (action, message, costTime) {
        if (action != null) {
            this._action = action
        }
        var data = JSON.stringify({
            app_sdkappid: this._sdk_app_id,
            app_user_id: this._user_id,
            app_room_id: this._class_id,
            business: 'tcic_sdk',
            action_name: action,
            action_param: message,
            action_cost: costTime == null ? 0 : costTime,
            dev_platform: this._platform,
            net_type: this._netType,
            report_global_random: this._random,
            dev_user_agent: navigator.userAgent,
            app_web_sdk_version: this._version,
            app_module: 'web_call',

        })
        console.log(this._action, data)
        this._post({ url: "https://report-log-lv0.api.qcloud.com", data: data }, (code, msg) => {
            0 != code && console.warn("LOG_REPORT report error: " + msg);
        })
    },

    _post: function (option, calllback) {
        option.headers = { 'Content-Type': 'application/json' };
        option.method = 'POST';

        axios(option).then(rsp => {
            calllback(0, rsp.data);
        }).catch(err => {
            calllback(-1, err.message);
        })
    }
};

export { LogReport };