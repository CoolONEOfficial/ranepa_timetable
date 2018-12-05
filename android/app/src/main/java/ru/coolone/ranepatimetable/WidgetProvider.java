package ru.coolone.ranepatimetable;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;

import java.util.Calendar;

import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.widget.RemoteViews;

import java.util.GregorianCalendar;

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

    public static int width, height;

    private Calendar getTodayMidnight() {
        var todayMidnight = Calendar.getInstance();
        todayMidnight.set(Calendar.HOUR_OF_DAY, 0);
        todayMidnight.set(Calendar.MINUTE, 0);
        todayMidnight.set(Calendar.SECOND, 0);
        todayMidnight.set(Calendar.MILLISECOND, 0);

        return todayMidnight;
    }

    private Calendar getLessonFinish(Cursor cursor) {
        var lastLesson = new GregorianCalendar();
        lastLesson.setTimeInMillis(
                cursor.getLong(
                        cursor.getColumnIndex(Timeline.COLUMN_DATE)
                )
        ); // set day
        lastLesson.set(Calendar.HOUR,
                cursor.getInt(
                        cursor.getColumnIndex(
                                Timeline.PREFIX_START
                                        + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                        )
                )
        ); // set finish hour
        lastLesson.set(Calendar.MINUTE,
                cursor.getInt(
                        cursor.getColumnIndex(
                                Timeline.PREFIX_START
                                        + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                        )
                )
        ); // set finish minute
        return lastLesson;
    }

    private RemoteViews buildLayout(Context context, int appWidgetId, AppWidgetManager appWidgetManager) {

        // See the dimensions and
        Bundle options = appWidgetManager.getAppWidgetOptions(appWidgetId);
        width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH);
        height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT);
        log.severe("build layout: w" + width + " h" + height);

        // Specify the service to provide data for the collection widget.  Note that we need to
        // embed the appWidgetId via the data otherwise it will be ignored.
        var intent = new Intent(context, WidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.putExtra(WidgetRemoteViewsFactory.INTENT_WIDTH, width);
        intent.putExtra(WidgetRemoteViewsFactory.INTENT_HEIGHT, height);
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

        var rv = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
        rv.setInt(R.id.widget_root,  "setBackgroundResource", R.drawable.rounded_layout_light);
        rv.setRemoteAdapter(R.id.timeline_list, intent);
        // Set the empty view to be displayed if the collection is empty.  It must be a sibling
        // view of the collection view.
        rv.setEmptyView(R.id.timeline_list, R.id.empty_view);

        // Bind a click listener template for the contents of the weather list.  Note that we
        // need to update the intent's data if we set an extra, since the extras will be
        // ignored otherwise.
        var onClickIntent = new Intent(context, WidgetProvider.class);
        onClickIntent.setAction(WidgetProvider.CLICK_ACTION);
        onClickIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        onClickIntent.setData(Uri.parse(onClickIntent.toUri(Intent.URI_INTENT_SCHEME)));
        var onClickPendingIntent = PendingIntent.getBroadcast(context, 0,
                onClickIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        rv.setPendingIntentTemplate(R.id.timeline_list, onClickPendingIntent);

        // Bind the click intent for the refresh button on the widget
//        var refreshIntent = new Intent(context, WidgetProvider.class);
//        refreshIntent.setAction(WidgetProvider.REFRESH_ACTION);
//        var refreshPendingIntent = PendingIntent.getBroadcast(context, 0,
//                refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        //rv.setOnClickPendingIntent(R.id.refresh, refreshPendingIntent);

        var todayMidnight = getTodayMidnight();
        var cursor = TimetableDatabase.getInstance(context)
                .timetable()
                .selectByDate(todayMidnight.getTimeInMillis());
        if(cursor.moveToLast()) {
            var lastLessonFinish = getLessonFinish(cursor);

            int dayDescId = R.string.widget_title_today;

            var findDate = Calendar.getInstance();
            if(lastLessonFinish.compareTo(findDate) < 0) {
                findDate.add(Calendar.DATE, 1);
                dayDescId = R.string.widget_title_tomorrow;
            }
            String dayOfWeek;
            switch (findDate.get(Calendar.DAY_OF_WEEK)) {
                case Calendar.MONDAY:
                    dayOfWeek = context.getString(R.string.monday);
                    break;
                case Calendar.TUESDAY:
                    dayOfWeek = context.getString(R.string.tuesday);
                    break;
                case Calendar.WEDNESDAY:
                    dayOfWeek = context.getString(R.string.wednesday);
                    break;
                case Calendar.THURSDAY:
                    dayOfWeek = context.getString(R.string.thursday);
                    break;
                case Calendar.FRIDAY:
                    dayOfWeek = context.getString(R.string.friday);
                    break;
                case Calendar.SATURDAY:
                    dayOfWeek = context.getString(R.string.saturday);
                    break;
                default: // sunday
                    dayOfWeek = context.getString(R.string.monday);
                    findDate.add(Calendar.DATE, 1);
                    dayDescId = R.string.widget_title_next_week;
                    break;
            }
            rv.setTextViewText(R.id.widget_title,
                    String.format(dayOfWeek, context.getString(dayDescId))
            );
        }
        return rv;
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // Update each of the widgets with the remote adapter
        for (int appWidgetId : appWidgetIds) {
            appWidgetManager.updateAppWidget(
                    appWidgetId,
                    buildLayout(context, appWidgetId, appWidgetManager)
            );
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds);
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager,
                                          int appWidgetId, Bundle newOptions) {
        appWidgetManager.updateAppWidget(
                appWidgetId,
                buildLayout(
                        context,
                        appWidgetId,
                        appWidgetManager
                )
        );
    }
}