local obs = obslua

local selected_source
pos = obs.vec2()
switch = false
counter = 0

function on_off()
  if switch then 
    obs.timer_add(move_source_on_scene,50)
  else
    obs.timer_remove(move_source_on_scene)
  end
  switch = not switch
end

function add_source()
  current_scene = obs.obs_frontend_get_current_scene()
  scene = obs.obs_scene_from_source(current_scene)
  settings = obs.obs_data_create()

  counter = counter + 1
  green = 0xff00ff00
  hotkey_data = nil
  obs.obs_data_set_int(settings, "width",200)
  obs.obs_data_set_int(settings, "height",200)
  obs.obs_data_set_int(settings, "color",green)
  source = obs.obs_source_create("color_source", "ист#" .. counter, settings, hotkey_data)
  obs.obs_scene_add(scene, source)

  obs.obs_scene_release(scene)
  obs.obs_data_release(settings)
  obs.obs_source_release(source)
end

function move_button(props,p)
  move_source_on_scene()
end

function move_source_on_scene()
  current_scene = obs.obs_frontend_get_current_scene()
  scene = obs.obs_scene_from_source(current_scene)
  scene_item = obs.obs_scene_find_source(scene, selected_source)
  if scene_item then
    dx, dy = 10, 0
    obs.obs_sceneitem_get_pos( scene_item, pos) -- обновить позицию если источник был перемещён мышкой
    pos.x = pos.x + dx
    pos.y = pos.y + dy
    obs.obs_sceneitem_set_pos(scene_item, pos) 
  end

  obs.obs_scene_release(scene)
end

function script_properties()
  local props = obs.obs_properties_create()
  obs.obs_properties_add_button(props, "button1", "Вкл/Выкл",on_off)
  obs.obs_properties_add_button(props, "button2", "Добавить источник",add_source)
  obs.obs_properties_add_button(props, "button3", "Cдвинуть источник на +10,0",move_button)
  local p = obs.obs_properties_add_list(props, "selected_source", "Выберите источник", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
  local sources = obs.obs_enum_sources()
  if sources ~= nil then
    for _, source in ipairs(sources) do
      source_id = obs.obs_source_get_unversioned_id(source)
      if source_id == "color_source" then
        local name = obs.obs_source_get_name(source)
        obs.obs_property_list_add_string(p, name, name)
      end
    end
  end
  obs.source_list_release(sources)
  return props
end

function script_update(settings)
  selected_source = obs.obs_data_get_string(settings,"selected_source")
end
