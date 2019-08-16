package plugin.videotrimmingeditor;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;

import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;
import androidx.fragment.app.FragmentActivity;

import android.os.Bundle;
import android.util.Log;
import android.view.View;

import plugin.videotrimmingeditor.features.common.ui.BaseActivity;
import com.tbruyelle.rxpermissions2.RxPermissions;

import iknow.android.utils.callback.SimpleCallback;
import plugin.videotrimmingeditor.features.trim.VideoTrimmerActivity;

@SuppressWarnings("ResultOfMethodCallIgnored")
public class VideoTrimmingEditorActivity extends BaseActivity {

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
                Intent intent = new Intent();
                intent.putExtra(VideoTrimmerActivity.VIDEO_OUTPUT_KEY, videoPath);
                setResult(RESULT_OK, intent);
            }
        }

        finish();
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

}
