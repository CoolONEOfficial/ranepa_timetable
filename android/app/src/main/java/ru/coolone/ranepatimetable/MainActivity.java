package ru.coolone.ranepatimetable;

import android.os.Bundle;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.text.DateFormat;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import lombok.var;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        new BasicMessageChannel<>(getFlutterView(), "ru.coolone.ranepatimetable/jsonChannel", StringCodec.INSTANCE).setMessageHandler(
                new BasicMessageChannel.MessageHandler<String>() {
                    @Override
                    public void onMessage(String s, BasicMessageChannel.Reply<String> reply) {
                        Gson g = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").create();

                        var arr = g.fromJson(s, TimelineModel[].class);

                        for(var mObj: arr) {
                            Log.d("TAG", "Arr " + mObj);
                        }

                    }
                }
       );
    }

}
