package ru.coolone.ranepatimetable;

import android.database.Cursor;

import java.util.Calendar;
import java.util.List;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import static ru.coolone.ranepatimetable.WidgetProvider.getTodayMidnight;

@Dao
public interface TimelineDao {

    /**
     * Counts the number of timetables in the table.
     *
     * @return The number of timetables.
     */
    @Query("SELECT COUNT(*) FROM " + Timeline.TABLE_NAME)
    public int count();

    /**
     * Inserts a timeline into the table.
     *
     * @param timeline A new timeline.
     * @return The row ID of the newly inserted timeline.
     */
    @Insert
    public long insert(Timeline timeline);

    /**
     * Inserts multiple timelines into the database
     *
     * @param timelines An array of new timelines.
     * @return The row IDs of the newly inserted timelines.
     */
    @Insert
    public long[] insertAll(Timeline[] timelines);

    @Query("DELETE FROM " + Timeline.TABLE_NAME + " WHERE strftime('%Y-%m-%d', date) < strftime('%Y-%m-%d', 'now')")
    public int deleteOld();

    /**
     * Get all timetables.
     *
     * @return A {@link List} of all the timetables in the table.
     */
    @Query("SELECT * FROM " + Timeline.TABLE_NAME)
    public Timeline[] getAll();

    /**
     * Select all timetables.
     *
     * @return A {@link Cursor} of all the timetables in the table.
     */
    @Query("SELECT * FROM " + Timeline.TABLE_NAME)
    public Cursor selectAll();

    /**
     * Select a timetable by the ID.
     *
     * @param id The row ID.
     * @return A {@link Cursor} of the selected timetable.
     */
    @Query("SELECT * FROM " + Timeline.TABLE_NAME + " WHERE " + Timeline.COLUMN_ID + " = :id")
    public Cursor selectById(long id);

    /**
     * Select a timetable by the Date.
     *
     * @param date The row Date.
     * @return A {@link Cursor} of the selected timetable.
     */
    @Query("SELECT * FROM " + Timeline.TABLE_NAME + " WHERE " + Timeline.COLUMN_DATE + " = :date")
    public Cursor selectByDate(long date);

    //SELECT * FROM NAMES WHERE date == (SELECT date FROM NAMES WHERE date >= '1900-02-01 00:00:00' LIMIT 1)

    @Query("SELECT * FROM " + Timeline.TABLE_NAME + " WHERE " + Timeline.COLUMN_DATE + " == " +
            "(" +
            "SELECT " + Timeline.COLUMN_DATE +
            " FROM " + Timeline.TABLE_NAME +
            " WHERE " + Timeline.COLUMN_DATE + " >= :now LIMIT 1" +
            ")"
    )
    public Cursor selectWeekday(long now);

    /**
     * Delete a timetable by the ID.
     *
     * @param id The row ID.
     * @return A number of timetables deleted. This should always be {@code 1}.
     */
    @Query("DELETE FROM " + Timeline.TABLE_NAME + " WHERE " + Timeline.COLUMN_ID + " = :id")
    public int deleteById(long id);

    /**
     * Delete all timetables.
     *
     * @return A number of timetables deleted. This should always be {@code 1}.
     */
    @Query("DELETE FROM " + Timeline.TABLE_NAME)
    public int delete();

    /**
     * Update the timeline. The timeline is identified by the row ID.
     *
     * @param timeline The timeline to update.
     * @return A number of timetables updated. This should always be {@code 1}.
     */
    @Update
    public int update(Timeline timeline);
}