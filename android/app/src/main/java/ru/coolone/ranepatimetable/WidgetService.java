package ru.coolone.ranepatimetable;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Bundle;

import lombok.AllArgsConstructor;
import lombok.extern.java.Log;

import android.util.DisplayMetrics;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;

import lombok.var;

import static ru.coolone.ranepatimetable.WidgetProvider.width;

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
    private Context context;
    private Cursor cursor;
    private long dateMillis;
    private WidgetProvider.Theme theme;

    public static final String DATE = "date";
    public static final String THEME_ID = "themeId";

    public WidgetRemoteViewsFactory(Context context, Intent intent) {
        this.context = context;
        var intentDateMillis = intent.getLongExtra(DATE, -1);
        if (intentDateMillis != -1) dateMillis = intentDateMillis;
        var themeId = intent.getIntExtra(THEME_ID, WidgetProvider.DEFAULT_THEME_ID);
        theme = WidgetProvider.Theme.values()[themeId];
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
        log.severe("Widget columns count: " + cursor.getCount());
        return cursor.getCount();
    }

    /**
     * This method converts dp unit to equivalent pixels, depending on device density.
     *
     * @param dp A value in dp (density independent pixels) unit. Which we need to convert into pixels
     * @return A float value to represent px equivalent to dp depending on device density
     */
    private float dpToPixel(float dp) {
        var metrics = context.getResources().getDisplayMetrics();
        return dp * ((float) metrics.densityDpi / DisplayMetrics.DENSITY_DEFAULT);
    }

    private static final int rectMargins = 8,
            iconSize = 29,
            circleRadius = 23,
            rectRound = 5,
            circleMargin = 5;

    private Bitmap buildItemBitmap(Context context, float w, float h) {
        log.severe("w: " + w + ", h: " + h);

        var dpScale = dpToPixel(1);
        w *= dpScale;
        h *= dpScale;

        var bitmap = Bitmap.createBitmap((int) w, (int) h, Bitmap.Config.ARGB_8888);
        var canvas = new Canvas(bitmap);

        // Background rect draw
        var rect = new RectF(dpScale * rectMargins, dpScale * rectMargins,
                w - rectMargins * dpScale, h);
        var bgRectPaint = new Paint();
        bgRectPaint.setAntiAlias(true);
        bgRectPaint.setColor(theme.background);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            canvas.drawRoundRect(rect, dpScale * rectRound, dpScale * rectRound, bgRectPaint);
        else canvas.drawRect(rect, bgRectPaint);

        var first = cursor.getInt(cursor.getColumnIndex(Timeline.COLUMN_FIRST)) != 0;
        var last = cursor.getInt(cursor.getColumnIndex(Timeline.COLUMN_LAST)) != 0;

        var circleX = dpScale * (rectMargins * 2 + 70 + circleRadius);
        var circleY = dpScale * ((80 + rectMargins) / 2);

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
                    dpScale * (circleRadius + 3),
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
                        context.getAssets(),
                        "fonts/TimetableIcons.ttf"
                )
        );

        // Draw lesson icon
        iconPaint.setTextSize(dpScale * iconSize);
        iconPaint.setColor(theme.textPrimary);
        canvas.drawText(
                String.valueOf(
                        Character.toChars(
                                cursor.getInt(
                                        cursor.getColumnIndex(
                                                Timeline.PREFIX_LESSON
                                                        + Timeline.LessonModel.COLUMN_LESSON_ICON)
                                )
                        )
                ), circleX, circleY + dpScale * (10 + translateIcon), iconPaint
        );

        // Draw room location icon
        var roomLocation = Timeline.Location.values()[cursor.getInt(cursor.getColumnIndex(
                Timeline.PREFIX_ROOM
                        + Timeline.RoomModel.COLUMN_ROOM_LOCATION)
        )];
        iconPaint.setColor(theme.textAccent);
        iconPaint.setTextSize(dpScale * 20);
        canvas.drawText(
                String.valueOf(
                        Character.toChars(roomLocation.iconCodePoint)
                ), dpScale * 25, dpScale * 70, iconPaint
        );

        return bitmap;
    }

    Locale getCurrentLocale() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return context.getResources().getConfiguration().getLocales().get(0);
        } else {
            //noinspection deprecation
            return context.getResources().getConfiguration().locale;
        }
    }

    @Override
    public RemoteViews getViewAt(int position) {
        var rv = new RemoteViews(context.getPackageName(), R.layout.widget_item);

        // Get the data for this position from the content provider
        if (cursor.moveToPosition(position)) {
            var date = new GregorianCalendar();
            date.setTimeInMillis(cursor.getLong(cursor.getColumnIndex(Timeline.COLUMN_DATE)));

            var start = new Timeline.TimeOfDayModel(
                    cursor.getInt(cursor.getColumnIndex(Timeline.PREFIX_START + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR)),
                    cursor.getInt(cursor.getColumnIndex(Timeline.PREFIX_START + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE))
            );
            var finish = new Timeline.TimeOfDayModel(
                    cursor.getInt(cursor.getColumnIndex(Timeline.PREFIX_FINISH + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR)),
                    cursor.getInt(cursor.getColumnIndex(Timeline.PREFIX_FINISH + Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE))
            );

            rv.setTextViewText(R.id.widget_item_lesson_title,
                    cursor.getString(
                            cursor.getColumnIndex(
                                    Timeline.PREFIX_LESSON
                                            + Timeline.LessonModel.COLUMN_LESSON_TITLE
                            )
                    )
            );
            var teacherName = cursor.getString(cursor.getColumnIndex(Timeline.PREFIX_TEACHER + Timeline.TeacherModel.COLUMN_TEACHER_NAME));
            var teacherSurname = cursor.getString(cursor.getColumnIndex(Timeline.PREFIX_TEACHER + Timeline.TeacherModel.COLUMN_TEACHER_SURNAME));
            var teacherPatronymic = cursor.getString(cursor.getColumnIndex(Timeline.PREFIX_TEACHER + Timeline.TeacherModel.COLUMN_TEACHER_PATRONYMIC));
            var group = cursor.getString(cursor.getColumnIndex(Timeline.COLUMN_GROUP));
            var user = Timeline.User.values()[cursor.getInt(cursor.getColumnIndex(Timeline.COLUMN_USER))];
            rv.setTextViewText(R.id.widget_item_teacher_or_group,
                    user == Timeline.User.Teacher
                            ? group
                            : teacherSurname + ' ' + teacherName.charAt(0) + ". " + teacherPatronymic.charAt(0) + '.');
            rv.setTextViewText(R.id.widget_item_start, String.format(getCurrentLocale(), "%d:%02d", start.hour, start.minute));
            rv.setTextViewText(R.id.widget_item_finish, String.format(getCurrentLocale(), "%d:%02d", finish.hour, finish.minute));
            rv.setTextViewText(R.id.widget_item_room_number, String.valueOf(
                    cursor.getString(cursor.getColumnIndex(
                            Timeline.PREFIX_ROOM
                                    + Timeline.RoomModel.COLUMN_ROOM_NUMBER)
                    )));

            rv.setTextColor(R.id.widget_item_lesson_title, theme.textAccent);
            rv.setTextColor(R.id.widget_item_teacher_or_group, theme.textAccent);
            rv.setTextColor(R.id.widget_item_start, theme.textAccent);
            rv.setTextColor(R.id.widget_item_finish, theme.textAccent);
            rv.setTextColor(R.id.widget_item_room_number, theme.textAccent);

            rv.setImageViewBitmap(
                    R.id.widget_item_image,
                    buildItemBitmap(
                            context,
                            width,
                            80
                    )
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
        cursor = TimetableDatabase.getInstance(context).timetable().selectByDate(dateMillis);
    }
}