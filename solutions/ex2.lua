local obs = obslua

hotkeys = {
  htk_stop = "Стоп",
  htk_start = "Старт",
}
hk = {}

active = false

function hotkey_mapping(hotkey)
  if hotkey == "htk_stop" then
    print('Стоп')
  elseif hotkey == "htk_start" then
    print('Старт')
  end
end

function htk_1_cb(pressed) 
  if pressed then
    print('1')
  end
end

function htk_2_cb(pressed) 
  if pressed then
    active = not active
    if active then
      print('вкл')
    else
      print('выкл')
    end
  end
end

function htk_3_cb(pressed) 
  if pressed then
    print('3')
  end
end

function htk_4_cb(pressed) 
  if pressed then
    print('4')
  end
end

key_1 = '{"htk_1": [ { "key": "OBS_KEY_1" } ],'
key_3 = '"htk_3": [ { "key": "OBS_KEY_3" } ],'
key_4 = '"htk_4": [ { "key": "OBS_KEY_4","shift":true } ],'
key_2 = '"htk_2": [ { "key": "OBS_KEY_2" } ]}'
json_s = key_1 .. key_3 .. key_4 .. key_2
default_hotkeys = {
  {id='htk_1',des='Кнопка 1 ',callback=htk_1_cb},
  {id='htk_2',des='Кнопка 2 ',callback=htk_2_cb},
  {id='htk_3',des='Кнопка 3 ',callback=htk_3_cb},
  {id='htk_4',des='Кнопка 4 ',callback=htk_4_cb},
}

function script_load(settings)

  for k, v in pairs(hotkeys) do 
    hk[k] = obs.obs_hotkey_register_frontend(k, v, function(pressed)
      if pressed then 
        hotkey_mapping(k)
      end 
    end)
    a = obs.obs_data_get_array(settings, k)
    obs.obs_hotkey_load(hk[k], a)
    obs.obs_data_array_release(a)
  end

  s = obs.obs_data_create_from_json(json_s)
  for _,v in pairs(default_hotkeys) do 
    a = obs.obs_data_get_array(s,v.id)
    h = obs.obs_hotkey_register_frontend(v.id,v.des,v.callback)
    obs.obs_hotkey_load(h,a)
    obs.obs_data_array_release(a)
  end
  obs.obs_data_release(s)
end

function script_save(settings)
  for k, v in pairs(hotkeys) do
    a = obs.obs_hotkey_save(hk[k])
    obs.obs_data_set_array(settings, k, a)
    obs.obs_data_array_release(a)
  end
end
