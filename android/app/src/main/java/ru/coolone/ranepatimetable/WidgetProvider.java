package ru.coolone.ranepatimetable;

import android.Manifest;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.appwidget.AppWidgetProviderInfo;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.provider.CalendarContract;
import android.util.Pair;
import android.view.View;
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

import androidx.core.app.ActivityCompat;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.java.Log;
import lombok.val;
import lombok.var;

import static ru.coolone.ranepatimetable.WidgetRemoteViewsFactory.dpScale;

/**
 * The widget's AppWidgetProvider.
 */
@Log
@NoArgsConstructor
public class WidgetProvider extends AppWidgetProvider {
    enum IntentAction {
        DeleteOld("DELETE_OLD"),
        CreateAlarmClock("CREATE_ALARM_CLOCK"),
        CreateCalendarEvents("CREATE_CALENDAR_EVENTS"),
        DayNext("DAY_NEXT"),
        DayPrev("DAY_PREV");
        final String action;

        IntentAction(String action) {
            this.action = "ru.coolone.ranepatimetable." + action;
        }
    }

    enum Brightness {
        Dark,
        Light
    }

    AlarmManager manager;
    PendingIntent updatePendingIntent, deleteOldPendingIntent;

    static private int dateOffset;

    enum SearchItemTypeId {Teacher, Group}

    private static SharedPreferences _prefs;

    public static SharedPreferences getPrefs(Context ctx) {
        if (_prefs == null)
            _prefs = ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        return _prefs;
    }

    @Override
    public void onDisabled(Context ctx) {
        if (manager != null && updatePendingIntent != null)
            manager.cancel(updatePendingIntent);
    }

