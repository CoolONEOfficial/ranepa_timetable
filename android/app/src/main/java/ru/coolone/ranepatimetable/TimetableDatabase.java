package ru.coolone.ranepatimetable;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;

@Database(entities = {Timeline.class}, version = 1, exportSchema = false)
public abstract class TimetableDatabase extends RoomDatabase {

    public static final String FILENAME = "timetable.db";

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
     * @param ctx The ctx.
     * @return The singleton instance of TimetableDatabase.
     */
    public static synchronized TimetableDatabase getInstance(Context ctx) {
        if (sInstance == null) {
            sInstance = Room
                    .databaseBuilder(
                            ctx,
                            TimetableDatabase.class,
                            FILENAME
                    )
                    .createFromAsset("database/" + FILENAME)
                    .allowMainThreadQueries()
                    .build();
        }
        return sInstance;
    }
}