package ru.coolone.ranepatimetable;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import lombok.var;


public class TimetableDataProvider extends ContentProvider {

    /** The authority of this content provider. */
    public static final String AUTHORITY = "ru.coolone.ranepatimetable.provider";

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
            var context = getContext();
            if (context == null) return null;

            var timetable = TimetableDatabase.getInstance(context).timetable();

            final Cursor cursor;
            if (code == CODE_TIMELINE_DIR) {
                cursor = timetable.selectAll();
            } else {
                cursor = timetable.selectById(ContentUris.parseId(uri));
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
        return null;
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

}