package plugin.videotrimmingeditor;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.fragment.app.FragmentActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import iknow.android.utils.BaseUtils;
import plugin.videotrimmingeditor.features.select.VideoSelectActivity;
import plugin.videotrimmingeditor.features.trim.VideoTrimmerActivity;

public class VideoTrimmingEditor extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            BaseUtils.init(this.cordova.getActivity().getApplicationContext());

            JSONObject params = data.getJSONObject(0);

            String videoPath = "/storage/emulated/0/xxx.mp4";

            Bundle bundle = new Bundle();
            bundle.putString(VideoTrimmerActivity.VIDEO_PATH_KEY, videoPath);

            this.cordova.setActivityResultCallback(this);

            Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, VideoTrimmingEditorActivity.class);
            intent.putExtras(bundle);
            this.cordova.getActivity().startActivityForResult(intent, VideoTrimmerActivity.VIDEO_TRIM_REQUEST_CODE);

            return true;
        } else {
            return false;
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == VideoTrimmerActivity.VIDEO_TRIM_REQUEST_CODE) {
            if (resultCode == this.cordova.getActivity().RESULT_OK) {
                String videoPath = data.getStringExtra(VideoTrimmerActivity.VIDEO_OUTPUT_KEY);
            }
        }

    }
}
