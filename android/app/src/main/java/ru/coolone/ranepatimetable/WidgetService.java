package ru.coolone.ranepatimetable;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import java.util.GregorianCalendar;
import java.util.Locale;

import lombok.extern.java.Log;
import lombok.var;

import static ru.coolone.ranepatimetable.Timeline.COLUMN_DATE;
import static ru.coolone.ranepatimetable.Timeline.COLUMN_FIRST;
import static ru.coolone.ranepatimetable.Timeline.COLUMN_GROUP;
import static ru.coolone.ranepatimetable.Timeline.COLUMN_LAST;
import static ru.coolone.ranepatimetable.Timeline.COLUMN_MERGE_TOP;
import static ru.coolone.ranepatimetable.Timeline.LessonAction;
import static ru.coolone.ranepatimetable.Timeline.LessonModel;
import static ru.coolone.ranepatimetable.Timeline.Location;
import static ru.coolone.ranepatimetable.Timeline.PREFIX_FINISH;
import static ru.coolone.ranepatimetable.Timeline.PREFIX_LESSON;
import static ru.coolone.ranepatimetable.Timeline.PREFIX_ROOM;
import static ru.coolone.ranepatimetable.Timeline.PREFIX_START;
import static ru.coolone.ranepatimetable.Timeline.PREFIX_TEACHER;
import static ru.coolone.ranepatimetable.Timeline.RoomModel;
import static ru.coolone.ranepatimetable.Timeline.TeacherModel;
import static ru.coolone.ranepatimetable.Timeline.TimeOfDayModel;
import static ru.coolone.ranepatimetable.WidgetProvider.RoomLocationStyle.Icon;
import static ru.coolone.ranepatimetable.WidgetProvider.RoomLocationStyle.Text;
import static ru.coolone.ranepatimetable.WidgetProvider.defaultTheme;
import static ru.coolone.ranepatimetable.WidgetProvider.getPrefs;
import static ru.coolone.ranepatimetable.WidgetProvider.widgetSize;

/**
 * This is the service that provides the factory to be bound to the collection service.
 */
public class WidgetService extends RemoteViewsService {
    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new WidgetRemoteViewsFactory(this.getApplicationContext(), intent);
    }
}

/**
 * This is the factory that will provide data to the collection widget.
 */
@Log
class WidgetRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {
    private Context ctx;
    private Cursor cursor;
    private long dateMillis;
    private WidgetProvider.Theme theme;

    public static final String DATE = "date";
    public static final String THEME_PRIMARY = "themePrimary";
    public static final String THEME_ACCENT = "themeAccent";
    public static final String THEME_TEXT_PRIMARY = "themeTextPrimary";
    public static final String THEME_TEXT_ACCENT = "themeTextAccent";
    public static final String THEME_BACKGROUND = "themeBackground";

    public WidgetRemoteViewsFactory(Context ctx, Intent intent) {
        this.ctx = ctx;
        var intentDateMillis = intent.getLongExtra(DATE, -1);
        if (intentDateMillis != -1) dateMillis = intentDateMillis;
        theme = new WidgetProvider.Theme(
                intent.getIntExtra(THEME_PRIMARY, defaultTheme.primary),
                intent.getIntExtra(THEME_ACCENT, defaultTheme.accent),
                intent.getIntExtra(THEME_TEXT_PRIMARY, defaultTheme.textPrimary),
                intent.getIntExtra(THEME_TEXT_ACCENT, defaultTheme.textAccent),
                intent.getIntExtra(THEME_BACKGROUND, defaultTheme.background)
        );
    }

    @Override
    public void onCreate() {
        // Since we reload the cursor in onDataSetChanged() which gets called immediately after
        // onCreate(), we do nothing here.
    }

    @Override
    public void onDestroy() {
        if (cursor != null) {
            cursor.close();
        }
    }

