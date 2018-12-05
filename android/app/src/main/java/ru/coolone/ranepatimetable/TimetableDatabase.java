package ru.coolone.ranepatimetable;

import android.arch.persistence.room.Database;
import android.arch.persistence.room.Room;
import android.arch.persistence.room.RoomDatabase;
import android.content.Context;
import android.support.annotation.VisibleForTesting;

@Database(entities = {Timeline.class}, version = 1, exportSchema = false)
public abstract class TimetableDatabase extends RoomDatabase {

    public static final String NAME = "TimetableDatabase";

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
                            NAME
                    )
                    .allowMainThreadQueries()
                    .build();
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
        sInstance = Room.inMemoryDatabaseBuilder(
                context.getApplicationContext(),
                TimetableDatabase.class
        ).build();
    }

}