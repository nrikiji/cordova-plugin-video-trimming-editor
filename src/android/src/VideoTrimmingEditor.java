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
import plugin.videotrimmingeditor.features.trim.VideoTrimmerActivity;
import plugin.videotrimmingeditor.features.trim.VideoTrimmerUtil;

public class VideoTrimmingEditor extends CordovaPlugin {

    CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            this.callbackContext = callbackContext;
            BaseUtils.init(this.cordova.getActivity().getApplicationContext());

            JSONObject params = data.getJSONObject(0);
            String inputPath = params.get("input_path").toString();
            int videoMaxTime = params.getInt("video_max_time");

            Bundle bundle = new Bundle();
            bundle.putString(VideoTrimmerActivity.VIDEO_PATH_KEY, inputPath);
            VideoTrimmerUtil.setVideoMaxTime(videoMaxTime);

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
                try {
                    String videoPath = data.getStringExtra(VideoTrimmerActivity.VIDEO_OUTPUT_KEY);
                    JSONObject json = new JSONObject();
                    json.put("output_path", videoPath);
                    callbackContext.success(json);
                } catch (JSONException e) {
                    callbackContext.error(-1);
                }
            }
        }

    }
}
