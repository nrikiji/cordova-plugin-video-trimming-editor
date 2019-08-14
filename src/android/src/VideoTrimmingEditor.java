package plugin.videotrimmingeditor;

import android.content.Context;
import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import plugin.videotrimmingeditor.features.select.VideoSelectActivity;

public class VideoTrimmingEditor extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            JSONObject params = data.getJSONObject(0);

            Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, VideoSelectActivity.class);
            this.cordova.getActivity().startActivity(intent);

            return true;
        } else {
            return false;
        }
    }

}
