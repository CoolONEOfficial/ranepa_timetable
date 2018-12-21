package ru.coolone.ranepatimetable;

import android.Manifest;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.provider.CalendarContract;
import android.support.v4.app.ActivityCompat;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.jakewharton.threetenabp.AndroidThreeTen;
import com.nabinbhandari.android.permissions.PermissionHandler;
import com.nabinbhandari.android.permissions.Permissions;

import org.threeten.bp.Duration;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Objects;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.java.Log;
import lombok.var;

/**
 * The widget's AppWidgetProvider.
 */
@Log
@NoArgsConstructor
public class WidgetProvider extends AppWidgetProvider {
    public static final String DELETE_OLD = "ru.coolone.ranepatimetable.DELETE_OLD";
    public static final String CREATE_ALARM_CLOCK = "ru.coolone.ranepatimetable.CREATE_ALARM_CLOCK";
    public static final String CREATE_CALENDAR_EVENTS = "ru.coolone.ranepatimetable.CREATE_CALENDAR_EVENTS";

    AlarmManager manager;
    PendingIntent updatePendingIntent, deleteOldPendingIntent;

    private static SharedPreferences _prefs;

    public static SharedPreferences getPrefs(Context context) {
        if (_prefs == null)
            _prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        return _prefs;
    }

    @Override
    public void onDisabled(Context context) {
        if (manager != null && updatePendingIntent != null)
            manager.cancel(updatePendingIntent);
    }

