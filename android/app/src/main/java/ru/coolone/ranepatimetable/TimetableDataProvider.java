package ru.coolone.ranepatimetable;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.support.annotation.NonNull;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.SneakyThrows;
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
class RoomModel {
    enum Location {
        Academy,
        Hotel,
        StudyHostel
    }

    final int number;
    final Location location;
}


@AllArgsConstructor
class TimelineModel {
    final LessonModel lesson;
    final RoomModel room;

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
        ROOM_NUMBER("room_number"),
        ROOM_LOCATION("room_location"),
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
    private static final ArrayList<TimelineModel> sData = new ArrayList<>();

    @Override
    public boolean onCreate() {
        // We are going to initialize the data provider with some default values
        sData.add(new TimelineModel(
                        new LessonModel("Lesson one", 123),
                        new RoomModel(432, RoomModel.Location.Academy),
                        new Date(),
                        "group11",
                        new TeacherModel("DFsdfs", "snm", "sanich"),
                        new TimeOfDayModel(9, 12),
                        new TimeOfDayModel(11, 12)
                )
        );

        sData.add(new TimelineModel(
                        new LessonModel("Lesson two", 321),
                        new RoomModel(12, RoomModel.Location.StudyHostel),
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
    @SneakyThrows
    public Uri insert(Uri uri, ContentValues values) {

        sData.add(
                new TimelineModel(
                        new LessonModel(
                                values.getAsString(Columns.LESSON_TITLE.text),
                                values.getAsInteger(Columns.LESSON_ICON.text)
                        ),
                        new RoomModel(
                                values.getAsInteger(Columns.ROOM_NUMBER.text),
                                RoomModel.Location.valueOf(values.getAsString(Columns.ROOM_LOCATION.text))
                        ),
                        DateFormat.getDateTimeInstance().parse(values.getAsString(Columns.DATE.text)),
                        values.getAsString(Columns.GROUP.text),
                        new TeacherModel(
                                values.getAsString(Columns.TEACHER_NAME.text),
                                values.getAsString(Columns.TEACHER_SURNAME.text),
                                values.getAsString(Columns.TEACHER_PATRONYMIC.text)
                        ),
                        new TimeOfDayModel(
                                values.getAsInteger(Columns.START_HOUR.text),
                                values.getAsInteger(Columns.START_MINUTE.text)
                        ),
                        new TimeOfDayModel(
                                values.getAsInteger(Columns.FINISH_HOUR.text),
                                values.getAsInteger(Columns.FINISH_MINUTE.text)
                        )

                )
        );

        // This example code does not support inserting
        return null;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        sData.clear();
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