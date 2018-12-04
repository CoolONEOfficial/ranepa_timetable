package ru.coolone.ranepatimetable;

import android.arch.persistence.room.ColumnInfo;
import android.arch.persistence.room.Embedded;
import android.arch.persistence.room.Entity;
import android.arch.persistence.room.PrimaryKey;
import android.arch.persistence.room.TypeConverter;
import android.arch.persistence.room.TypeConverters;
import android.content.ContentValues;
import android.provider.BaseColumns;

import java.sql.Date;

import lombok.AllArgsConstructor;

import static ru.coolone.ranepatimetable.Timeline.LessonModel.COLUMN_LESSON_ICON;
import static ru.coolone.ranepatimetable.Timeline.LessonModel.COLUMN_LESSON_TITLE;
import static ru.coolone.ranepatimetable.Timeline.RoomModel.COLUMN_ROOM_LOCATION;
import static ru.coolone.ranepatimetable.Timeline.RoomModel.COLUMN_ROOM_NUMBER;
import static ru.coolone.ranepatimetable.Timeline.TeacherModel.COLUMN_TEACHER_NAME;
import static ru.coolone.ranepatimetable.Timeline.TeacherModel.COLUMN_TEACHER_PATRONYMIC;
import static ru.coolone.ranepatimetable.Timeline.TeacherModel.COLUMN_TEACHER_SURNAME;
import static ru.coolone.ranepatimetable.Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_HOUR;
import static ru.coolone.ranepatimetable.Timeline.TimeOfDayModel.COLUMN_TIMEOFDAY_MINUTE;

/**
 * Represents one record of the Timeline table.
 */
@AllArgsConstructor
@Entity(tableName = Timeline.TABLE_NAME)
public class Timeline {

    enum Location {
        Academy,
        Hotel,
        StudyHostel
    }

    @AllArgsConstructor
    static public class TeacherModel {
        public static final String COLUMN_TEACHER_NAME = "name";
        public static final String COLUMN_TEACHER_SURNAME = "surname";
        public static final String COLUMN_TEACHER_PATRONYMIC = "patronymic";

        final String name, surname, patronymic;
    }

    @AllArgsConstructor
    static public class TimeOfDayModel {
        public static final String COLUMN_TIMEOFDAY_HOUR = "hour";
        public static final String COLUMN_TIMEOFDAY_MINUTE = "minute";

        final int hour, minute;
    }

    @AllArgsConstructor
    static public class LessonModel {
        public static final String COLUMN_LESSON_TITLE = "title";
        public static final String COLUMN_LESSON_ICON = "iconCodePoint";

        final String title;
        final int iconCodePoint;
    }

    @AllArgsConstructor
    static public class RoomModel {
        public static final String COLUMN_ROOM_NUMBER = "number";
        public static final String COLUMN_ROOM_LOCATION = "location";

        final int number;

        @TypeConverters(Timeline.class)
        final Location location;
    }

    /**
     * The name of the Timeline table.
     */
    public static final String TABLE_NAME = "timelines";

    public static final String COLUMN_ID = BaseColumns._ID;
    public static final String COLUMN_DATE = "date";
    public static final String COLUMN_GROUP = "group";
    public static final String COLUMN_FIRST = "first";
    public static final String COLUMN_LAST = "last";

    public static final String PREFIX_LESSON = "lesson_";
    public static final String PREFIX_ROOM = "room_";
    public static final String PREFIX_TEACHER = "teacher_";
    public static final String PREFIX_START = "start_";
    public static final String PREFIX_FINISH = "finish_";

    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(index = true, name = COLUMN_ID)
    public long id;

    @Embedded(prefix = PREFIX_LESSON)
    final LessonModel lesson;

    @Embedded(prefix = PREFIX_ROOM)
    final RoomModel room;

    @ColumnInfo(name = COLUMN_DATE)
    @TypeConverters(Timeline.class)
    final Date date;

    @ColumnInfo(name = COLUMN_GROUP)
    final String group;

    @ColumnInfo(name = COLUMN_FIRST)
    final boolean first;

    @ColumnInfo(name = COLUMN_LAST)
    final boolean last;

    @Embedded(prefix = PREFIX_TEACHER)
    final TeacherModel teacher;

    @Embedded(prefix = PREFIX_START)
    final TimeOfDayModel start;

    @Embedded(prefix = PREFIX_FINISH)
    final TimeOfDayModel finish;

    @TypeConverter
    public static Date toDate(Long dateLong) {
        return dateLong == null ? null : new Date(dateLong);
    }

    @TypeConverter
    public static Long fromDate(Date date) {
        return date == null ? null : date.getTime();
    }

    @TypeConverter
    public static Location toLocation(int numeral) {
        return Location.values()[numeral];
    }

    @TypeConverter
    public static int fromLocation(Location status) {
        return status.ordinal();
    }
}