package plugin.videotrimmingeditor;

import android.content.Context;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class VideoTrimmingEditor extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equals("open")) {
            JSONObject params = data.getJSONObject(0);

            String strLatitude = params.get("latitude").toString();
            String strLongitude = params.get("longitude").toString();

            double latitude = Double.parseDouble(strLatitude);
            double longitude = Double.parseDouble(strLongitude);

            return true;
        } else {
            return false;
        }
    }

}