    @Override
    public int getCount() {
        log.info("Widget columns count: " + cursor.getCount());
        return cursor.getCount();
    }

    /**
     * This method converts dp unit to equivalent pixels, depending on device density.
     *
     * @param dp A value in dp (density independent pixels) unit. Which we need to convert into pixels
     * @return A float value to represent px equivalent to dp depending on device density
     */
    static float dpToPixel(Context ctx, float dp) {
        var metrics = ctx.getResources().getDisplayMetrics();
        return dp * ((float) metrics.densityDpi / DisplayMetrics.DENSITY_DEFAULT);
    }

    private static float _dpScale = -1;

    static float dpScale(Context ctx) {
        if (_dpScale == -1) _dpScale = dpToPixel(ctx, 1);
        return _dpScale;
    }

    private static final int rectMargins = 8,
            iconSize = 29,
            circleRadius = 23,
            rectCornersRadius = 10,
            circleMargin = 5,
            circleRadiusAdd = 3;

    private Bitmap buildItemBitmap(Context ctx) {
        var dpScale = dpScale(ctx);

        var w = (widgetSize.first > 0 ? widgetSize.first : 100) * dpScale;
        var h = 80 * dpScale;

        log.info("w: " + w + ", h: " + h);

        var bitmap = Bitmap.createBitmap((int) w, (int) h, Bitmap.Config.ARGB_8888);
        var canvas = new Canvas(bitmap);

        // Background rect draw
        var rect = new RectF(dpScale * rectMargins, dpScale * rectMargins,
                w - rectMargins * dpScale, h);
        var bgRectPaint = new Paint();
        bgRectPaint.setAntiAlias(true);
        bgRectPaint.setColor(theme.background);
        canvas.drawRoundRect(rect, dpScale * rectCornersRadius, dpScale * rectCornersRadius, bgRectPaint);

        var mergeTop = cursor.getInt(cursor.getColumnIndex(COLUMN_MERGE_TOP)) != 0;
        if (mergeTop) {
            var mergePaint = new Paint();
            mergePaint.setAntiAlias(true);
            mergePaint.setColor(Color.argb(
                    Color.alpha(theme.background) / 2,
                    Color.red(theme.background),
                    Color.green(theme.background),
                    Color.blue(theme.background
                    ))
            );
            canvas.drawRect(
                    new RectF(
                            dpScale * rectCornersRadius * 2,
                            0,
                            w - (dpScale * rectCornersRadius * 2),
                            dpScale * rectMargins
                    ),
                    mergePaint
            );
        }

        var first = cursor.getInt(cursor.getColumnIndex(COLUMN_FIRST)) != 0;
        var last = cursor.getInt(cursor.getColumnIndex(COLUMN_LAST)) != 0;

        var circleX = dpScale * (rectMargins * 2 + circleRadius + 68);
        var circleY = h / 2 + dpScale * (rectMargins / 2f);

        var translateIcon = 0.0f;

        if (!(first && last)) {
            var rectPaint = new Paint();
            rectPaint.setAntiAlias(true);
            rectPaint.setColor(theme.accent);

            // Rect round
            if (first || !last) {
                translateIcon = circleMargin;
                circleY -= circleMargin;
                canvas.drawRect(
                        circleX - circleRadius * dpScale, circleY - 1,
                        circleX + circleRadius * dpScale, dpScale * h + 1,
                        rectPaint
                );
            }
            if (last || !first) {
                translateIcon = -circleMargin;
                circleY += circleMargin;
                canvas.drawRect(
                        circleX - circleRadius * dpScale, -1,
                        circleX + circleRadius * dpScale, circleY + 1,
                        rectPaint
                );
            }

            // Arc draw
            var arcRect = new RectF(
                    circleX - circleRadius * dpScale, circleY - circleRadius * dpScale,
                    circleX + circleRadius * dpScale, circleY + circleRadius * dpScale
            );
            var arcPaint = new Paint();
            arcPaint.setAntiAlias(true);
            arcPaint.setColor(theme.accent);

            if (first)
                canvas.drawArc(
                        arcRect,
                        180f,
                        180f,
                        false,
                        arcPaint
                );
            else if (last)
                canvas.drawArc(
                        arcRect,
                        0f,
                        180f,
                        false,
                        arcPaint
                );
        } else {
            // Draw circle
            var circlePaint = new Paint();
            circlePaint.setAntiAlias(true);
            circlePaint.setColor(theme.accent);
            circlePaint.setStyle(Paint.Style.FILL);

            canvas.drawCircle(
                    circleX,
                    circleY,
                    dpScale * (circleRadius + circleRadiusAdd),
                    circlePaint
            );
        }

        // Draw icons
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

        // Draw lesson icon
        iconPaint.setTextSize(dpScale * iconSize);
        iconPaint.setColor(theme.textAccent);
        canvas.drawText(
                String.valueOf(
                        Character.toChars(
                                cursor.getInt(
                                        cursor.getColumnIndex(
                                                PREFIX_LESSON
                                                        + LessonModel.COLUMN_LESSON_ICON)
                                )
                        )
                ), circleX, circleY + dpScale * (10 + translateIcon), iconPaint
        );

        // Draw room location icon
        if (WidgetProvider.RoomLocationStyle.values()[
                (int) getPrefs(ctx).getLong(WidgetProvider.PrefsIds.RoomLocationStyle.prefId, 0)
                ] == Icon) {
            var roomLocation = Location.values()[cursor.getInt(cursor.getColumnIndex(
                    PREFIX_ROOM
                            + RoomModel.COLUMN_ROOM_LOCATION)
            )];
            iconPaint.setColor(theme.textPrimary);
            iconPaint.setTextSize(dpScale * 20);
            canvas.drawText(
                    String.valueOf(
                            Character.toChars(roomLocation.iconCodePoint)
                    ), dpScale * 25, dpScale * 70, iconPaint
            );
        }

        return bitmap;
    }

