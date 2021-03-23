package com.videothumbnail;

import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

public class RNVideoThumbnailModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNVideoThumbnailModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNVideoThumbnail";
  }

  @ReactMethod
  public void get(String filePath, Promise promise) {
    filePath = filePath.replace("file://","");
    MediaMetadataRetriever retriever = new MediaMetadataRetriever();
    retriever.setDataSource(filePath);

    long duration = Long.parseLong(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
    long oneSecond = TimeUnit.MICROSECONDS.convert(1, TimeUnit.SECONDS);
    long time = Math.min(duration, oneSecond);

    Bitmap image = retriever.getFrameAtTime(time);
    if (image != null) {
        String path = saveImageToCache(image);
        WritableMap map = Arguments.createMap();

        map.putString("path", path);
        map.putDouble("width", image.getWidth());
        map.putDouble("height", image.getHeight());

        promise.resolve(map);
    } else {
      promise.reject("E_RNVideoThumbnail_ERROR", "could not get thumbnail");
    }
  }

  private String saveImageToCache(Bitmap bitmap) {
    File thumbnailFile = new File(getCurrentActivity().getCacheDir(), UUID.randomUUID().toString().concat(".jpg"));
    try {
      FileOutputStream stream = new FileOutputStream(thumbnailFile);
      bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
      return thumbnailFile.getPath();
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    }

    return null;
  }

}
