package plugin.videotrimmingeditor;

import android.content.Context;
import android.content.Intent;

import androidx.fragment.app.FragmentActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import plugin.videotrimmingeditor.features.select.VideoSelectActivity;
import plugin.videotrimmingeditor.features.trim.VideoTrimmerActivity;

public class VideoTrimmingEditor extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            JSONObject params = data.getJSONObject(0);

            Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, VideoTrimmingEditorActivity.class);
            this.cordova.getActivity().startActivity(intent);

            /*
            String path = "/storage/emulated/0/CROOZBlog/34176116/EDIT/f4930454-bd6f-4499-816c-1d24ab0941bf.mp4";
            Context context = cordova.getActivity();
            VideoTrimmerActivity.call((FragmentActivity) context, path);
            Intent intent = new Intent(context, VideoTrimmerActivity.class);
            this.cordova.getActivity().startActivity(intent);
            */

            /*
            Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, VideoSelectActivity.class);
            this.cordova.getActivity().startActivity(intent);
            */

            /*
            Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, VideoTrimmerActivity.class);
            this.cordova.getActivity().startActivity(intent);
            */

            return true;
        } else {
            return false;
        }
    }

}
