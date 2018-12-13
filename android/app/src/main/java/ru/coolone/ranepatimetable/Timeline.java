package ru.coolone.ranepatimetable;

import android.arch.persistence.room.ColumnInfo;
import android.arch.persistence.room.Embedded;
import android.arch.persistence.room.Entity;
import android.arch.persistence.room.PrimaryKey;
import android.arch.persistence.room.TypeConverter;
import android.arch.persistence.room.TypeConverters;
import android.content.ContentValues;
import android.provider.BaseColumns;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

/**
 * Represents one record of the Timeline table.
 */
@NoArgsConstructor
@AllArgsConstructor
@Entity(tableName = Timeline.TABLE_NAME)
public class Timeline {

    @NoArgsConstructor
    @AllArgsConstructor
    public enum Location {
        Academy(0xe81b),
        Hotel(0xe801),
        StudyHostel(0xe802);

        int iconCodePoint;
    }

    public enum User {Student, Teacher}

    public enum LessonType {None, Theory, Practice}

    @NoArgsConstructor
    @AllArgsConstructor
    static public class TeacherModel {
        public static final String COLUMN_TEACHER_NAME = "name";
        public static final String COLUMN_TEACHER_SURNAME = "surname";
        public static final String COLUMN_TEACHER_PATRONYMIC = "patronymic";

        String name, surname, patronymic;

        public static TeacherModel fromContentValues(ContentValues values, String prefix) {
            return new TeacherModel(
                    values.getAsString(prefix + COLUMN_TEACHER_NAME),
                    values.getAsString(prefix + COLUMN_TEACHER_SURNAME),
                    values.getAsString(prefix + COLUMN_TEACHER_PATRONYMIC)
            );
        }
    }

    @NoArgsConstructor
    @AllArgsConstructor
    static public class TimeOfDayModel {
        public static final String COLUMN_TIMEOFDAY_HOUR = "hour";
        public static final String COLUMN_TIMEOFDAY_MINUTE = "minute";

        int hour, minute;

        public static TimeOfDayModel fromContentValues(ContentValues values, String prefix) {
            return new TimeOfDayModel(
                    values.getAsInteger(prefix + COLUMN_TIMEOFDAY_HOUR),
                    values.getAsInteger(prefix + COLUMN_TIMEOFDAY_MINUTE)
            );
        }
    }

    @AllArgsConstructor
    @NoArgsConstructor
    static public class LessonModel {
        public static final String COLUMN_LESSON_TITLE = "title";
        public static final String COLUMN_LESSON_ICON = "iconCodePoint";
        public static final String COLUMN_LESSON_TYPE = "lessonType";

        String title;
        int iconCodePoint;
        @TypeConverters(LessonModel.class)
        LessonType lessonType;

        public static LessonModel fromContentValues(ContentValues values, String prefix) {
            return new LessonModel(
                    values.getAsString(prefix + COLUMN_LESSON_TITLE),
                    values.getAsInteger(prefix + COLUMN_LESSON_ICON),
                    LessonType.values()[values.getAsInteger(prefix + COLUMN_LESSON_TYPE)]
            );
        }

        @TypeConverter
        public static LessonType toLessonType(int numeral) {
            return LessonType.values()[numeral];
        }

        @TypeConverter
        public static int fromLessonType(LessonType type) {
            return type.ordinal();
        }
    }

    @NoArgsConstructor
    @AllArgsConstructor
    static public class RoomModel {
        public static final String COLUMN_ROOM_NUMBER = "number";
        public static final String COLUMN_ROOM_LOCATION = "location";

        String number;

        @TypeConverters(RoomModel.class)
        Location location;

        public static RoomModel fromContentValues(ContentValues values, String prefix) {
            return new RoomModel(
                    values.getAsString(prefix + COLUMN_ROOM_NUMBER),
                    Location.values()[values.getAsInteger(prefix + COLUMN_ROOM_LOCATION)]
            );
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

    /**
     * The name of the Timeline table.
     */
    public static final String TABLE_NAME = "timelines";

    public static final String COLUMN_ID = BaseColumns._ID;
    public static final String COLUMN_DATE = "date";
    public static final String COLUMN_GROUP = "group";
    public static final String COLUMN_FIRST = "first";
    public static final String COLUMN_LAST = "last";
    public static final String COLUMN_USER = "user";

    public static final String PREFIX_LESSON = "lesson_";
    public static final String PREFIX_ROOM = "room_";
    public static final String PREFIX_TEACHER = "teacher_";
    public static final String PREFIX_START = "start_";
    public static final String PREFIX_FINISH = "finish_";

    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(index = true, name = COLUMN_ID)
    public long id;

    @Embedded(prefix = PREFIX_LESSON)
    LessonModel lesson;

    @Embedded(prefix = PREFIX_ROOM)
    RoomModel room;

    @ColumnInfo(name = COLUMN_DATE)
    @TypeConverters(Timeline.class)
    Date date;

    @ColumnInfo(name = COLUMN_USER)
    @TypeConverters(Timeline.class)
    User user;

    @ColumnInfo(name = COLUMN_GROUP)
    String group;

    @ColumnInfo(name = COLUMN_FIRST)
    boolean first;

    @ColumnInfo(name = COLUMN_LAST)
    boolean last;

    @Embedded(prefix = PREFIX_TEACHER)
    TeacherModel teacher;

    @Embedded(prefix = PREFIX_START)
    TimeOfDayModel start;

    @Embedded(prefix = PREFIX_FINISH)
    TimeOfDayModel finish;

    @TypeConverter
    public static Date toDate(Long dateLong) {
        return dateLong == null ? null : new Date(dateLong);
    }

    @TypeConverter
    public static Long fromDate(Date date) {
        return date == null ? null : date.getTime();
    }

    @TypeConverter
    public static User toUser(int numeral) {
        return User.values()[numeral];
    }

    @TypeConverter
    public static int fromUser(User status) {
        return status.ordinal();
    }

//    public static Timeline fromContentValues(ContentValues values) {
//        return new Timeline(
//                values.getAsLong(COLUMN_ID),
//                LessonModel.fromContentValues(values, PREFIX_LESSON),
//                RoomModel.fromContentValues(values, PREFIX_ROOM),
//                new Date(values.getAsLong(COLUMN_DATE)),
//                Timeline.User.values()
//                values.getAsString(COLUMN_GROUP),
//                values.getAsInteger(COLUMN_FIRST) == 1,
//                values.getAsInteger(COLUMN_LAST) == 1,
//                TeacherModel.fromContentValues(values, PREFIX_TEACHER),
//                TimeOfDayModel.fromContentValues(values, PREFIX_START),
//                TimeOfDayModel.fromContentValues(values, PREFIX_FINISH)
//        );
//    }
}