package ru.coolone.ranepatimetable;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.os.Bundle;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import lombok.var;

/**
 * This is the service that provides the factory to be bound to the collection service.
 */
public class WidgetService extends RemoteViewsService {
    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new WidgetRemoteViewsFactory(this.getApplicationContext(), intent);
    }
}

/**
 * This is the factory that will provide data to the collection widget.
 */
class WidgetRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {
    private Context mContext;
    private Cursor mCursor;

    public WidgetRemoteViewsFactory(Context context, Intent intent) {
        mContext = context;
    }

    @Override
    public void onCreate() {
        // Since we reload the cursor in onDataSetChanged() which gets called immediately after
        // onCreate(), we do nothing here.
    }

    @Override
    public void onDestroy() {
        if (mCursor != null) {
            mCursor.close();
        }
    }

    @Override
    public int getCount() {
        return mCursor.getCount();
    }

    public Bitmap buildBitmap(Context context, String text)
    {
        Bitmap myBitmap = Bitmap.createBitmap(160, 84, Bitmap.Config.ARGB_4444);
        Canvas myCanvas = new Canvas(myBitmap);
        Paint paint = new Paint();
        Typeface clock = Typeface.createFromAsset(context.getAssets(),"fonts/Timetable.ttf");
        paint.setAntiAlias(true);
        paint.setSubpixelText(true);
        paint.setTypeface(clock);
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.RED);
        paint.setTextSize(65);
        paint.setTextAlign(Paint.Align.CENTER);
        myCanvas.drawText(text, 40, 40, paint);
        return myBitmap;
    }

    @Override
    public RemoteViews getViewAt(int position) {
//        // Get the data for this position from the content provider
//        String date = "Unknown Day";
//        String lesson = "Unknown lesson";
//        if (mCursor.moveToPosition(position)) {
//            date = mCursor.getString(mCursor.getColumnIndex(TimetableDataProvider.Columns.DATE.toString()));
//            lesson = mCursor.getString(mCursor.getColumnIndex(TimetableDataProvider.Columns.LESSON_TITLE.toString()));
//        }
//
//        // Return a proper item with the proper day and temperature
//        final String formatStr = mContext.getResources().getString(R.string.item_format_string);
//
//        var rv = new RemoteViews(mContext.getPackageName(), R.layout.widget_item);
//        rv.setTextViewText(R.id.widget_item_text, String.format(formatStr, lesson, date));
////        rv.setImageViewBitmap(R.id.widget_item, buildBitmap(mContext, "\ue80f"));
//
//        // Set the click intent so that we can handle it and show a toast message
//        final Intent fillInIntent = new Intent();
//        final Bundle extras = new Bundle();
//        extras.putString(WidgetProvider.EXTRA_DAY_ID, date);
//        fillInIntent.putExtras(extras);
//        rv.setOnClickFillInIntent(R.id.widget_item, fillInIntent);
        return null;
    }

    @Override
    public RemoteViews getLoadingView() {
        // We aren't going to return a default loading view in this sample
        return null;
    }

    @Override
    public int getViewTypeCount() {
        // Technically, we have two types of views (the dark and light background views)
        return 2;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public void onDataSetChanged() {
        // Refresh the cursor
        if (mCursor != null) {
            mCursor.close();
        }
        mCursor = mContext.getContentResolver().query(TimetableDataProvider.URI_TIMELINE, null, null,
                null, null);
    }
}