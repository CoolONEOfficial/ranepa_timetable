package ru.coolone.ranepatimetable;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
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
    public static final String DELETE_OLD = "ru.coolone.ranepatimetable.DELETE_OLD";

    AlarmManager manager;
    PendingIntent updatePendingIntent, deleteOldPendingIntent;

    @Override
    public void onDisabled(Context context) {
        if (manager != null && updatePendingIntent != null)
            manager.cancel(updatePendingIntent);
    }

    @Override
    public void onEnabled(Context context) {
        manager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

        updatePendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                new Intent(context, WidgetProvider.class),
                PendingIntent.FLAG_UPDATE_CURRENT
        );
        manager.setRepeating(
                AlarmManager.RTC,
                getTodayMidnight().getTimeInMillis(),
                1000 * 60 * 60 * 24,
                updatePendingIntent
        );

        deleteOldPendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                new Intent(DELETE_OLD),
                PendingIntent.FLAG_UPDATE_CURRENT
        );
        manager.setRepeating(
                AlarmManager.RTC,
                getTodayMidnight().getTimeInMillis(),
                1000 * 60 * 60 * 24,
                deleteOldPendingIntent
        );
    }

    @Override
    public void onReceive(Context ctx, Intent intent) {
        if (intent.getAction() != null)
            switch (intent.getAction()) {
                case DELETE_OLD:
                    TimetableDatabase.getInstance(ctx).timetable().deleteOld();
                    break;
            }

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

    public static final int DEFAULT_THEME_ID = Theme.LightRed.ordinal();
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
        log.info("build layout: w" + width + " h" + height);

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
            rv.setTextColor(R.id.widget_title, theme.textAccent);
        }

        // Specify the service to provide data for the collection widget.  Note that we need to
        // embed the appWidgetId via the data otherwise it will be ignored.
        var intent = new Intent(context, WidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.putExtra(WidgetRemoteViewsFactory.DATE, getMidnight(findDate).getTimeInMillis());
        intent.putExtra(WidgetRemoteViewsFactory.THEME_ID, theme.ordinal());
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

        var translucent = prefs.getBoolean(PrefsIds.WidgetTranslucent.prefId, true);
        var bodyLayoutResLight = translucent
                ? R.drawable.rounded_body_layout_light_translucent
                : R.drawable.rounded_body_layout_light;
        var bodyLayoutResDark = translucent
                ? R.drawable.rounded_body_layout_dark_translucent
                : R.drawable.rounded_body_layout_dark;
        var headLayoutResLight = translucent
                ? R.drawable.rounded_head_layout_light_translucent
                : R.drawable.rounded_head_layout_light;
        var headLayoutResDark = translucent
                ? R.drawable.rounded_head_layout_dark_translucent
                : R.drawable.rounded_head_layout_dark;

        int bodyLayoutResId = -1;
        int headLayoutResId = -1;

        switch (theme) {
            case Dark:
            case DarkRed:
                bodyLayoutResId = bodyLayoutResDark;
                headLayoutResId = headLayoutResDark;
                break;
            case Light:
            case LightRed:
                bodyLayoutResId = bodyLayoutResLight;
                headLayoutResId = headLayoutResLight;
                break;
        }
        rv.setInt(R.id.widget_body, "setBackgroundResource", bodyLayoutResId);
        rv.setInt(R.id.widget_head, "setBackgroundResource", headLayoutResId);

        rv.setRemoteAdapter(R.id.timeline_list, intent);
        // Set the empty view to be displayed if the collection is empty.  It must be a sibling
        // view of the collection view.
        rv.setEmptyView(R.id.timeline_list, R.id.empty_view);

        return rv;
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        log.info("widget onUpdate");

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
        log.info("widget onAppWidgetOptionsChanged");

        appWidgetManager.updateAppWidget(
                appWidgetId,
                buildLayout(
                        context,
                        appWidgetId,
                        appWidgetManager
                )
        );

        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.timeline_list);
    }
}