    @Override
    public void onEnabled(Context context) {
        AndroidThreeTen.init(context);

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

    private int getCalendarId(Context ctx) {
        String projection[] = {
                CalendarContract.Calendars._ID, CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL
        };

        var contentResolver = ctx.getContentResolver();
        var managedCursor = contentResolver.query(
                Uri.parse("content://com.android.calendar/calendars"),
                projection,
                null,
                null,
                null
        );

        if (managedCursor != null && managedCursor.moveToFirst()) {
            var idIndex = managedCursor.getColumnIndex(projection[0]);
            var accessIndex = managedCursor.getColumnIndex(projection[1]);
            do {
                if (managedCursor.getInt(accessIndex) == 700)
                    return managedCursor.getInt(idIndex);
            } while (managedCursor.moveToNext());
            managedCursor.close();
        }
        return -1;

    }

    private void createAlarmClock(Context ctx) {
        var firstLesson = TimetableDatabase.getInstance(ctx).timetable().selectByDate(showDate);
        if (firstLesson.moveToFirst()) {
            var duration = Duration.ofMinutes(getPrefs(ctx).getLong(PrefsIds.BeforeAlarmClock.prefId, 0));

            if (duration.isZero())
                Toast.makeText(ctx, R.string.noBeforeAlarmClock, Toast.LENGTH_LONG).show();
            else {
                var date = GregorianCalendar.getInstance();
                date.setTimeInMillis(firstLesson.getLong(firstLesson.getColumnIndex(Timeline.COLUMN_DATE)));
                date.add(Calendar.HOUR, firstLesson.getInt(firstLesson.getColumnIndex(
                        Timeline.PREFIX_START
                                + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                ))
                        - ((int) duration.toHours()));
                date.add(Calendar.MINUTE, firstLesson.getInt(firstLesson.getColumnIndex(
                        Timeline.PREFIX_START
                                + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE
                ))
                        - ((int) duration.toMinutes()));

                var alarmIntent = new Intent(AlarmClock.ACTION_SET_ALARM);
                alarmIntent.putExtra(AlarmClock.EXTRA_MESSAGE, firstLesson.getString(firstLesson.getColumnIndex(Timeline.PREFIX_LESSON + Timeline.LessonModel.COLUMN_LESSON_TITLE)));
                alarmIntent.putExtra(AlarmClock.EXTRA_HOUR, date.get(Calendar.HOUR));
                alarmIntent.putExtra(AlarmClock.EXTRA_MINUTES, date.get(Calendar.MINUTE));
                alarmIntent.putExtra(AlarmClock.EXTRA_SKIP_UI, true);
                alarmIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                ctx.startActivity(alarmIntent);
            }
        } else Toast.makeText(ctx, R.string.noLessons, Toast.LENGTH_LONG).show();
    }

    private void createCalendarEvents(final Context ctx) {
        var mLesson = TimetableDatabase.getInstance(ctx).timetable().selectByDate(showDate);

        if (mLesson.getCount() == 0)
            Toast.makeText(ctx, R.string.noLessons, Toast.LENGTH_LONG).show();
        else {
            while (mLesson.moveToNext()) {
                var mDate = GregorianCalendar.getInstance();
                mDate.setTimeInMillis(mLesson.getLong(mLesson.getColumnIndex(Timeline.COLUMN_DATE)));

                var mStartDate = new GregorianCalendar();
                mStartDate.setTimeInMillis(mDate.getTimeInMillis());
                mStartDate.add(Calendar.HOUR, mLesson.getInt(mLesson.getColumnIndex(
                        Timeline.PREFIX_START
                                + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                )));
                mStartDate.add(Calendar.MINUTE, mLesson.getInt(mLesson.getColumnIndex(
                        Timeline.PREFIX_START
                                + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE
                )));

                var mFinishDate = new GregorianCalendar();
                mFinishDate.setTimeInMillis(mDate.getTimeInMillis());
                mFinishDate.add(Calendar.HOUR, mLesson.getInt(mLesson.getColumnIndex(
                        Timeline.PREFIX_FINISH
                                + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                )));
                mFinishDate.add(Calendar.MINUTE, mLesson.getInt(mLesson.getColumnIndex(
                        Timeline.PREFIX_FINISH
                                + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE
                )));

                ContentResolver cr = ctx.getContentResolver();
                ContentValues values = new ContentValues();
                values.put(CalendarContract.Events.DTSTART, mStartDate.getTimeInMillis());
                values.put(CalendarContract.Events.DTEND, mFinishDate.getTimeInMillis());
                values.put(CalendarContract.Events.TITLE, mLesson.getString(mLesson.getColumnIndex(
                        Timeline.PREFIX_LESSON
                                + Timeline.LessonModel.COLUMN_LESSON_TITLE
                )));
                values.put(CalendarContract.Events.DESCRIPTION, mLesson.getString(mLesson.getColumnIndex(
                        Timeline.PREFIX_LESSON
                                + Timeline.LessonModel.COLUMN_LESSON_FULL_TITLE
                )));
                values.put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().getID());
                if (ActivityCompat.checkSelfPermission(ctx, android.Manifest.permission.WRITE_CALENDAR)
                        == PackageManager.PERMISSION_GRANTED
                        && ActivityCompat.checkSelfPermission(ctx, Manifest.permission.READ_CALENDAR)
                        == PackageManager.PERMISSION_GRANTED) {
                    values.put(CalendarContract.Events.CALENDAR_ID, getCalendarId(ctx));
                    Toast.makeText(ctx, cr.insert(CalendarContract.Events.CONTENT_URI, values) == null
                                    ? R.string.createCalendarEventsFailed
                                    : R.string.createCalendarEventsSuccess,
                            Toast.LENGTH_LONG
                    ).show();
                } else
                    Permissions.check(
                            ctx,
                            new String[]{
                                    Manifest.permission.WRITE_CALENDAR,
                                    Manifest.permission.READ_CALENDAR
                            },
                            null,
                            null,
                            new PermissionHandler() {
                                @Override
                                public void onGranted() {
                                    createCalendarEvents(ctx);
                                }

                                @Override
                                public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                                    super.onDenied(context, deniedPermissions);
                                    Toast.makeText(ctx, R.string.noCalendarPermissions,
                                            Toast.LENGTH_LONG
                                    ).show();
                                }
                            }
                    );
            }
        }
    }

    @Override
    public void onReceive(Context ctx, Intent intent) {
        log.info("onReceive: " + intent.getAction());

        if (Objects.equals(intent.getAction(), DELETE_OLD)) {
            TimetableDatabase.getInstance(ctx).timetable().deleteOld();
        } else if (Objects.equals(intent.getAction(), CREATE_ALARM_CLOCK)) {
            createAlarmClock(ctx);
        } else if (Objects.equals(intent.getAction(), CREATE_CALENDAR_EVENTS)) {
            createCalendarEvents(ctx);
        }

        super.onReceive(ctx, intent);
    }

    public static int width, height;
    public Theme theme;

    @AllArgsConstructor
    enum Theme {
        Light(
                Color.BLUE,
                0xFF2196F3,
                Color.WHITE,
                Color.BLACK,
                0xFF90CAF9
        ),
        LightRed(
                Color.RED,
                0xFFF44336,
                Color.WHITE,
                Color.BLACK,
                0xFFEF9A9A
        ),
        Dark(
                0xFF212121,
                0xFF64FFDA,
                Color.BLACK,
                Color.WHITE,
                0xFF616161
        ),
        DarkRed(
                0xFF212121,
                0xFFF44336,
                Color.WHITE,
                Color.WHITE,
                0xFF616161
        );

        final int primary, accent, textPrimary, textAccent, background;
    }

    public static final int DEFAULT_THEME_ID = Theme.LightRed.ordinal();
    private static final String FLUTTER_PREFIX = "flutter.";

    @AllArgsConstructor
    enum PrefsIds {
        WidgetTranslucent(FLUTTER_PREFIX.concat("widget_translucent")),
        ThemeId(FLUTTER_PREFIX.concat("theme_id")),
        BeforeAlarmClock(FLUTTER_PREFIX.concat("before_alarm_clock")),
        EndCache(FLUTTER_PREFIX.concat("end_cache"));
        final String prefId;
    }

    private static Calendar getMidnight(Calendar calendar) {
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar;
    }

    public static Calendar getTodayMidnight() {
        return getMidnight(Calendar.getInstance());
    }

    private Calendar getLessonStart(Cursor cursor) {
        var lesson = GregorianCalendar.getInstance();
        lesson.setTimeInMillis(
                cursor.getLong(
                        cursor.getColumnIndex(Timeline.COLUMN_DATE)
                )
        ); // set day
        lesson.set(Calendar.HOUR,
                cursor.getInt(
                        cursor.getColumnIndex(
                                Timeline.PREFIX_START
                                        + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                        )
                )
        ); // set finish hour
        lesson.set(Calendar.MINUTE,
                cursor.getInt(
                        cursor.getColumnIndex(
                                Timeline.PREFIX_START
                                        + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR
                        )
                )
        ); // set finish minute
        return lesson;
    }

    public static int daysBetween(Calendar startDate, Calendar endDate) {
        long end = endDate.getTimeInMillis();
        long start = startDate.getTimeInMillis();
        return safeLongToInt(TimeUnit.MILLISECONDS.toDays(Math.abs(end - start)));
    }

    public static int safeLongToInt(long l) {
        return (int) Math.max(Math.min(Integer.MAX_VALUE, l), Integer.MIN_VALUE);
    }

    static long showDate;

    private RemoteViews buildLayout(Context context, int appWidgetId, AppWidgetManager appWidgetManager) {
        theme = Theme.values()[(int) getPrefs(context).getLong(PrefsIds.ThemeId.prefId, DEFAULT_THEME_ID)];

        // See the dimensions and
        var options = appWidgetManager.getAppWidgetOptions(appWidgetId);
        width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH);
        height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT);
        log.info("build layout: w" + width + " h" + height);

        var rv = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

        var futureLessonCursor = TimetableDatabase.getInstance(context)
                .timetable()
                .selectWeekday(getTodayMidnight().getTimeInMillis());

        if (futureLessonCursor.moveToFirst()) {
            var futureLessonStart = getLessonStart(futureLessonCursor);

            String dayOfWeek;
            switch (futureLessonStart.get(Calendar.DAY_OF_WEEK)) {
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
                    break;
            }

            int dayDescId;
            switch (daysBetween(getTodayMidnight(), futureLessonStart)) {
                case 0:
                    dayDescId = R.string.widget_title_today;
                    break;
                case 1:
                    dayDescId = R.string.widget_title_tomorrow;
                    break;
                default:
                    dayDescId = R.string.widget_title_next_week;
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
        var futureLessonDate = GregorianCalendar.getInstance();
        futureLessonDate.setTimeInMillis(
                futureLessonCursor.getLong(futureLessonCursor.getColumnIndex(Timeline.COLUMN_DATE))
        );
        showDate = getMidnight(futureLessonDate).getTimeInMillis();
        intent.putExtra(WidgetRemoteViewsFactory.DATE, showDate);
        intent.putExtra(WidgetRemoteViewsFactory.THEME_ID, theme.ordinal());
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

        var translucent = getPrefs(context).getBoolean(PrefsIds.WidgetTranslucent.prefId, true);
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
        rv.setInt(R.id.create_calendar_events, "setColorFilter", theme.textAccent);
        rv.setInt(R.id.create_alarm_clock, "setColorFilter", theme.textAccent);

        rv.setOnClickPendingIntent(R.id.create_alarm_clock, getPendingSelfIntent(context, CREATE_ALARM_CLOCK));
        rv.setOnClickPendingIntent(R.id.create_calendar_events, getPendingSelfIntent(context, CREATE_CALENDAR_EVENTS));

        rv.setRemoteAdapter(R.id.timeline_list, intent);
        // Set the empty view to be displayed if the collection is empty.  It must be a sibling
        // view of the collection view.
        rv.setEmptyView(R.id.timeline_list, R.id.empty_view);

        return rv;
    }

    protected PendingIntent getPendingSelfIntent(Context context, String action) {
        var intent = new Intent(context, getClass());
        intent.setAction(action);
        return PendingIntent.getBroadcast(context, 0, intent, 0);
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