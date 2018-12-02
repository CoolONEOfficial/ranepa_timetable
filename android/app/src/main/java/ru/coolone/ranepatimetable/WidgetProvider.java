package ru.coolone.ranepatimetable;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
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

import lombok.var;

/**
 * Our data observer just notifies an update for all weather widgets when it detects a change.
 */
class WidgetDataProviderObserver extends ContentObserver {
    private AppWidgetManager mAppWidgetManager;
    private ComponentName mComponentName;

    WidgetDataProviderObserver(AppWidgetManager mgr, ComponentName cn, Handler h) {
        super(h);
        mAppWidgetManager = mgr;
        mComponentName = cn;
    }

    @Override
    public void onChange(boolean selfChange) {
        // The data has changed, so notify the widget that the collection view needs to be updated.
        // In response, the factory's onDataSetChanged() will be called which will requery the
        // cursor for the new data.
        mAppWidgetManager.notifyAppWidgetViewDataChanged(
                mAppWidgetManager.getAppWidgetIds(mComponentName), R.id.weather_list);
    }
}

/**
 * The weather widget's AppWidgetProvider.
 */
public class WidgetProvider extends AppWidgetProvider {
    public static String CLICK_ACTION = "ru.coolone.ranepatimetable.CLICK";
    public static String REFRESH_ACTION = "ru.coolone.ranepatimetable.REFRESH";
    public static String EXTRA_DAY_ID = "ru.coolone.ranepatimetable.day";
    private static Handler sWorkerQueue;
    private static WidgetDataProviderObserver sDataObserver;

    public WidgetProvider() {
        // Start the worker thread
        HandlerThread sWorkerThread = new HandlerThread("WidgetProvider-worker");
        sWorkerThread.start();
        sWorkerQueue = new Handler(sWorkerThread.getLooper());
    }

    @Override
    public void onEnabled(Context context) {
        // Register for external updates to the data to trigger an update of the widget.  When using
        // content providers, the data is often updated via a background service, or in response to
        // user interaction in the main app.  To ensure that the widget always reflects the current
        // state of the data, we must listen for changes and update ourselves accordingly.
        final ContentResolver r = context.getContentResolver();
        if (sDataObserver == null) {
            final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
            final ComponentName cn = new ComponentName(context, WidgetProvider.class);
            sDataObserver = new WidgetDataProviderObserver(mgr, cn, sWorkerQueue);
            r.registerContentObserver(TimetableDataProvider.CONTENT_URI, true, sDataObserver);
        }
    }

    @Override
    public void onReceive(Context ctx, Intent intent) {
        final String action = intent.getAction();
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

    private RemoteViews buildLayout(Context context, int appWidgetId) {

        // Specify the service to provide data for the collection widget.  Note that we need to
        // embed the appWidgetId via the data otherwise it will be ignored.
        var intent = new Intent(context, WidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
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
            RemoteViews layout = buildLayout(context, appWidgetId);
            appWidgetManager.updateAppWidget(appWidgetId, layout);
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds);
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager,
                                          int appWidgetId, Bundle newOptions) {
        RemoteViews layout = buildLayout(context, appWidgetId);
        appWidgetManager.updateAppWidget(appWidgetId, layout);
    }
}