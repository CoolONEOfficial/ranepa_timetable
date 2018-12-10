package ru.coolone.ranepatimetable;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.widget.RemoteViews;

import java.util.Calendar;
import java.util.GregorianCalendar;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.java.Log;
import lombok.var;

/**
 * The weather widget's AppWidgetProvider.
 */
@Log
@NoArgsConstructor
public class WidgetProvider extends AppWidgetProvider {
    public static String REFRESH_ACTION = "ru.coolone.ranepatimetable.REFRESH";

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
    public Theme theme;
    public static SharedPreferences prefs;

    @AllArgsConstructor
    enum Theme {
        Light(Color.BLUE, 0xFF2196F3, Color.WHITE, Color.BLACK, 0xFF90CAF9),
        LightRed(Color.RED, 0xFFF44336, Color.WHITE, Color.BLACK, 0xFFEF9A9A),
        Dark(0xFF212121, 0xFF64FFDA, Color.BLACK, Color.WHITE, 0xFF616161),
        DarkRed(0xFF212121, 0xFFF44336, Color.WHITE, Color.WHITE, 0xFF616161);
        final int primary, accent, textPrimary, textAccent, background;
    }

    public static final int DEFAULT_THEME_ID = 0;
    private static final String FLUTTER_PREFIX = "flutter.";

    @AllArgsConstructor
    enum PrefsIds {
        WidgetTranslucent(FLUTTER_PREFIX.concat("widget_translucent")),
        ThemeId(FLUTTER_PREFIX.concat("theme_id"));
        final String prefId;
    }

    private Calendar getMidnight(Calendar calendar) {
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar;
    }

    private Calendar getTodayMidnight() {
        return getMidnight(Calendar.getInstance());
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
        prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        theme = Theme.values()[(int) prefs.getLong(PrefsIds.ThemeId.prefId, DEFAULT_THEME_ID)];

        // See the dimensions and
        Bundle options = appWidgetManager.getAppWidgetOptions(appWidgetId);
        width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH);
        height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT);
        log.severe("build layout: w" + width + " h" + height);

        var rv = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

        var cursor = TimetableDatabase.getInstance(context)
                .timetable()
                .selectByDate(getTodayMidnight().getTimeInMillis());
        var findDate = Calendar.getInstance();
        if (cursor.moveToLast()) {
            var lastLessonFinish = getLessonFinish(cursor);

            int dayDescId = R.string.widget_title_today;

            if (lastLessonFinish.compareTo(findDate) < 0) {
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

        // Specify the service to provide data for the collection widget.  Note that we need to
        // embed the appWidgetId via the data otherwise it will be ignored.
        var intent = new Intent(context, WidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.putExtra(WidgetRemoteViewsFactory.DATE, getMidnight(findDate).getTimeInMillis());
        intent.putExtra(WidgetRemoteViewsFactory.THEME_ID, theme.ordinal());
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

        int resId = -1;
        var translucent = prefs.getBoolean(PrefsIds.WidgetTranslucent.prefId, true);
        switch (theme) {
            case Dark:
            case DarkRed:
                resId = translucent
                        ? R.drawable.rounded_layout_dark_translucent
                        : R.drawable.rounded_layout_dark;
                break;
            case Light:
            case LightRed:
                resId = translucent
                        ? R.drawable.rounded_layout_light_translucent
                        : R.drawable.rounded_layout_light;
                break;
        }
        rv.setInt(R.id.widget_root, "setBackgroundResource", resId);
        rv.setRemoteAdapter(R.id.timeline_list, intent);
        // Set the empty view to be displayed if the collection is empty.  It must be a sibling
        // view of the collection view.
        rv.setEmptyView(R.id.timeline_list, R.id.empty_view);

        // Bind a click listener template for the contents of the weather list.  Note that we
        // need to update the intent's data if we set an extra, since the extras will be
        // ignored otherwise.
//        var onClickIntent = new Intent(context, WidgetProvider.class);
//        onClickIntent.setAction(WidgetProvider.CLICK_ACTION);
//        onClickIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
//        onClickIntent.setData(Uri.parse(onClickIntent.toUri(Intent.URI_INTENT_SCHEME)));
//        var onClickPendingIntent = PendingIntent.getBroadcast(context, 0,
//                onClickIntent, PendingIntent.FLAG_UPDATE_CURRENT);
//        rv.setPendingIntentTemplate(R.id.timeline_list, onClickPendingIntent);

        // Bind the click intent for the refresh button on the widget
//        var refreshIntent = new Intent(context, WidgetProvider.class);
//        refreshIntent.setAction(WidgetProvider.REFRESH_ACTION);
//        var refreshPendingIntent = PendingIntent.getBroadcast(context, 0,
//                refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        //rv.setOnClickPendingIntent(R.id.refresh, refreshPendingIntent);

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