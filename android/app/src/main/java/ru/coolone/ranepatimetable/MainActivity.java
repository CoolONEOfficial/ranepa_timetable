package ru.coolone.ranepatimetable;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Bundle;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import lombok.var;

@lombok.extern.java.Log
public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        new BasicMessageChannel<>(getFlutterView(), "ru.coolone.ranepatimetable/getChannel", StringCodec.INSTANCE).setMessageHandler(
                new BasicMessageChannel.MessageHandler<String>() {
                    @Override
                    public void onMessage(String s, BasicMessageChannel.Reply<String> reply) {

                    }
                }
        );

        new BasicMessageChannel<>(getFlutterView(), "ru.coolone.ranepatimetable/updateChannel", StringCodec.INSTANCE).setMessageHandler(
                new BasicMessageChannel.MessageHandler<String>() {
                    @Override
                    public void onMessage(String s, BasicMessageChannel.Reply<String> reply) {

                    }
                }
        );

        new MethodChannel(getFlutterView(), "ru.coolone.ranepatimetable/methodChannel").setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    Gson getGson() {
                        return new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").create();
                    }

                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        switch (methodCall.method) {
                            case "refreshWidget":
                                var intent = new Intent(MainActivity.this, WidgetProvider.class);
                                intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
                                var ids = AppWidgetManager.getInstance(getApplication())
                                        .getAppWidgetIds(new ComponentName(getApplication(), WidgetProvider.class));
                                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
                                sendBroadcast(intent);
                                result.success(new Object());
                                break;
                            case "getDb": {
                                log.info("getDb started..");
                                var g = getGson();

                                var jsonArr = g.toJson(
                                        TimetableDatabase.getInstance(getApplicationContext())
                                        .timetable()
                                        .getAll()
                                );

                                log.info("getDb success (db arr: " + jsonArr +")");
                                result.success(jsonArr);
                                break;
                            }
                            case "deleteDb": {
                                log.info("deleteDb started..");

                                TimetableDatabase.getInstance(getApplicationContext())
                                        .timetable()
                                        .delete();

                                log.info("deleteDb success");
                                result.success(null);
                                break;
                            }
                            case "updateDb": {
                                log.info("updateDb started..");

                                var g = getGson();
                                var arr = g.fromJson(
                                        (String) methodCall.arguments,
                                        Timeline[].class
                                );

                                TimetableDatabase.getInstance(getApplicationContext()).timetable()
                                        .insertAll(arr);

                                log.info("updateDb success");
                                result.success(null);
                                break;
                            }
                            default:
                                result.notImplemented();
                                break;
                        }
                    }
                }
        );
    }

}
