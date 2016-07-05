package com.cykra.musiccontrols;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MusicControlsInfos{
	public String artist;
	public String title;
	public String ticker;
	public String artwork;
	public boolean isPlaying;
	public boolean hasPrev;
	public boolean hasNext;
	public boolean hasClose;
	public boolean dismissable;

	public MusicControlsInfos(JSONArray args) throws JSONException {
		final JSONObject params = args.getJSONObject(0);

		this.title = params.getString("title");
		this.artist = params.getString("artist");
		this.ticker = params.getString("ticker");
		this.artwork = params.getString("artwork");
		this.isPlaying = params.getBoolean("isPlaying");
		this.hasPrev = params.getBoolean("hasPrev");
		this.hasNext = params.getBoolean("hasNext");
		this.hasClose = params.getBoolean("hasClose");
		this.dismissable = params.getBoolean("dismissable");
	}

}
