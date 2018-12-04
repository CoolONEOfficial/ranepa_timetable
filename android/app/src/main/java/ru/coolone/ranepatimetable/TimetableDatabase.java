package ru.coolone.ranepatimetable;

import android.arch.persistence.room.Database;
import android.arch.persistence.room.Room;
import android.arch.persistence.room.RoomDatabase;
import android.content.Context;
import android.support.annotation.VisibleForTesting;

import java.sql.Date;

@Database(entities = {Timeline.class}, version = 1, exportSchema = false)
public abstract class TimetableDatabase extends RoomDatabase {

    /**
     * @return The DAO for the Timeline table.
     */
    @SuppressWarnings("WeakerAccess")
    public abstract TimelineDao timetable();

    /**
     * The only instance
     */
    private static TimetableDatabase sInstance;

    /**
     * Gets the singleton instance of TimetableDatabase.
     *
     * @param context The context.
     * @return The singleton instance of TimetableDatabase.
     */
    public static synchronized TimetableDatabase getInstance(Context context) {
        if (sInstance == null) {
            sInstance = Room
                    .databaseBuilder(
                            context.getApplicationContext(),
                            TimetableDatabase.class,
                            "ex"
                    )
                    .build();
//            sInstance.populateInitialData();
        }
        return sInstance;
    }

    /**
     * Switches the internal implementation with an empty in-memory database.
     *
     * @param context The context.
     */
    @VisibleForTesting
    public static void switchToInMemory(Context context) {
        sInstance = Room.inMemoryDatabaseBuilder(context.getApplicationContext(),
                TimetableDatabase.class).build();
    }

    /**
     * Inserts the dummy data into the database if it is currently empty.
     */
//    private void populateInitialData() {
//        if (timetable().count() == 0) {
//            beginTransaction();
//            try {
//                for (int i = 0; i < 5; i++) {
//                    timetable().insert(
//                            new Timeline(
//                                    i,
//                                    new Timeline.LessonModel(
//                                            "lesson",
//                                            123
//                                    ),
//                                    new Timeline.RoomModel(
//                                            312,
//                                            Timeline.Location.Hotel
//                                    ),
//                                    new Date(0),
//                                    "Иб-021",
//                                    new Timeline.TeacherModel(
//                                            "Николай",
//                                            "Трухин",
//                                            "Александрович"
//                                    ),
//                                    new Timeline.TimeOfDayModel(
//                                            12,
//                                            30
//                                    ),
//                                    new Timeline.TimeOfDayModel(
//                                            13,
//                                            50
//                                    )
//                            )
//                    );
//                }
//                setTransactionSuccessful();
//            } finally {
//                endTransaction();
//            }
//        }
//    }

}