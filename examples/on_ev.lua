local obs = obslua

function alert()
  error("NOT RECORDING")
end

function action()
  if not obs.obs_frontend_recording_active() then 
    alert()
  end
end

function on_event(event) 
  if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED
    then action() 
  end 
end

function script_load(settings)
  obs.obs_frontend_add_event_callback(on_event)
end
