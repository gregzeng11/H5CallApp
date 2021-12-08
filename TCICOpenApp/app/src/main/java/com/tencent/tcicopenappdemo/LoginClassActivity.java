package com.tencent.tcicopenappdemo;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.tencent.tcic.TCICClassConfig;
import com.tencent.tcic.TCICConstants;
import com.tencent.tcic.pages.TCICClassActivity;
import com.tencent.tcic.util.Utils;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import androidx.appcompat.app.AppCompatActivity;

public class LoginClassActivity extends AppCompatActivity implements View.OnClickListener {
    private static final String TAG = LoginClassActivity.class.getSimpleName();
    private TextView paramsTv;
    private Button loginBtn;
    private static final String DEMO_SCHEME = "tcicdemo";
    private String paramStr;

    private String schoolid;
    private String classid;
    private String userid;
    private String token;
    private String env ="release";
    private Map<String, String> customParams = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_class);
        paramsTv = (TextView) findViewById(R.id.tv_params);
        loginBtn = (Button) findViewById(R.id.btn_login);
        loginBtn.setOnClickListener(this);

        getParamsFromUri();
    }

    private void getParamsFromUri() {
        Uri uri = getIntent().getData();
        if (uri == null) {
            Log.e(TAG, "getParams Error!");
            return;
        }
        Log.d(TAG, "uri: " + uri.toString());
        String scheme = uri.getScheme();

        if (TextUtils.isEmpty(scheme)) {
            Log.e(TAG, "scheme is Empty!");
            return;
        }

        if (!scheme.equals(DEMO_SCHEME)) {
            Log.e(TAG, "scheme invalid!");
            return;
        }
        paramStr = "参数信息:\n";
        String paramsKey = "";
        String paramsValue = "";

        //解析uri中的参数
        Set<String> queryParameterNames = uri.getQueryParameterNames();
        if (queryParameterNames != null && queryParameterNames.size() > 0) {
            for (String key : queryParameterNames) {
                paramsKey = key;
                paramsValue = uri.getQueryParameter(paramsKey);
                paramStr += paramsKey + " : " + paramsValue + "\n";
                handleParams(paramsKey, paramsValue);
                Log.i(TAG, "key: " + paramsKey + " value: " + paramsValue);
            }
        }
        paramsTv.setText(paramStr);
    }

    private void handleParams(String key, String value) {
        if (key.equals("schoolid")) {
            schoolid = value;
        } else if (key.equals("classid")) {
            classid = value;
        } else if (key.equals("userid")) {
            userid = value;
        } else if (key.equals("token")) {
            token = value;
        } else if (key.equals("env")) {
            env = value;
        } else {
            customParams.put(key, value);
        }
    }

    private void enterClassroom() {
        if (TextUtils.isEmpty(schoolid) || TextUtils.isEmpty(classid) || TextUtils.isEmpty(userid) || TextUtils.isEmpty(userid)) {
            Log.e(TAG, "class params is empty");
            return;
        }
        Intent intent = new Intent(LoginClassActivity.this, TCICClassActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        Bundle bundle = new Bundle();

        TCICClassConfig initConfig = new TCICClassConfig.Builder()
                .schoolId(Integer.parseInt(schoolid))
                .classId(Long.parseLong(classid))
                .userId(userid)
                .deviceType(Utils.isTablet(LoginClassActivity.this)
                        ? TCICConstants.DEVICE_TABLET
                        : TCICConstants.DEVICE_PHONE)
                .token(token)
                .coreEnv(env.equals("release") ? "" : env)
                .customParams(customParams)
                .build();
        bundle.putParcelable(TCICConstants.KEY_INIT_CONFIG, initConfig);

        intent.putExtras(bundle);
        startActivity(intent);
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.btn_login:
                enterClassroom();
                break;
        }
    }

}