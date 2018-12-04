package ru.coolone.ranepatimetable;

import android.arch.persistence.room.Dao;
import android.arch.persistence.room.Insert;
import android.arch.persistence.room.Query;
import android.arch.persistence.room.Update;
import android.database.Cursor;

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