    private Locale getCurrentLocale() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return ctx.getResources().getConfiguration().getLocales().get(0);
        } else {
            //noinspection deprecation
            return ctx.getResources().getConfiguration().locale;
        }
    }

    @Override
    public RemoteViews getViewAt(int position) {
        var rv = new RemoteViews(ctx.getPackageName(), R.layout.widget_item);

        // Get the data for this position from the content provider
        if (cursor.moveToPosition(position)) {
            var date = new GregorianCalendar();
            date.setTimeInMillis(cursor.getLong(cursor.getColumnIndex(COLUMN_DATE)));

            var start = new TimeOfDayModel(
                    cursor.getInt(cursor.getColumnIndex(PREFIX_START + TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR)),
                    cursor.getInt(cursor.getColumnIndex(PREFIX_START + TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE))
            );
            var finish = new TimeOfDayModel(
                    cursor.getInt(cursor.getColumnIndex(PREFIX_FINISH + TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR)),
                    cursor.getInt(cursor.getColumnIndex(PREFIX_FINISH + TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE))
            );

            rv.setTextViewText(R.id.widget_item_lesson_title,
                    cursor.getString(
                            cursor.getColumnIndex(
                                    PREFIX_LESSON + (
                                            getPrefs(ctx).getBoolean(
                                                    WidgetProvider.PrefsIds.OptimizedLessonTitles.prefId,
                                                    true
                                            )
                                                    ? LessonModel.COLUMN_LESSON_TITLE
                                                    : LessonModel.COLUMN_LESSON_FULL_TITLE
                                    ))));
            var teacherName = cursor.getString(cursor.getColumnIndex(PREFIX_TEACHER + TeacherModel.COLUMN_TEACHER_NAME));
            var teacherSurname = cursor.getString(cursor.getColumnIndex(PREFIX_TEACHER + TeacherModel.COLUMN_TEACHER_SURNAME));
            var teacherPatronymic = cursor.getString(cursor.getColumnIndex(PREFIX_TEACHER + TeacherModel.COLUMN_TEACHER_PATRONYMIC));
            var group = cursor.getString(cursor.getColumnIndex(COLUMN_GROUP));
            var user = WidgetProvider.SearchItemTypeId.values()[(int) getPrefs(ctx).getLong(
                    WidgetProvider.PrefsIds.PrimarySearchItemPrefix.prefId +
                            WidgetProvider.PrefsIds.ItemType.prefId,
                    -1
            )];
            rv.setTextViewText(R.id.widget_item_teacher_or_group,
                    user == WidgetProvider.SearchItemTypeId.Group
                            ? teacherSurname + ' ' + teacherName.charAt(0) + ". " + teacherPatronymic.charAt(0) + '.'
                            : group);
            rv.setTextViewText(R.id.widget_item_start, String.format(getCurrentLocale(), "%d:%02d", start.hour, start.minute));
            rv.setTextViewText(R.id.widget_item_finish, String.format(getCurrentLocale(), "%d:%02d", finish.hour, finish.minute));

            var prefix = "";
            var roomLocationStyle = WidgetProvider.RoomLocationStyle.values()[
                    (int) getPrefs(ctx).getLong(WidgetProvider.PrefsIds.RoomLocationStyle.prefId, 0)
                    ];
            switch (roomLocationStyle) {
                case Icon:
                    rv.setViewPadding(R.id.widget_item_room_number,
                            (int) dpToPixel(ctx, 22),
                            0, 0, 0
                    );
                    break;
                case Text:
                    switch (Location.values()[cursor.getInt(cursor.getColumnIndex(
                            PREFIX_ROOM
                                    + RoomModel.COLUMN_ROOM_LOCATION))]) {
                        case Hotel:
                            prefix = "П8-";
                            break;
                        case StudyHostel:
                            prefix = "СО-";
                            break;
                    }
                    break;
            }
            rv.setTextViewText(R.id.widget_item_room_number,
                    prefix + cursor.getString(cursor.getColumnIndex(
                            PREFIX_ROOM
                                    + RoomModel.COLUMN_ROOM_NUMBER)
                    ));
            var action = cursor.getString(
                    cursor.getColumnIndex(
                            PREFIX_LESSON
                                    + LessonModel.PREFIX_LESSON_ACTION
                                    + LessonAction.COLUMN_LESSON_TYPE_TITLE
                    ));
            if (action == null)
                rv.setViewVisibility(R.id.widget_item_lesson_action, View.GONE);
            else
                rv.setTextViewText(R.id.widget_item_lesson_action, action);

            rv.setTextColor(R.id.widget_item_lesson_action, theme.textPrimary);
            rv.setTextColor(R.id.widget_item_lesson_title, theme.textPrimary);
            rv.setTextColor(R.id.widget_item_teacher_or_group, theme.textPrimary);
            rv.setTextColor(R.id.widget_item_start, theme.textPrimary);
            rv.setTextColor(R.id.widget_item_finish, theme.textPrimary);
            rv.setTextColor(R.id.widget_item_room_number, theme.textPrimary);

            rv.setImageViewBitmap(
                    R.id.widget_item_image,
                    buildItemBitmap(ctx)
            );
        }

        return rv;
    }

    @Override
    public RemoteViews getLoadingView() {
        // We aren't going to return a default loading view in this sample
        return null;
    }

    @Override
    public int getViewTypeCount() {
        // Technically, we have two types of views (the dark and light background views)
        return 2;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public void onDataSetChanged() {
        // Refresh the cursor
        if (cursor != null) {
            cursor.close();
        }
        log.info("Database cursor refresh...");
        cursor = TimetableDatabase.getInstance(ctx).timetable().selectByDate(dateMillis);
    }
}