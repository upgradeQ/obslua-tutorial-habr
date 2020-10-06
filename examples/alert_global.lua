local obs = obslua
mediaSource = nil -- Null pointer
outputIndex = 63 -- Last index

function play_sound()
  mediaSource = obs.obs_source_create_private("ffmpeg_source", "Global Media Source", nil)
  local s = obs.obs_data_create()
  obs.obs_data_set_string(s, "local_file",script_path() .. "alert.mp3")
  obs.obs_source_update(mediaSource,s)
  obs.obs_source_set_monitoring_type(mediaSource,obs.OBS_MONITORING_TYPE_MONITOR_AND_OUTPUT)
  obs.obs_data_release(s)

  obs.obs_set_output_source(outputIndex, mediaSource)
  return mediaSource
end

function obs_play_sound_release_source()
  r = play_sound()
  obs.obs_source_release(r)
end

function on_event(event) 
  if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED
    then obs_play_sound_release_source()
  end 
end

function script_load(settings)
  obs.obs_frontend_add_event_callback(on_event)
end

function script_unload()
  obs.obs_set_output_source(outputIndex, nil)
end
