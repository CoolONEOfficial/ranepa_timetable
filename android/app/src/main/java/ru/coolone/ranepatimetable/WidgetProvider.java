package ru.coolone.ranepatimetable;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.appwidget.AppWidgetProviderInfo;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.widget.RemoteViews;

import lombok.extern.java.Log;
import lombok.var;

/**
 * The weather widget's AppWidgetProvider.
 */
@Log
public class WidgetProvider extends AppWidgetProvider {
    public static String CLICK_ACTION = "ru.coolone.ranepatimetable.CLICK";
    public static String REFRESH_ACTION = "ru.coolone.ranepatimetable.REFRESH";
    public static String EXTRA_DAY_ID = "ru.coolone.ranepatimetable.day";

    public WidgetProvider() {
    }

    @Override
    public void onEnabled(Context context) {
    }

    @Override
    public void onReceive(Context ctx, Intent intent) {
//        final String action = intent.getAction();
//        if (action.equals(REFRESH_ACTION)) {
//            // BroadcastReceivers have a limited amount of time to do work, so for this sample, we
//            // are triggering an update of the data on another thread.  In practice, this update
//            // can be triggered from a background service, or perhaps as a result of user actions
//            // inside the main application.
//            final Context context = ctx;
//            sWorkerQueue.removeMessages(0);
//            sWorkerQueue.post(new Runnable() {
//                @Override
//                public void run() {
//                    final ContentResolver r = context.getContentResolver();
//                    final Cursor c = r.query(TimetableDataProvider.CONTENT_URI, null, null, null,
//                            null);
//                    final int count = c.getCount();
//                    c.close();
//                    // We disable the data changed observer temporarily since each of the updates
//                    // will trigger an onChange() in our data observer.
//                    r.unregisterContentObserver(sDataObserver);
//                    for (int i = 0; i < count; ++i) {
//                        final Uri uri = ContentUris.withAppendedId(TimetableDataProvider.CONTENT_URI, i);
//                        final ContentValues values = new ContentValues();
//                        values.put(TimetableDataProvider.Columns.TEMPERATURE,
//                                new Random().nextInt(sMaxDegrees));
//                        r.update(uri, values, null, null);
//                    }
//                    r.registerContentObserver(TimetableDataProvider.CONTENT_URI, true, sDataObserver);
//                    final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
//                    final ComponentName cn = new ComponentName(context, WidgetProvider.class);
//                    mgr.notifyAppWidgetViewDataChanged(mgr.getAppWidgetIds(cn), R.id.weather_list);
//                }
//            });
//        } else if (action.equals(CLICK_ACTION)) {
//            // Show a toast
//            final String day = intent.getStringExtra(EXTRA_DAY_ID);
//            final String formatStr = ctx.getResources().getString(R.string.toast_format_string);
//            Toast.makeText(ctx, String.format(formatStr, day), Toast.LENGTH_SHORT).show();
//        }
        super.onReceive(ctx, intent);
    }

    public static int globalwidth, globalheight;

    private RemoteViews buildLayout(Context context, int appWidgetId, int width, int height) {

        log.severe("build layout: w" + width + " h" + height);
        globalwidth = width;
        globalheight = height;

        // Specify the service to provide data for the collection widget.  Note that we need to
        // embed the appWidgetId via the data otherwise it will be ignored.
        var intent = new Intent(context, WidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.putExtra(WidgetRemoteViewsFactory.INTENT_WIDTH, width);
        intent.putExtra(WidgetRemoteViewsFactory.INTENT_HEIGHT, height);
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));
        var rv = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
        rv.setRemoteAdapter(R.id.weather_list, intent);
        // Set the empty view to be displayed if the collection is empty.  It must be a sibling
        // view of the collection view.
        rv.setEmptyView(R.id.weather_list, R.id.empty_view);

        // Bind a click listener template for the contents of the weather list.  Note that we
        // need to update the intent's data if we set an extra, since the extras will be
        // ignored otherwise.
        var onClickIntent = new Intent(context, WidgetProvider.class);
        onClickIntent.setAction(WidgetProvider.CLICK_ACTION);
        onClickIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        onClickIntent.setData(Uri.parse(onClickIntent.toUri(Intent.URI_INTENT_SCHEME)));
        var onClickPendingIntent = PendingIntent.getBroadcast(context, 0,
                onClickIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        rv.setPendingIntentTemplate(R.id.weather_list, onClickPendingIntent);

        // Bind the click intent for the refresh button on the widget
        var refreshIntent = new Intent(context, WidgetProvider.class);
        refreshIntent.setAction(WidgetProvider.REFRESH_ACTION);
        var refreshPendingIntent = PendingIntent.getBroadcast(context, 0,
                refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        rv.setOnClickPendingIntent(R.id.refresh, refreshPendingIntent);

        // Restore the minimal header
        rv.setTextViewText(R.id.city_name, context.getString(R.string.city_name));

        return rv;
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // Update each of the widgets with the remote adapter
        for (int appWidgetId : appWidgetIds) {
            // See the dimensions and
            Bundle options = appWidgetManager.getAppWidgetOptions(appWidgetId);

            // Get min width and height.
            int minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH);
            int minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT);

            RemoteViews layout = buildLayout(context, appWidgetId, minWidth, minHeight);
            appWidgetManager.updateAppWidget(appWidgetId, layout);
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds);
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager,
                                          int appWidgetId, Bundle newOptions) {
        // See the dimensions and
        Bundle options = appWidgetManager.getAppWidgetOptions(appWidgetId);

        // Get min width and height.
        int minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH);
        int minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT);

        appWidgetManager.updateAppWidget(appWidgetId, buildLayout(context, appWidgetId, minWidth, minHeight));
    }
}