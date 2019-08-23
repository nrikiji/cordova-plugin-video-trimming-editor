package plugin.videotrimmingeditor;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;

import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;
import androidx.fragment.app.FragmentActivity;

import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.icu.util.Output;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.telecom.Call;
import android.util.Log;
import android.view.View;

import plugin.videotrimmingeditor.features.common.ui.BaseActivity;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DecodeFormat;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.FileDescriptorBitmapDecoder;
import com.bumptech.glide.load.resource.bitmap.VideoBitmapDecoder;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.tbruyelle.rxpermissions2.RxPermissions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import iknow.android.utils.callback.SimpleCallback;
import plugin.videotrimmingeditor.features.trim.VideoTrimmerActivity;
import plugin.videotrimmingeditor.utils.StorageUtil;

@SuppressWarnings("ResultOfMethodCallIgnored")
public class VideoTrimmingEditorActivity extends BaseActivity {

    public static final String THUMBNAIL_OUTPUT_KEY = "thumbnail-output-path";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Bundle bd = getIntent().getExtras();
        String path = "";
        if (bd != null) path = bd.getString(VideoTrimmerActivity.VIDEO_PATH_KEY);

        VideoTrimmerActivity.call((FragmentActivity) this, path);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == VideoTrimmerActivity.VIDEO_TRIM_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                String videoPath = data.getStringExtra(VideoTrimmerActivity.VIDEO_OUTPUT_KEY);
                int startMs = data.getIntExtra(VideoTrimmerActivity.VIDEO_START_MS, 0);

                final Context context = getApplicationContext();

                // キャプチャのファイル名は動画のファイル名から拡張子だけかえたものとする
                String thumbnailPath = videoPath.replaceAll(".mp4$", ".jpg");

                this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Callback callback = new Callback() {
                            @Override
                            public void success() {
                                Intent intent = new Intent();
                                intent.putExtra(VideoTrimmerActivity.VIDEO_OUTPUT_KEY, videoPath);
                                intent.putExtra(THUMBNAIL_OUTPUT_KEY, thumbnailPath);
                                setResult(RESULT_OK, intent);
                                finish();
                            }
                            @Override
                            public void failed() {
                                finish();
                            }
                        };

                        createThumbnail(callback, context, videoPath, thumbnailPath, startMs);
                    }
                });
            }
        }
    }

    @Override
    protected void initUI() {
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    private interface Callback {
        void success();
        void failed();
    }

    // サムネイル生成
    private void createThumbnail(Callback callback, Context context, String videoPath, String thumbnailPath, int startMs) {
        BitmapPool bitmapPool = Glide.get(context).getBitmapPool();
        FileDescriptorBitmapDecoder decoder = new FileDescriptorBitmapDecoder(
            new VideoBitmapDecoder(startMs),
            bitmapPool,
            DecodeFormat.PREFER_ARGB_8888
        );

        Glide.with(context)
            .load(videoPath)
            .asBitmap()
            .videoDecoder(decoder)
            .into(new SimpleTarget<Bitmap>() {
                @Override
                public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                    try {
                        OutputStream outputStream = new FileOutputStream(new File(thumbnailPath));
                        resource.compress(Bitmap.CompressFormat.JPEG, 70, outputStream);
                        outputStream.close();
                        callback.success();
                    } catch (IOException e) {
                        callback.failed();
                    }
                }

                @Override
                public void onLoadFailed(Exception e, Drawable errorDrawable) {
                    super.onLoadFailed(e, errorDrawable);
                    callback.failed();
                }
            });
    }

    private class CompressAsyncTask extends AsyncTask<Void, Void, Void> {

        

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        @Override
        protected Void doInBackground(Void... voids) {
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
        }
    }

}
