package ru.coolone.ranepatimetable;

import android.content.ContentProvider;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.OperationApplicationException;
import android.content.UriMatcher;
import android.database.Cursor;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.util.ArrayList;


public class TimetableDataProvider extends ContentProvider {

    /** The authority of this content provider. */
    public static final String AUTHORITY = "com.example.android.ranepatimetable.provider";

    /** The URI for the Timeline table. */
    public static final Uri URI_TIMELINE = Uri.parse(
            "content://" + AUTHORITY + "/" + Timeline.TABLE_NAME);

    /** The match code for some items in the Timeline table. */
    private static final int CODE_TIMELINE_DIR = 1;

    /** The match code for an item in the Timeline table. */
    private static final int CODE_TIMELINE_ITEM = 2;

    /** The URI matcher. */
    private static final UriMatcher MATCHER = new UriMatcher(UriMatcher.NO_MATCH);

    static {
        MATCHER.addURI(AUTHORITY, Timeline.TABLE_NAME, CODE_TIMELINE_DIR);
        MATCHER.addURI(AUTHORITY, Timeline.TABLE_NAME + "/*", CODE_TIMELINE_ITEM);
    }

    @Override
    public boolean onCreate() {
        return true;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection,
                        @Nullable String[] selectionArgs, @Nullable String sortOrder) {
        final int code = MATCHER.match(uri);
        if (code == CODE_TIMELINE_DIR || code == CODE_TIMELINE_ITEM) {
            final Context context = getContext();
            if (context == null) {
                return null;
            }
            TimelineDao cheese = TimetableDatabase.getInstance(context).cheese();
            final Cursor cursor;
            if (code == CODE_TIMELINE_DIR) {
                cursor = cheese.selectAll();
            } else {
                cursor = cheese.selectById(ContentUris.parseId(uri));
            }
            cursor.setNotificationUri(context.getContentResolver(), uri);
            return cursor;
        } else {
            throw new IllegalArgumentException("Unknown URI: " + uri);
        }
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
        switch (MATCHER.match(uri)) {
            case CODE_TIMELINE_DIR:
                return "vnd.android.cursor.dir/" + AUTHORITY + "." + Timeline.TABLE_NAME;
            case CODE_TIMELINE_ITEM:
                return "vnd.android.cursor.item/" + AUTHORITY + "." + Timeline.TABLE_NAME;
            default:
                throw new IllegalArgumentException("Unknown URI: " + uri);
        }
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
        switch (MATCHER.match(uri)) {
            case CODE_TIMELINE_DIR:
                final Context context = getContext();
                if (context == null) {
                    return null;
                }
                final long id = TimetableDatabase.getInstance(context).cheese()
                        .insert(Timeline.fromContentValues(values));
                context.getContentResolver().notifyChange(uri, null);
                return ContentUris.withAppendedId(uri, id);
            case CODE_TIMELINE_ITEM:
                throw new IllegalArgumentException("Invalid URI, cannot insert with ID: " + uri);
            default:
                throw new IllegalArgumentException("Unknown URI: " + uri);
        }
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection,
                      @Nullable String[] selectionArgs) {
        switch (MATCHER.match(uri)) {
            case CODE_TIMELINE_DIR:
                throw new IllegalArgumentException("Invalid URI, cannot update without ID" + uri);
            case CODE_TIMELINE_ITEM:
                final Context context = getContext();
                if (context == null) {
                    return 0;
                }
                final int count = TimetableDatabase.getInstance(context).cheese()
                        .deleteById(ContentUris.parseId(uri));
                context.getContentResolver().notifyChange(uri, null);
                return count;
            default:
                throw new IllegalArgumentException("Unknown URI: " + uri);
        }
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection,
                      @Nullable String[] selectionArgs) {
        switch (MATCHER.match(uri)) {
            case CODE_TIMELINE_DIR:
                throw new IllegalArgumentException("Invalid URI, cannot update without ID" + uri);
            case CODE_TIMELINE_ITEM:
                final Context context = getContext();
                if (context == null) {
                    return 0;
                }
                final Timeline timeline = Timeline.fromContentValues(values);
                timeline.id = ContentUris.parseId(uri);
                final int count = TimetableDatabase.getInstance(context).cheese()
                        .update(timeline);
                context.getContentResolver().notifyChange(uri, null);
                return count;
            default:
                throw new IllegalArgumentException("Unknown URI: " + uri);
        }
    }

    @NonNull
    @Override
    public ContentProviderResult[] applyBatch(
            @NonNull ArrayList<ContentProviderOperation> operations)
            throws OperationApplicationException {
        final Context context = getContext();
        if (context == null) {
            return new ContentProviderResult[0];
        }
        final TimetableDatabase database = TimetableDatabase.getInstance(context);
        database.beginTransaction();
        try {
            final ContentProviderResult[] result = super.applyBatch(operations);
            database.setTransactionSuccessful();
            return result;
        } finally {
            database.endTransaction();
        }
    }

    @Override
    public int bulkInsert(@NonNull Uri uri, @NonNull ContentValues[] valuesArray) {
        switch (MATCHER.match(uri)) {
            case CODE_TIMELINE_DIR:
                final Context context = getContext();
                if (context == null) {
                    return 0;
                }
                final TimetableDatabase database = TimetableDatabase.getInstance(context);
                final Timeline[] timelines = new Timeline[valuesArray.length];
                for (int i = 0; i < valuesArray.length; i++) {
                    timelines[i] = Timeline.fromContentValues(valuesArray[i]);
                }
                return database.cheese().insertAll(timelines).length;
            case CODE_TIMELINE_ITEM:
                throw new IllegalArgumentException("Invalid URI, cannot insert with ID: " + uri);
            default:
                throw new IllegalArgumentException("Unknown URI: " + uri);
        }
    }

}

