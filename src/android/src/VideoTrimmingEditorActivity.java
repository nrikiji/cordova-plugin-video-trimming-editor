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

// import nrikiji.trimsample.R;
import nrikiji.videotrimmingeditorsample.databinding.ActivityVideoSelectBinding;
import plugin.videotrimmingeditor.features.common.ui.BaseActivity;
import plugin.videotrimmingeditor.features.record.VideoRecordActivity;
import plugin.videotrimmingeditor.features.record.view.CameraPreviewLayout;
import plugin.videotrimmingeditor.features.record.view.PreviewSurfaceView;
import com.tbruyelle.rxpermissions2.RxPermissions;

import iknow.android.utils.callback.SimpleCallback;
import plugin.videotrimmingeditor.features.trim.VideoTrimmerActivity;

@SuppressWarnings("ResultOfMethodCallIgnored")
public class VideoTrimmingEditorActivity extends BaseActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // String path = "/storage/emulated/0/CROOZBlog/34176116/EDIT/f4930454-bd6f-4499-816c-1d24ab0941bf.mp4";
        // String path = "/storage/emulated/0/DCIM/Camera/VID_20180928_195930.mp4";
        // String path = "/storage/emulated/0/xxx.mp4";
        // VideoTrimmerActivity.call((FragmentActivity) VideoTrimmingEditorActivity.this, path);

        String path = "/storage/emulated/0/xxx.mp4";
        Context context = this;
        VideoTrimmerActivity.call((FragmentActivity) context, path);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.d("","戻ってきたよー!!");
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
