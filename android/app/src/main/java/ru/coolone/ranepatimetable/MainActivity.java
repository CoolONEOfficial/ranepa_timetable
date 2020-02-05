package ru.coolone.ranepatimetable;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Bundle;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import lombok.var;

@lombok.extern.java.Log
public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), "ru.coolone.ranepatimetable/methodChannel").setMethodCallHandler(
                (methodCall, result) -> {
                    if ("refreshWidget".equals(methodCall.method)) {
                        var intent = new Intent(MainActivity.this, WidgetProvider.class);
                        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
                        var ids = AppWidgetManager.getInstance(getApplication())
                                .getAppWidgetIds(new ComponentName(getApplication(), WidgetProvider.class));
                        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
                        sendBroadcast(intent);
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

}
