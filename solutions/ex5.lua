local obs = obslua
total_s = 0
text_data = ''

function script_tick(seconds)
  total_s = total_s + seconds
end

function on_event(event) 
  if event == obs.OBS_FRONTEND_EVENT_RECORDING_STARTED then 
    total_s = 0
  end 
end

function htk_1_cb(pressed) 
  if pressed then
    write_to_file("МЕТКА ; ")
  end
end

key_1 = '{"htk_1": [ { "key": "OBS_KEY_1" } ]}'
json_s = key_1
default_hotkeys = {
  {id='htk_1',des='Кнопка 1 ',callback=htk_1_cb},
}

function write_to_file(content)
    io.output(io.open(script_path() .. "out.txt","a"))
    io.write(content .. os.date("%c") .. " ; relative ; " .. total_s .. "\n")
    io.close()
end

function write_from_prop(props,prop)
  write_to_file(text_data .. ' ; ')
end

function script_update(settings)
  text_data = obs.obs_data_get_string(settings, "_text_data")
end

function script_properties()
  local props = obs.obs_properties_create()
  obs.obs_properties_add_text(props, "_text_data", "Text event data", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_button(props, "write_button", "Write", write_from_prop)
  return props
end

function script_load(settings)

  obs.obs_frontend_add_event_callback(on_event)

  s = obs.obs_data_create_from_json(json_s)
  for _,v in pairs(default_hotkeys) do 
    a = obs.obs_data_get_array(s,v.id)
    h = obs.obs_hotkey_register_frontend(v.id,v.des,v.callback)
    obs.obs_hotkey_load(h,a)
    obs.obs_data_array_release(a)
  end
  obs.obs_data_release(s)
end
