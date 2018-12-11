package ru.coolone.ranepatimetable;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.lang.ref.WeakReference;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import lombok.AllArgsConstructor;
import lombok.var;

import static ru.coolone.ranepatimetable.Timeline.COLUMN_ID;
import static ru.coolone.ranepatimetable.Timeline.LessonModel.COLUMN_LESSON_TITLE;
import static ru.coolone.ranepatimetable.Timeline.PREFIX_LESSON;

public class MainActivity extends FlutterActivity {

    @AllArgsConstructor
    private static class AgentAsyncTask extends AsyncTask<Timeline[], Void, Void> {

        final WeakReference<Context> weakContext;

        @Override
        protected Void doInBackground(Timeline[]... params) {
            var timetable = TimetableDatabase.getInstance(weakContext.get()).timetable();
            timetable.delete();
            timetable.insertAll(params[0]);
            return null;
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        new BasicMessageChannel<>(getFlutterView(), "ru.coolone.ranepatimetable/jsonChannel", StringCodec.INSTANCE).setMessageHandler(
                new BasicMessageChannel.MessageHandler<String>() {
                    @Override
                    public void onMessage(String s, BasicMessageChannel.Reply<String> reply) {
                        Gson g = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").create();

                        var arr = g.fromJson(
                                s,
                                Timeline[].class
                        );

                        new AgentAsyncTask(new WeakReference<>(getApplicationContext())).execute(arr);
                    }
                }
        );

        new MethodChannel(getFlutterView(), "ru.coolone.ranepatimetable/methodChannel").setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if(methodCall.method.equals("refreshWidget")) {
                            var intent = new Intent(MainActivity.this, WidgetProvider.class);
                            intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
                            var ids = AppWidgetManager.getInstance(getApplication())
                                    .getAppWidgetIds(new ComponentName(getApplication(), WidgetProvider.class));
                            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
                            sendBroadcast(intent);
                            result.success(new Object());
                        } else result.notImplemented();
                    }
                }
        );
    }

}
