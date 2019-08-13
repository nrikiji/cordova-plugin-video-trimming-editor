package plugin.videotrimmingeditor.features.record;

import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.ImageView;

// import plugin.videotrimmingeditor.R;
import plugin.videotrimmingeditor.features.common.ui.BaseActivity;
import plugin.videotrimmingeditor.features.record.view.PreviewSurfaceView;

/**
 * author : J.Chou
 * e-mail : who_know_me@163.com
 * time   : 2019/02/22 4:24 PM
 * version: 1.0
 * description:
 */
public class VideoRecordActivity extends BaseActivity implements View.OnClickListener {
  private PreviewSurfaceView mGLView;
  private ImageView mIvRecordBtn, mIvSwitchCameraBtn;

  public static void call(Context context) {
    context.startActivity(new Intent(context, VideoRecordActivity.class));
  }

  @Override
  public void initUI() {
    /*
    setContentView(R.layout.activity_video_recording);
    mGLView = this.findViewById(R.id.glView);
    mIvRecordBtn = this.findViewById(R.id.ivRecord);
    mIvSwitchCameraBtn = this.findViewById(R.id.ivSwitch);
    */
    setContentView(getResources().getIdentifier("activity_video_recording", "layout", getPackageName()));
    mGLView = this.findViewById(getResources().getIdentifier("glView", "id", getPackageName()));
    mIvRecordBtn = this.findViewById(getResources().getIdentifier("ivRecord", "id", getPackageName()));
    mIvSwitchCameraBtn = this.findViewById(getResources().getIdentifier("ivSwitch", "id", getPackageName()));

    mIvRecordBtn.setOnClickListener(this);
    mIvSwitchCameraBtn.setOnClickListener(this);
    mGLView.startPreview();
  }

  @Override
  public void onClick(View view) {
    if (getResources().getIdentifier("ivRecord", "id", getPackageName()) == view.getId()) {
    // if (R.id.ivRecord == view.getId()) {
      mGLView.startPreview();
    }
  }
}
