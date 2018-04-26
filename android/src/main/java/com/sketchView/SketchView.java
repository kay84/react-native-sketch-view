package com.sketchView;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.view.MotionEvent;
import android.view.View;

import com.sketchView.tools.EraseSketchTool;
import com.sketchView.tools.PenSketchTool;
import com.sketchView.tools.SketchTool;
import com.sketchView.tools.ToolThickness;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;

/**
 * Created by keshav on 05/04/17.
 */

public class SketchView extends View {

    SketchTool currentTool;
    SketchTool penTool;
    SketchTool eraseTool;
    Bitmap incrementalImage;
    private boolean sketchViewEdited;
    private boolean blockEditedUpdates;
    
    public SketchView(Context context) {
        super(context);
        sketchViewEdited = false;
        blockEditedUpdates = false;
        penTool = new PenSketchTool(this);
        eraseTool = new EraseSketchTool(this);
        setToolType(SketchTool.TYPE_PEN);

        setBackgroundColor(Color.TRANSPARENT);
    }

    public void setToolType(int toolType) {
        switch (toolType) {
            case SketchTool.TYPE_PEN:
                currentTool = penTool;
                break;
            case SketchTool.TYPE_ERASE:
                currentTool = eraseTool;
                break;
            default:
                currentTool = penTool;
        }
    }

    public void setToolColor(int toolColor) {
        ((PenSketchTool) penTool).setToolColor(toolColor);
    }

    public void setToolThickness(float toolThickness) {
        ((ToolThickness) penTool).setToolThickness(toolThickness);
        ((ToolThickness) eraseTool).setToolThickness(toolThickness);
    }
    
    public void setViewImage(Bitmap bitmap) {
        incrementalImage = bitmap;
        invalidate();
    }

    Bitmap drawBitmap() {
        Bitmap viewBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(viewBitmap);
        draw(canvas);
        return  viewBitmap;
    }

    public void clear() {
        incrementalImage = null;
        currentTool.clear();
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if(incrementalImage != null)
            canvas.drawBitmap(incrementalImage, getLeft(), getTop(), null);
        if(currentTool != null)
            currentTool.render(canvas);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (!blockEditedUpdates) {
            setSketchViewEdited(true);
            blockEditedUpdates = true;
        }
        boolean value = currentTool.onTouch(this, event);
        if(event.getAction() == MotionEvent.ACTION_CANCEL || event.getAction() == MotionEvent.ACTION_UP) {
            setViewImage(drawBitmap());
            currentTool.clear();
            blockEditedUpdates = false;
        }
        return value;
    }

    public void setSketchViewEdited (boolean newValue) {
        sketchViewEdited = newValue;
        onSketchViewEdited(this, newValue);
    }

    private void onSketchViewEdited(View view, boolean value) {
        WritableMap event = Arguments.createMap();
        event.putBoolean("edited", value);
        sendEvent(((View)view.getParent()), "onSketchViewEdited", event);
    }

    private void sendEvent(View view, String eventType, WritableMap event) {
        WritableMap nativeEvent = Arguments.createMap();
        nativeEvent.putString("type", eventType);
        nativeEvent.putMap("event", event);
        ReactContext reactContext = (ReactContext) view.getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(view.getId(), "topChange", nativeEvent);
      }
}
