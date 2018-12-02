package ru.coolone.ranepatimetable;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.support.annotation.NonNull;

import java.util.ArrayList;
import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.var;

/**
 * A dummy class that we are going to use internally to store weather data.  Generally, this data
 * will be stored in an external and persistent location (ie. File, Database, SharedPreferences) so
 * that the data can persist if the process is ever killed.  For simplicity, in this sample the
 * data will only be stored in memory.
 */
@AllArgsConstructor
class TeacherModel {
    final String name, surname, patronymic;
}

@AllArgsConstructor
class TimeOfDayModel {
    final int hour, minute;
}

@AllArgsConstructor
class LessonModel {
    final String title;
    final int iconCodePoint;
}

@AllArgsConstructor
class TimelineDataModel {
    final LessonModel lesson;
    final int room;

    final Date date;

    final String group;
    final TeacherModel teacher;

    final TimeOfDayModel start, finish;
}

/**
 * The AppWidgetProvider for our sample weather widget.
 */
public class TimetableDataProvider extends ContentProvider {
    public static final Uri CONTENT_URI =
            Uri.parse("content://ru.coolone.ranepatimetable.provider");

    @AllArgsConstructor
    public enum Columns {
        ID("_id"),
        LESSON_TITLE("lesson_title"),
        LESSON_ICON("lesson_icon"),
        ROOM("room"),
        DATE("date"),
        GROUP("group"),
        TEACHER_NAME("teacher_name"),
        TEACHER_SURNAME("teacher_surname"),
        TEACHER_PATRONYMIC("teacher_patronymic"),
        START_HOUR("start_hour"),
        START_MINUTE("start_minute"),
        FINISH_HOUR("finish_hour"),
        FINISH_MINUTE("finish_minute");

        private final String text;

        @Override
        public String toString() {
            return text;
        }

        static final String[] strValues = new String[Columns.values().length];

        static {
            for (int mColumnId = 0; mColumnId < values().length; mColumnId++)
                strValues[mColumnId] = values()[mColumnId].toString();
        }
    }

    /**
     * Generally, this data will be stored in an external and persistent location (ie. File,
     * Database, SharedPreferences) so that the data can persist if the process is ever killed.
     * For simplicity, in this sample the data will only be stored in memory.
     */
    private static final ArrayList<TimelineDataModel> sData = new ArrayList<>();

    @Override
    public boolean onCreate() {
        // We are going to initialize the data provider with some default values
        sData.add(new TimelineDataModel(
                        new LessonModel("Lesson one", 123),
                        431,
                        new Date(),
                        "group11",
                        new TeacherModel("DFsdfs", "snm", "sanich"),
                        new TimeOfDayModel(9, 12),
                        new TimeOfDayModel(11, 12)
                )
        );

        sData.add(new TimelineDataModel(
                        new LessonModel("Lesson two", 321),
                        112,
                        new Date(),
                        "group11",
                        new TeacherModel("Name", "snm", "sanich"),
                        new TimeOfDayModel(12, 12),
                        new TimeOfDayModel(13, 12)
                )
        );

        return true;
    }

    @Override
    public synchronized Cursor query(@NonNull Uri uri, String[] projection, String selection,
                                     String[] selectionArgs, String sortOrder) {
        var c = new MatrixCursor(Columns.strValues);
        for (int i = 0; i < sData.size(); ++i) {
            var data = sData.get(i);
            c.addRow(new Object[]{
                    i,
                    data.lesson.title,
                    data.lesson.iconCodePoint,
                    data.room,
                    data.date.toString(),
                    data.group,
                    data.teacher.name,
                    data.teacher.surname,
                    data.teacher.patronymic,
                    data.start.hour,
                    data.start.minute,
                    data.finish.hour,
                    data.finish.minute
            });
        }
        return c;
    }

    @Override
    public String getType(Uri uri) {
        return "vnd.android.cursor.dir/vnd.timetablewidget.timeline";
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        // This example code does not support inserting
        return null;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        // This example code does not support deleting
        return 0;
    }

    @Override
    public synchronized int update(Uri uri, ContentValues values, String selection,
                                   String[] selectionArgs) {
//        assert (uri.getPathSegments().size() == 1);
//        // In this sample, we only update the content provider individually for each row with new
//        // temperature values.
//        var index = Integer.parseInt(uri.getPathSegments().get(0));
//        var c = new MatrixCursor(Columns.strValues);
//        assert (0 <= index && index < sData.size());
//        var data = sData.get(index);
//        data.degrees = values.getAsInteger(Columns.TEMPERATURE);
//        // Notify any listeners that the data backing the content provider has changed, and return
//        // the number of rows affected.
//        getContext().getContentResolver().notifyChange(uri, null);
        return 0; //1
    }
}