package com.faultyworld.walkthrough;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.os.Build;
import android.support.v4.content.LocalBroadcastManager;
import android.content.res.AssetManager;
import android.os.Handler;
import android.os.Looper;
import android.renderscript.RenderScript;
import android.os.Bundle;
import android.content.Context;
import android.util.Log;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.VpnService;
import android.support.annotation.Nullable;
import android.app.Activity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "walk_through";

  private static final int VPN_REQUEST_CODE = 0;
  private static final String CONNECTION_TEST_URL = "https://www.google.com";

  private BroadcastReceiver serviceStateReceiver;
  private boolean VPNrunning = false;

  private void createNotificationChannel(String channelId) {
    // Create the NotificationChannel, but only on API 26+ because
    // the NotificationChannel class is new and not in the support library
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      CharSequence name = getString(R.string.notification_channel_name);
      String description = getString(R.string.notification_channel_description);
      int importance = NotificationManager.IMPORTANCE_HIGH;
      NotificationChannel channel = new NotificationChannel(channelId, name, importance);
      channel.setDescription(description);
      // Register the channel with the system; you can't change the importance
      // or other notification behaviors after this
      NotificationManager notificationManager = getSystemService(NotificationManager.class);
      notificationManager.createNotificationChannel(channel);
    }
  }

  private void destoryNotificationChannel(String channelId) {
    // Create the NotificationChannel, but only on API 26+ because
    // the NotificationChannel class is new and not in the support library
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      // Register the channel with the system; you can't change the importance
      // or other notification behaviors after this
      NotificationManager notificationManager = getSystemService(NotificationManager.class);
      notificationManager.deleteNotificationChannel(channelId);
    }
  }

  private void copyRawResourceToDir(int resId, String destPathName, boolean override) {
    File file = new File(destPathName);
    if (override || !file.exists()) {
      try {
        try (InputStream is = getResources().openRawResource(resId);
             FileOutputStream fos = new FileOutputStream(file)) {
          byte[] buf = new byte[1024];
          int len;
          while ((len = is.read(buf)) > 0) {
            fos.write(buf, 0, len);
          }
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    Globals.Init(this);
    TrojanConfig ins = Globals.getTrojanConfigInstance();

    createNotificationChannel(getString(R.string.notification_channel_id));

    copyRawResourceToDir(R.raw.cacert, Globals.getCaCertPath(), true);
    copyRawResourceToDir(R.raw.country, Globals.getCountryMmdbPath(), true);
    copyRawResourceToDir(R.raw.clash_config, Globals.getClashConfigPath(), false);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                    (call, result) -> {
                      if (call.method.equals("switchProxy")) {
                        if(!VPNrunning){
                          ArrayList remoteDetail = call.arguments();
                          String remoteAddress = remoteDetail.get(0).toString();
                          int remotePort = Integer.parseInt(remoteDetail.get(1).toString());
                          String remotePassword = remoteDetail.get(2).toString();
                          ins.setRemoteAddr(remoteAddress);
                          ins.setRemotePort(remotePort);
                          ins.setPassword(remotePassword);
                        }
                        MethodResultWrapper resultWrapper = new MethodResultWrapper(result);
                        if (!Globals.getTrojanConfigInstance().isValidRunningConfig()) {
                          resultWrapper.error("Invalid config.", null, null);
                        }
                        ProxyService serviceInstance = ProxyService.getInstance();
                        if (serviceInstance == null) {
                          TrojanHelper.WriteTrojanConfig(
                                  Globals.getTrojanConfigInstance(),
                                  Globals.getTrojanConfigPath()
                          );
                          TrojanHelper.ShowConfig(Globals.getTrojanConfigPath());

                          Intent i = VpnService.prepare(getApplicationContext());
                          if (i != null) {
                            startActivityForResult(i, VPN_REQUEST_CODE);
                          } else {
                            onActivityResult(VPN_REQUEST_CODE, Activity.RESULT_OK, null);
                            VPNrunning = true;
                            resultWrapper.success("Service start successfully.");
                          }
                        } else {
                          serviceInstance.stop();
                          VPNrunning = false;
                          resultWrapper.success("Service stop successfully.");
                        }
                      } else if (call.method.equals("testConnection")){
                        MethodResultWrapper resultWrapper = new MethodResultWrapper(result);
                        TestConnection testConnection = new TestConnection(MainActivity.this);
                        testConnection.setFinishListener(new TestConnection.DataFinishListener() {
                          @Override
                          public void dataFinishSuccessfully(Object data) {
                            resultWrapper.success(data);
                          }
                        });
                        testConnection.execute(CONNECTION_TEST_URL);
                      } else {
                        result.notImplemented();
                      }
                    }
            );
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == VPN_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
      Intent intent = new Intent(this, ProxyService.class);
      intent.putExtra(ProxyService.CLASH_EXTRA_NAME, true);
      startService(intent);
    }
  }

  private static class MethodResultWrapper implements MethodChannel.Result {
    private MethodChannel.Result methodResult;
    private Handler handler;

    MethodResultWrapper(MethodChannel.Result result) {
      methodResult = result;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          methodResult.success(result);
        }
      });
    }

    @Override
    public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          methodResult.error(errorCode, errorMessage, errorDetails);
        }
      });
    }

    @Override
    public void notImplemented() {
      handler.post(new Runnable() {
        @Override
        public void run() {
          methodResult.notImplemented();
        }
      });
    }
  }

}
