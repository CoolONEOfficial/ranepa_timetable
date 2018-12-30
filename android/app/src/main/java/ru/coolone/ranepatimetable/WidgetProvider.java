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
import android.support.v4.app.ActivityCompat;
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

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.java.Log;
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

    AlarmManager manager;
    PendingIntent updatePendingIntent, deleteOldPendingIntent;

    static private int dateOffset;

    enum SearchItemTypeId {Teacher, Group}

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
                            buildLayout(ctx, mId, AppWidgetManager.getInstance(ctx))
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
                dateOffset += Objects.equals(intent.getAction(), IntentAction.DayNext.action) ? 1 : -1;

                now = GregorianCalendar.getInstance();
                now.add(Calendar.DATE, dateOffset);
            } while (now.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY);
            refreshWidget(ctx);
        }

        super.onReceive(ctx, intent);
    }

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

    enum PrefsIds {
        WidgetTranslucent("widget_translucent"),
        ThemeId("theme_id"),
        BeforeAlarmClock("before_alarm_clock"),
        EndCache("end_cache"),

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

    static Bitmap buildEmptyViewBitmap(Context context, Theme theme) {
        var type = SearchItemTypeId.values()[
                (int) getPrefs(context).getLong(
                        PrefsIds.PrimarySearchItemPrefix.prefId + PrefsIds.ItemType.prefId,
                        0
                )
                ];

        var BEER = '\ue838';
        var CONFETTI = '\ue839';

        return buildNotificationBitmap(
                context,
                theme,
                type == SearchItemTypeId.Teacher
                        ? CONFETTI
                        : BEER,
                context.getString(R.string.freeDay),
                9
        );
    }

    static Bitmap buildNoCacheImageBitmap(Context context, Theme theme) {
        var NO_CACHE = '\ue826';

        return buildNotificationBitmap(
                context,
                theme,
                NO_CACHE,
                context.getString(R.string.noCache),
                14,
                0
        );
    }

    static Bitmap buildNotificationBitmap(
            Context context,
            Theme theme,
            char icon,
            String notification,
            int textScale
    ) {
        return buildNotificationBitmap(
                context,
                theme,
                icon,
                notification,
                textScale,
                context.getResources().getDimension(R.dimen.widget_head_height) / dpScale(context)
        );
    }

    static Bitmap buildNotificationBitmap(
            Context context,
            Theme theme,
            char icon,
            String notification,
            int textScale,
            float headHeight
    ) {
        var dpScale = dpScale(context);

        var bitmap = Bitmap.createBitmap((int) (widgetSize.first * dpScale), (int) (widgetSize.second * dpScale), Bitmap.Config.ARGB_8888);
        var canvas = new Canvas(bitmap);

        var iconPaint = new Paint();
        iconPaint.setAntiAlias(true);
        iconPaint.setSubpixelText(true);
        iconPaint.setTextAlign(Paint.Align.CENTER);
        iconPaint.setTypeface(
                Typeface.createFromAsset(
                        context.getAssets(),
                        "fonts/TimetableIcons.ttf"
                )
        );

        iconPaint.setTextSize(dpScale * (Math.min(widgetSize.first, widgetSize.second) / 3));
        iconPaint.setColor(theme.textAccent);

        canvas.drawText(
                String.valueOf(icon),
                (widgetSize.first / 2) * dpScale,
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
                                Math.min(widgetSize.first, widgetSize.second) / 4
                        )
        ) * dpScale;
        for (var line : notification.split("\n")) {
            canvas.drawText(
                    line,
                    (widgetSize.first / 2) * dpScale,
                    mTextY,
                    textPaint
            );
            mTextY += textPaint.descent() - textPaint.ascent();
        }

        return bitmap;
    }

    private Pair<Integer, Integer> getWidgetSize(
            Context context,
            int appWidgetId,
            AppWidgetManager manager
    ) {

        AppWidgetProviderInfo providerInfo = AppWidgetManager.getInstance(
                context.getApplicationContext()).getAppWidgetInfo(appWidgetId);

        // Since min and max is usually the same, just take min
        var mWidgetLandSize = new Pair<>(providerInfo.minWidth, providerInfo.minHeight);
        var mWidgetPortSize = new Pair<>(providerInfo.minWidth, providerInfo.minHeight);

        Bundle mAppWidgetOptions = manager.getAppWidgetOptions(appWidgetId);

        if (mAppWidgetOptions
                .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) > 0) {

            mWidgetPortSize = new Pair<>(mAppWidgetOptions
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH), mAppWidgetOptions
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT));

            mWidgetLandSize = new Pair<>(mAppWidgetOptions
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH), mAppWidgetOptions
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT));
        }

        log.info(
                "Dimensions of the Widget in DIP: "
                        + ", landWidth = " + mWidgetLandSize.first
                        + ", landHeight = " + mWidgetLandSize.second
                        + ", portWidth = " + mWidgetPortSize.first
                        + ", portHeight = " + mWidgetPortSize.second
        );

        return context.getResources().getBoolean(R.bool.isPort) ? mWidgetPortSize : mWidgetLandSize;
    }

    public static Pair<Integer, Integer> widgetSize = new Pair<>(0, 0);

    private RemoteViews buildLayout(Context context, int appWidgetId, AppWidgetManager manager) {
        theme = Theme.values()[(int) getPrefs(context).getLong(PrefsIds.ThemeId.prefId, DEFAULT_THEME_ID)];

        // Set the size
        widgetSize = getWidgetSize(context, appWidgetId, manager);

        // Get rounded background layout ids

        int bodyLayoutResId = -1;
        int headLayoutResId = -1;
        int layoutResId = -1;

        var translucent = getPrefs(context).getBoolean(PrefsIds.WidgetTranslucent.prefId, true);

        switch (theme) {
            case Dark:
            case DarkRed:
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
            case LightRed:
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

        if (TimetableDatabase.getInstance(context).timetable().count() != 0) {

            rv = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

            var futureLessonFindDate = getTodayMidnight();
            futureLessonFindDate.add(Calendar.DATE, dateOffset);

            String dayOfWeek = null;
            switch (futureLessonFindDate.get(Calendar.DAY_OF_WEEK)) {
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

            var dayDescStr = context.getString(dayDescId);
            if (dateOffset > 2)
                dayDescStr = String.format(dayDescStr, dateOffset);

            rv.setTextViewText(R.id.widget_title,
                    dayOfWeek + ", " + dayDescStr
            );
            rv.setTextColor(R.id.widget_title, theme.textAccent);

            // Specify the service to provide data for the collection widget.  Note that we need to
            // embed the appWidgetId via the data otherwise it will be ignored.
            var intent = new Intent(context, WidgetService.class);
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            var futureLessonDate = GregorianCalendar.getInstance();
            futureLessonDate.setTimeInMillis(
                    futureLessonFindDate.getTimeInMillis()
            );
            showDate = getMidnight(futureLessonDate).getTimeInMillis();
            intent.putExtra(WidgetRemoteViewsFactory.DATE, showDate);
            intent.putExtra(WidgetRemoteViewsFactory.THEME_ID, theme.ordinal());
            intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

            rv.setInt(R.id.widget_body, "setBackgroundResource", bodyLayoutResId);
            rv.setInt(R.id.widget_head, "setBackgroundResource", headLayoutResId);
            rv.setInt(R.id.create_calendar_events, "setColorFilter", theme.textAccent);
            rv.setInt(R.id.create_alarm_clock, "setColorFilter", theme.textAccent);
            rv.setInt(R.id.day_next, "setColorFilter", theme.textAccent);
            rv.setInt(R.id.day_prev, "setColorFilter", theme.textAccent);

            rv.setOnClickPendingIntent(R.id.create_alarm_clock, getPendingSelfIntent(context, IntentAction.CreateAlarmClock.action));
            rv.setOnClickPendingIntent(R.id.create_calendar_events, getPendingSelfIntent(context, IntentAction.CreateCalendarEvents.action));
            rv.setOnClickPendingIntent(R.id.day_next, getPendingSelfIntent(context, IntentAction.DayNext.action));
            rv.setOnClickPendingIntent(R.id.day_prev, getPendingSelfIntent(context, IntentAction.DayPrev.action));

            rv.setViewPadding(
                    R.id.widget_title, dateOffset == 0
                            ? (int) WidgetRemoteViewsFactory.dpToPixel(context, 16)
                            : 0, 0, 0, 0
            );
            rv.setViewVisibility(R.id.day_prev, dateOffset > 0 ? View.VISIBLE : View.GONE);
            rv.setViewVisibility(R.id.day_next, dateOffset < 7 ? View.VISIBLE : View.GONE);

            rv.setRemoteAdapter(R.id.timeline_list, intent);
            rv.setImageViewBitmap(
                    R.id.empty_view,
                    buildEmptyViewBitmap(context, theme)
            );
            rv.setEmptyView(R.id.timeline_list, R.id.empty_view);

        } else {
            rv = new RemoteViews(context.getPackageName(), R.layout.widget_no_cache_layout);

            rv.setInt(R.id.widget_no_cache_image, "setBackgroundResource", layoutResId);
            rv.setOnClickPendingIntent(R.id.widget_no_cache_image,
                    PendingIntent.getActivity(
                            context,
                            0,
                            new Intent(
                                    context,
                                    MainActivity.class
                            ),
                            0
                    )
            );
            rv.setImageViewBitmap(
                    R.id.widget_no_cache_image,
                    buildNoCacheImageBitmap(context, theme)
            );
        }

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