    @Override
    public void onEnabled(Context ctx) {
        AndroidThreeTen.init(ctx);

        widgetSize = Pair.create(
                getPrefs(ctx).getInt(PrefsIds.WidgetSizeWidth.prefId, 1),
                getPrefs(ctx).getInt(PrefsIds.WidgetSizeHeight.prefId, 1)
        );

        log.info("Create widget size from prefs: \n"
                + "w: " + widgetSize.first + "\n"
                + "h: " + widgetSize.second + "\n"
        );

        manager = (AlarmManager) ctx.getSystemService(Context.ALARM_SERVICE);

        updatePendingIntent = PendingIntent.getBroadcast(
                ctx,
                0,
                new Intent(ctx, WidgetProvider.class),
                PendingIntent.FLAG_UPDATE_CURRENT
        );
        manager.setRepeating(
                AlarmManager.RTC,
                getTodayMidnight().getTimeInMillis(),
                1000 * 60 * 60 * 24,
                updatePendingIntent
        );

        deleteOldPendingIntent = PendingIntent.getBroadcast(
                ctx,
                0,
                new Intent(IntentAction.DeleteOld.action),
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
                                public void onDenied(Context ctx, ArrayList<String> deniedPermissions) {
                                    super.onDenied(ctx, deniedPermissions);
                                    Toast.makeText(ctx, R.string.noCalendarPermissions,
                                            Toast.LENGTH_LONG
                                    ).show();
                                }
                            }
                    );
            }
        }
    }

    private void refreshWidget(Context ctx) {
        ComponentName name = new ComponentName(ctx, WidgetProvider.class);
        int[] ids = AppWidgetManager.getInstance(ctx).getAppWidgetIds(name);

        for (var mId : ids)
            AppWidgetManager.getInstance(ctx)
                    .updateAppWidget(
                            new ComponentName(
                                    ctx.getPackageName(),
                                    WidgetProvider.class.getName()
                            ),
                            buildLayout(
                                    ctx,
                                    mId,
                                    AppWidgetManager.getInstance(ctx),
                                    false
                            )
                    );
    }

    @Override
    public void onReceive(Context ctx, Intent intent) {
        log.info("onReceive: " + intent.getAction());

        if (Objects.equals(intent.getAction(), IntentAction.DeleteOld.action)) {
            TimetableDatabase.getInstance(ctx).timetable().deleteOld();
        } else if (Objects.equals(intent.getAction(), IntentAction.CreateAlarmClock.action)) {
            createAlarmClock(ctx);
        } else if (Objects.equals(intent.getAction(), IntentAction.CreateCalendarEvents.action)) {
            createCalendarEvents(ctx);
        } else if (Objects.equals(intent.getAction(), IntentAction.DayNext.action) || Objects.equals(intent.getAction(), IntentAction.DayPrev.action)) {
            Calendar now;
            do {
                dateOffset += Objects.equals(intent.getAction(), IntentAction.DayNext.action)
                        ? 1
                        : -1;

                now = GregorianCalendar.getInstance();
                now.add(Calendar.DATE, dateOffset);
            } while (now.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY);
            refreshWidget(ctx);
        }

        super.onReceive(ctx, intent);
    }

    public Theme theme;

    @AllArgsConstructor
    static class Theme {
        final int primary, accent, textPrimary, textAccent, background;
    }

    public static final Theme defaultTheme = new Theme(
            Color.BLUE,
            0xFF2196F3,
            Color.WHITE,
            Color.BLACK,
            0xFF90CAF9
    );

    private static final String FLUTTER_PREFIX = "flutter.";

    enum PrefsIds {
        WidgetTranslucent("widget_translucent"),

        ThemePrimary("theme_primary"),
        ThemeAccent("theme_accent"),
        ThemeTextPrimary("theme_text_primary"),
        ThemeTextAccent("theme_text_accent"),
        ThemeBackground("theme_background"),

        ThemeBrightness("theme_brightness"),

        BeforeAlarmClock("before_alarm_clock"),
        EndCache("end_cache"),
        WidgetSizeWidth("widget_size_width"),
        WidgetSizeHeight("widget_size_height"),

        SelectedSearchItemPrefix("selected_search_item_"),
        PrimarySearchItemPrefix("primary_search_item_"),
        ItemType("type", false),
        ItemId("id", false),
        ItemTitle("title", false);

        final String prefId;

        PrefsIds(String prefId) {
            this(prefId, true);
        }

        PrefsIds(String prefId, boolean flutterPrefix) {
            this.prefId = flutterPrefix ? FLUTTER_PREFIX.concat(prefId) : prefId;
        }
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

    static long showDate;

    static Bitmap buildEmptyViewBitmap(Context ctx, Theme theme) {
        var type = SearchItemTypeId.values()[
                (int) getPrefs(ctx).getLong(
                        PrefsIds.PrimarySearchItemPrefix.prefId + PrefsIds.ItemType.prefId,
                        0
                )
                ];

        var BEER = '\ue838';
        var CONFETTI = '\ue839';

        return buildNotificationBitmap(
                ctx,
                theme,
                type == SearchItemTypeId.Teacher
                        ? CONFETTI
                        : BEER,
                ctx.getString(R.string.freeDay),
                9f
        );
    }

    static Bitmap buildNoCacheImageBitmap(Context ctx, Theme theme) {
        var NO_CACHE = '\ue826';

        return buildNotificationBitmap(
                ctx,
                theme,
                NO_CACHE,
                ctx.getString(R.string.noCache),
                14f,
                0
        );
    }

    static Bitmap buildNotificationBitmap(
            Context ctx,
            Theme theme,
            char icon,
            String notification,
            float textScale
    ) {
        return buildNotificationBitmap(
                ctx,
                theme,
                icon,
                notification,
                textScale,
                ctx.getResources().getDimension(R.dimen.widget_head_height) / dpScale(ctx)
        );
    }

    static Bitmap buildNotificationBitmap(
            Context ctx,
            Theme theme,
            char icon,
            String notification,
            float textScale,
            float headHeight
    ) {
        var dpScale = dpScale(ctx);

        var bitmap = Bitmap.createBitmap((int) (widgetSize.first * dpScale), (int) (widgetSize.second * dpScale), Bitmap.Config.ARGB_8888);
        var canvas = new Canvas(bitmap);

        var iconPaint = new Paint();
        iconPaint.setAntiAlias(true);
        iconPaint.setSubpixelText(true);
        iconPaint.setTextAlign(Paint.Align.CENTER);
        iconPaint.setTypeface(
                Typeface.createFromAsset(
                        ctx.getAssets(),
                        "fonts/TimetableIcons.ttf"
                )
        );

        iconPaint.setTextSize(dpScale * (Math.min(widgetSize.first, widgetSize.second) / 3f));
        iconPaint.setColor(theme.textAccent);

        canvas.drawText(
                String.valueOf(icon),
                (widgetSize.first / 2f) * dpScale,
                (headHeight + (widgetSize.second - headHeight) / 2) * dpScale,
                iconPaint
        );

        var textPaint = new Paint();
        textPaint.setAntiAlias(true);
        textPaint.setSubpixelText(true);
        textPaint.setTextAlign(Paint.Align.CENTER);

        textPaint.setTextSize(dpScale * (Math.min(widgetSize.first, widgetSize.second) / textScale));
        textPaint.setColor(theme.textAccent);

        var mTextY = (
                headHeight +
                        (
                                widgetSize.second - headHeight
                        ) / 2 +
                        (
                                Math.min(widgetSize.first, widgetSize.second) / 4f
                        )
        ) * dpScale;
        for (var line : notification.split("\n")) {
            canvas.drawText(
                    line,
                    (widgetSize.first / 2f) * dpScale,
                    mTextY,
                    textPaint
            );
            mTextY += textPaint.descent() - textPaint.ascent();
        }

        return bitmap;
    }

    private Pair<Integer, Integer> getWidgetSize(
            Context ctx,
            int appWidgetId,
            AppWidgetManager manager
    ) {

        AppWidgetProviderInfo providerInfo = AppWidgetManager.getInstance(
                ctx.getApplicationContext()).getAppWidgetInfo(appWidgetId);

        // Since min and max is usually the same, just take min
        var mWidgetLandSize = new Pair<>(providerInfo.minWidth, providerInfo.minHeight);
        var mWidgetPortSize = new Pair<>(providerInfo.minWidth, providerInfo.minHeight);
        var mNewWidgetLandSize = new Pair<>(0, 0);
        var mNewWidgetPortSize = new Pair<>(0, 0);

        Bundle mAppWidgetOptions = manager.getAppWidgetOptions(appWidgetId);

        if (mAppWidgetOptions
                .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) > 0) {

            mNewWidgetPortSize = new Pair<>(
                    mAppWidgetOptions
                            .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH),
                    mAppWidgetOptions
                            .getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
            );

            mNewWidgetLandSize = new Pair<>(
                    mAppWidgetOptions
                            .getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH),
                    mAppWidgetOptions
                            .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            );
        }

        log.info(
                "Dimensions of the Widget in DIP: \n"
                        + "landWidth = " + mWidgetLandSize.first
                        + ",\nlandHeight = " + mWidgetLandSize.second
                        + ",\nportWidth = " + mWidgetPortSize.first
                        + ",\nportHeight = " + mWidgetPortSize.second
                        + ",\nnew landWidth = " + mNewWidgetLandSize.first
                        + ",\nnew landHeight = " + mNewWidgetLandSize.second
                        + ",\nnew portWidth = " + mNewWidgetPortSize.first
                        + ",\nnew portHeight = " + mNewWidgetPortSize.second
        );

        return ctx.getResources().getBoolean(R.bool.isPort)
                ? mNewWidgetPortSize.first != 0 || mNewWidgetPortSize.second != 0
                ? mNewWidgetPortSize
                : mWidgetPortSize
                : mNewWidgetLandSize.first != 0 || mNewWidgetLandSize.second != 0
                ? mNewWidgetLandSize
                : mWidgetLandSize;
    }

    public static Pair<Integer, Integer> widgetSize;

    private RemoteViews buildLayout(Context ctx, int appWidgetId, AppWidgetManager manager, boolean updateSize) {
        val prefs = getPrefs(ctx);

        log.severe("prefs color: " + prefs.getString(PrefsIds.ThemePrimary.prefId, Integer.toHexString(defaultTheme.primary)));

        theme = new Theme(
                Color.parseColor('#' + prefs.getString(PrefsIds.ThemePrimary.prefId, Integer.toHexString(defaultTheme.primary))),
                Color.parseColor('#' + prefs.getString(PrefsIds.ThemeAccent.prefId, Integer.toHexString(defaultTheme.textAccent))),
                Color.parseColor('#' + prefs.getString(PrefsIds.ThemeTextAccent.prefId, Integer.toHexString(defaultTheme.textPrimary))),
                Color.parseColor('#' + prefs.getString(PrefsIds.ThemeTextPrimary.prefId, Integer.toHexString(defaultTheme.textAccent))),
                Color.parseColor('#' + prefs.getString(PrefsIds.ThemeBackground.prefId, Integer.toHexString(defaultTheme.background)))
        );

        // Set the size
        if (updateSize) {
            widgetSize = getWidgetSize(ctx, appWidgetId, manager);
            var prefsEditor = getPrefs(ctx).edit();
            prefsEditor.putInt(PrefsIds.WidgetSizeWidth.prefId, widgetSize.first);
            prefsEditor.putInt(PrefsIds.WidgetSizeHeight.prefId, widgetSize.second);
            prefsEditor.apply();
        }

        // Get rounded background layout ids

        int bodyLayoutResId = -1;
        int headLayoutResId = -1;
        int layoutResId = -1;

        var translucent = getPrefs(ctx).getBoolean(PrefsIds.WidgetTranslucent.prefId, true);

        switch (Brightness.values()[(int) prefs.getLong(PrefsIds.ThemeBrightness.prefId, 0)]) {
            case Dark:
                bodyLayoutResId = translucent
                        ? R.drawable.rounded_body_layout_dark_translucent
                        : R.drawable.rounded_body_layout_dark;
                headLayoutResId = translucent
                        ? R.drawable.rounded_head_layout_dark_translucent
                        : R.drawable.rounded_head_layout_dark;
                layoutResId = translucent
                        ? R.drawable.rounded_layout_dark_translucent
                        : R.drawable.rounded_layout_dark;
                break;
            case Light:
                bodyLayoutResId = translucent
                        ? R.drawable.rounded_body_layout_light_translucent
                        : R.drawable.rounded_body_layout_light;
                headLayoutResId = translucent
                        ? R.drawable.rounded_head_layout_light_translucent
                        : R.drawable.rounded_head_layout_light;
                layoutResId = translucent
                        ? R.drawable.rounded_layout_light_translucent
                        : R.drawable.rounded_layout_light;
                break;
        }

        RemoteViews rv;

        if (TimetableDatabase.getInstance(ctx).timetable().count() != 0) {

            rv = new RemoteViews(ctx.getPackageName(), R.layout.widget_layout);

            var futureLessonFindDate = getTodayMidnight();
            futureLessonFindDate.add(Calendar.DATE, dateOffset);

            String dayOfWeek = null;
            switch (futureLessonFindDate.get(Calendar.DAY_OF_WEEK)) {
                case Calendar.MONDAY:
                    dayOfWeek = ctx.getString(R.string.monday);
                    break;
                case Calendar.TUESDAY:
                    dayOfWeek = ctx.getString(R.string.tuesday);
                    break;
                case Calendar.WEDNESDAY:
                    dayOfWeek = ctx.getString(R.string.wednesday);
                    break;
                case Calendar.THURSDAY:
                    dayOfWeek = ctx.getString(R.string.thursday);
                    break;
                case Calendar.FRIDAY:
                    dayOfWeek = ctx.getString(R.string.friday);
                    break;
                case Calendar.SATURDAY:
                    dayOfWeek = ctx.getString(R.string.saturday);
                    break;
            }

            int dayDescId;
            switch (dateOffset) {
                case 0:
                    dayDescId = R.string.widget_title_today;
                    break;
                case 1:
                    dayDescId = R.string.widget_title_tomorrow;
                    break;
                case 2:
                    dayDescId = R.string.widget_title_after_tomorrow;
                    break;
                default:
                    dayDescId = R.string.widget_title_after_days;
            }

            var dayDescStr = ctx.getString(dayDescId);
            if (dateOffset > 2)
                dayDescStr = String.format(dayDescStr, dateOffset);

            rv.setTextViewText(R.id.widget_title,
                    dayOfWeek + ", " + dayDescStr
            );
            rv.setTextColor(R.id.widget_title, theme.textAccent);

            // Specify the service to provide data for the collection widget.  Note that we need to
            // embed the appWidgetId via the data otherwise it will be ignored.
            var intent = new Intent(ctx, WidgetService.class);
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            var futureLessonDate = GregorianCalendar.getInstance();
            futureLessonDate.setTimeInMillis(
                    futureLessonFindDate.getTimeInMillis()
            );
            showDate = getMidnight(futureLessonDate).getTimeInMillis();
            intent.putExtra(WidgetRemoteViewsFactory.DATE, showDate);
            intent.putExtra(WidgetRemoteViewsFactory.THEME_PRIMARY, theme.primary);
            intent.putExtra(WidgetRemoteViewsFactory.THEME_ACCENT, theme.accent);
            intent.putExtra(WidgetRemoteViewsFactory.THEME_TEXT_PRIMARY, theme.textPrimary);
            intent.putExtra(WidgetRemoteViewsFactory.THEME_TEXT_ACCENT, theme.textAccent);
            intent.putExtra(WidgetRemoteViewsFactory.THEME_BACKGROUND, theme.background);
            intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

            rv.setInt(R.id.widget_body, "setBackgroundResource", bodyLayoutResId);
            rv.setInt(R.id.widget_head, "setBackgroundResource", headLayoutResId);
            rv.setInt(R.id.create_calendar_events, "setColorFilter", theme.textAccent);
            rv.setInt(R.id.create_alarm_clock, "setColorFilter", theme.textAccent);
            rv.setInt(R.id.day_next, "setColorFilter", theme.textAccent);
            rv.setInt(R.id.day_prev, "setColorFilter", theme.textAccent);

            rv.setOnClickPendingIntent(R.id.create_alarm_clock, getPendingSelfIntent(ctx, IntentAction.CreateAlarmClock.action));
            rv.setOnClickPendingIntent(R.id.create_calendar_events, getPendingSelfIntent(ctx, IntentAction.CreateCalendarEvents.action));
            rv.setOnClickPendingIntent(R.id.day_next, getPendingSelfIntent(ctx, IntentAction.DayNext.action));
            rv.setOnClickPendingIntent(R.id.day_prev, getPendingSelfIntent(ctx, IntentAction.DayPrev.action));

            rv.setViewPadding(
                    R.id.widget_title, dateOffset == 0
                            ? (int) WidgetRemoteViewsFactory.dpToPixel(ctx, 16)
                            : 0, 0, 0, 0
            );
            rv.setViewVisibility(R.id.day_prev, dateOffset > 0 ? View.VISIBLE : View.GONE);
            rv.setViewVisibility(R.id.day_next, dateOffset < 6 ? View.VISIBLE : View.GONE);

            rv.setRemoteAdapter(R.id.timeline_list, intent);
            rv.setImageViewBitmap(
                    R.id.empty_view,
                    buildEmptyViewBitmap(ctx, theme)
            );
            rv.setEmptyView(R.id.timeline_list, R.id.empty_view);

        } else {
            rv = new RemoteViews(ctx.getPackageName(), R.layout.widget_no_cache_layout);

            rv.setInt(R.id.widget_no_cache_image, "setBackgroundResource", layoutResId);
            rv.setOnClickPendingIntent(R.id.widget_no_cache_image,
                    PendingIntent.getActivity(
                            ctx,
                            0,
                            new Intent(
                                    ctx,
                                    MainActivity.class
                            ),
                            0
                    )
            );
            rv.setImageViewBitmap(
                    R.id.widget_no_cache_image,
                    buildNoCacheImageBitmap(ctx, theme)
            );
        }

        return rv;
    }

    protected PendingIntent getPendingSelfIntent(Context ctx, String action) {
        var intent = new Intent(ctx, getClass());
        intent.setAction(action);
        return PendingIntent.getBroadcast(ctx, 0, intent, 0);
    }

    @Override
    public void onUpdate(Context ctx, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        log.info("widget onUpdate");

        // Update each of the widgets with the remote adapter
        for (int appWidgetId : appWidgetIds) {
            appWidgetManager.updateAppWidget(
                    appWidgetId,
                    buildLayout(
                            ctx,
                            appWidgetId,
                            appWidgetManager,
                            true
                    )
            );
        }
        super.onUpdate(ctx, appWidgetManager, appWidgetIds);
    }

    @Override
    public void onAppWidgetOptionsChanged(Context ctx, AppWidgetManager appWidgetManager,
                                          int appWidgetId, Bundle newOptions) {
        log.info("widget onAppWidgetOptionsChanged");

        appWidgetManager.updateAppWidget(
                appWidgetId,
                buildLayout(
                        ctx,
                        appWidgetId,
                        appWidgetManager,
                        true
                )
        );

        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.timeline_list);
    }
}