//
///**
// * A dummy class that we are going to use internally to store weather data.  Generally, this data
// * will be stored in an external and persistent location (ie. File, Database, SharedPreferences) so
// * that the data can persist if the process is ever killed.  For simplicity, in this sample the
// * data will only be stored in memory.
// */
//@AllArgsConstructor
//class TeacherModel {
//    final String name, surname, patronymic;
//}
//
//@AllArgsConstructor
//class TimeOfDayModel {
//    final int hour, minute;
//}
//
//@AllArgsConstructor
//class LessonModel {
//    final String title;
//    final int iconCodePoint;
//}
//
//@AllArgsConstructor
//class RoomModel {
//    enum Location {
//        Academy,
//        Hotel,
//        StudyHostel
//    }
//
//    final int number;
//    final Location location;
//}
//
//
//@AllArgsConstructor
//class TimelineModel {
//    final LessonModel lesson;
//    final RoomModel room;
//
//    final Date date;
//
//    final String group;
//    final TeacherModel teacher;
//
//    final TimeOfDayModel start, finish;
//}
//
///**
// * The AppWidgetProvider for our sample weather widget.
// */
//public class TimetableDataProvider extends ContentProvider {
//    public static final Uri CONTENT_URI =
//            Uri.parse("content://ru.coolone.ranepatimetable.provider");
//
//    public static final String TIMELINE_MODELS = "timeline_models";
//
//    @AllArgsConstructor
//    public enum Columns {
//        ID("_id"),
//        LESSON_TITLE("lesson_title"),
//        LESSON_ICON("lesson_icon"),
//        ROOM_NUMBER("room_number"),
//        ROOM_LOCATION("room_location"),
//        DATE("date"),
//        GROUP("group"),
//        TEACHER_NAME("teacher_name"),
//        TEACHER_SURNAME("teacher_surname"),
//        TEACHER_PATRONYMIC("teacher_patronymic"),
//        START("start"),
//        FINISH("finish");
//
//        private final String text;
//
//        @Override
//        public String toString() {
//            return text;
//        }
//
//        static final String[] strValues = new String[Columns.values().length];
//
//        static {
//            for (int mColumnId = 0; mColumnId < values().length; mColumnId++)
//                strValues[mColumnId] = values()[mColumnId].toString();
//        }
//    }
//
//    /**
//     * Generally, this data will be stored in an external and persistent location (ie. File,
//     * Database, SharedPreferences) so that the data can persist if the process is ever killed.
//     * For simplicity, in this sample the data will only be stored in memory.
//     */
//    private static final ArrayList<TimelineModel> sData = new ArrayList<>();
//
//    @Override
//    public boolean onCreate() {
//        // We are going to initialize the data provider with some default values
////        sData.add(new TimelineModel(
////                        new LessonModel("Lesson one", 123),
////                        new RoomModel(432, RoomModel.Location.Academy),
////                        new Date(),
////                        "group11",
////                        new TeacherModel("DFsdfs", "snm", "sanich"),
////                        new TimeOfDayModel(9, 12),
////                        new TimeOfDayModel(11, 12)
////                )
////        );
////
////        sData.add(new TimelineModel(
////                        new LessonModel("Lesson two", 321),
////                        new RoomModel(12, RoomModel.Location.StudyHostel),
////                        new Date(),
////                        "group11",
////                        new TeacherModel("Name", "snm", "sanich"),
////                        new TimeOfDayModel(12, 12),
////                        new TimeOfDayModel(13, 12)
////                )
////        );
//
//        return true;
//    }
//
//    @Override
//    public synchronized Cursor query(@NonNull Uri uri, String[] projection, String selection,
//                                     String[] selectionArgs, String sortOrder) {
//        var c = new MatrixCursor(Columns.strValues);
//        for (int i = 0; i < sData.size(); ++i) {
//            var data = sData.get(i);
//            c.addRow(new Object[]{
//                    i,
//                    data.lesson.title,
//                    data.lesson.iconCodePoint,
//                    data.room,
//                    data.date.toString(),
//                    data.group,
//                    data.teacher.name,
//                    data.teacher.surname,
//                    data.teacher.patronymic,
//                    data.start.hour,
//                    data.start.minute,
//                    data.finish.hour,
//                    data.finish.minute
//            });
//        }
//        return c;
//    }
//
//    @Override
//    public String getType(Uri uri) {
//        return "vnd.android.cursor.dir/vnd.timetablewidget.timeline";
//    }
//
//    @Override
//    @SneakyThrows
//    public Uri insert(Uri uri, ContentValues values) {
//
//        Gson g = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").create();
//
//        TimelineModel[] arr = g.fromJson(
//                values.getAsString(TIMELINE_MODELS),
//                TimelineModel[].class
//        );
//
////        sData.addAll(Arrays.asList(arr));
//
//        return null;
//    }
//
//    @Override
//    public int delete(Uri uri, String selection, String[] selectionArgs) {
//        sData.clear();
//        return 0;
//    }
//
//    @Override
//    public synchronized int update(Uri uri, ContentValues values, String selection,
//                                   String[] selectionArgs) {
////        assert (uri.getPathSegments().size() == 1);
////        // In this sample, we only update the content provider individually for each row with new
////        // temperature values.
////        var index = Integer.parseInt(uri.getPathSegments().get(0));
////        var c = new MatrixCursor(Columns.strValues);
////        assert (0 <= index && index < sData.size());
////        var data = sData.get(index);
////        data.degrees = values.getAsInteger(Columns.TEMPERATURE);
////        // Notify any listeners that the data backing the content provider has changed, and return
////        // the number of rows affected.
////        getContext().getContentResolver().notifyChange(uri, null);
//        return 0; //1
//    }
//}