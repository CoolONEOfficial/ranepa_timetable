package ru.coolone.ranepatimetable;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.lang.ref.WeakReference;
import java.text.DateFormat;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import lombok.AllArgsConstructor;
import lombok.var;

import static ru.coolone.ranepatimetable.Timeline.LessonModel.*;
import static ru.coolone.ranepatimetable.Timeline.RoomModel.*;
import static ru.coolone.ranepatimetable.Timeline.TeacherModel.*;
import static ru.coolone.ranepatimetable.Timeline.TimeOfDayModel.*;
import static ru.coolone.ranepatimetable.Timeline.*;

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

//                        ContentValues[] valuesArr = new ContentValues[arr.length];
//                        for(int mArrId = 0; mArrId < arr.length; mArrId++) {
//                            var mTimeline = arr[mArrId];
//                            var mValues = new ContentValues();
//                            mValues.put(COLUMN_ID, mArrId);
//                            mValues.put(PREFIX_LESSON + COLUMN_LESSON_TITLE, mTimeline.);
//                            valuesArr[mArrId] = mValues;
//                        }
//                        getContentResolver().bulkInsert(TimetableDataProvider.URI_TIMELINE, valuesArr);
                    }
                }
        );
    }

}
