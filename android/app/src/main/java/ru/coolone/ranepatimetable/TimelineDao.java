package ru.coolone.ranepatimetable;

import android.arch.persistence.room.Dao;
import android.arch.persistence.room.Insert;
import android.arch.persistence.room.Query;
import android.arch.persistence.room.Update;
import android.database.Cursor;

@Dao
public interface TimelineDao {

    /**
     * Counts the number of cheeses in the table.
     *
     * @return The number of cheeses.
     */
    @Query("SELECT COUNT(*) FROM " + Timeline.TABLE_NAME)
    int count();

    /**
     * Inserts a timeline into the table.
     *
     * @param timeline A new timeline.
     * @return The row ID of the newly inserted timeline.
     */
    @Insert
    long insert(Timeline timeline);

    /**
     * Inserts multiple timelines into the database
     *
     * @param timelines An array of new timelines.
     * @return The row IDs of the newly inserted timelines.
     */
    @Insert
    long[] insertAll(Timeline[] timelines);

    /**
     * Select all cheeses.
     *
     * @return A {@link Cursor} of all the cheeses in the table.
     */
    @Query("SELECT * FROM " + Timeline.TABLE_NAME)
    Cursor selectAll();

    /**
     * Select a cheese by the ID.
     *
     * @param id The row ID.
     * @return A {@link Cursor} of the selected cheese.
     */
    @Query("SELECT * FROM " + Timeline.TABLE_NAME + " WHERE " + Timeline.COLUMN_ID + " = :id")
    Cursor selectById(long id);

    /**
     * Delete a cheese by the ID.
     *
     * @param id The row ID.
     * @return A number of cheeses deleted. This should always be {@code 1}.
     */
    @Query("DELETE FROM " + Timeline.TABLE_NAME + " WHERE " + Timeline.COLUMN_ID + " = :id")
    int deleteById(long id);

    /**
     * Update the timeline. The timeline is identified by the row ID.
     *
     * @param timeline The timeline to update.
     * @return A number of cheeses updated. This should always be {@code 1}.
     */
    @Update
    int update(Timeline timeline);

}