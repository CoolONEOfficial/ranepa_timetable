package ru.coolone.ranepatimetable;

import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import lombok.var;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), "ru.coolone.ranepatimetable/jsonChannel", JSONMethodCodec.INSTANCE).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("set")) {
                            var cursor = getContentResolver().query(TimetableDataProvider.CONTENT_URI, null, null,
                                    null, null);

                            Log.d("TAGG", call.arguments.toString());

                            result.success(cursor.getCount());

                            cursor.close();
                        } else {
                            result.notImplemented();
                        }
                    }

                });
    }

}
