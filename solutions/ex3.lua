local obs = obslua
source_name = ''

function htk_1_cb(pressed) 
  if pressed then
    speed = math.random(0,1000)
    random_bool = math.random(0,1)
    if random_bool == 1 then random_bool = true else random_bool = false end
    add_filter_to_source(speed,random_bool)
  end
end

function add_filter_to_source(speed,random_bool)
  source = obs.obs_get_source_by_name(source_name)

  scroll_random = obs.obs_source_get_filter_by_name(source,"_scroll")
  if scroll_random == nil then -- if not exists
    settings = obs.obs_data_create()
    f = obs.obs_source_create_private( "scroll_filter", "_scroll", settings)
    obs.obs_source_filter_add(source, f)
    obs.obs_source_release(f)
    obs.obs_data_release(settings)
  end

  s = obs.obs_source_get_settings(scroll_random)
  i = obs.obs_data_set_int
  b = obs.obs_data_set_bool

  i(s,"speed_y",speed)
  b(s,"loop",random_bool)
  obs.obs_source_update(scroll_random,s)


  obs.obs_source_release(scroll_random)
  obs.obs_data_release(s)
  obs.obs_source_release(source)
end

function script_properties()
  -- source https://raw.githubusercontent.com/insin/obs-bounce/master/bounce.lua
  local props = obs.obs_properties_create()
  local source = obs.obs_properties_add_list(
    props,
    'source',
    'Source:',
    obs.OBS_COMBO_TYPE_EDITABLE,
    obs.OBS_COMBO_FORMAT_STRING)
  for _, name in ipairs(get_source_names()) do
    obs.obs_property_list_add_string(source, name, name)
  end
  return props
end

function script_update(settings)
  source_name = obs.obs_data_get_string(settings, 'source')
end


--- get a list of source names, sorted alphabetically
function get_source_names()
  local sources = obs.obs_enum_sources()
  local source_names = {}
  if sources then
    for _, source in ipairs(sources) do
      -- exclude Desktop Audio and Mic/Aux by their capabilities
      local capability_flags = obs.obs_source_get_output_flags(source)
      if bit.band(capability_flags, obs.OBS_SOURCE_DO_NOT_SELF_MONITOR) == 0 and
        capability_flags ~= bit.bor(obs.OBS_SOURCE_AUDIO, obs.OBS_SOURCE_DO_NOT_DUPLICATE) then
        table.insert(source_names, obs.obs_source_get_name(source))
      end
    end
  end
  obs.source_list_release(sources)
  table.sort(source_names, function(a, b)
    return string.lower(a) < string.lower(b)
  end)
  return source_names
end


key_1 = '{"htk_1": [ { "key": "OBS_KEY_1" } ]}'
json_s = key_1
default_hotkeys = {
  {id='htk_1',des='Кнопка 1 ',callback=htk_1_cb},
}

function script_load(settings)

  s = obs.obs_data_create_from_json(json_s)
  for _,v in pairs(default_hotkeys) do 
    a = obs.obs_data_get_array(s,v.id)
    h = obs.obs_hotkey_register_frontend(v.id,v.des,v.callback)
    obs.obs_hotkey_load(h,a)
    obs.obs_data_array_release(a)
  end
  obs.obs_data_release(s)
end
