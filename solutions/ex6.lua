local obs = obslua
name = ''

function count()
  --groups not working https://github.com/obsproject/obs-studio/issues/2788
  scenes = obs.obs_frontend_get_scenes()
  local c_scenes = 0
  local c_scene_items = 0
  local first_scene

  for _,scene in pairs(scenes) do

    if c_scenes == 0 then 
      first_scene = obs.obs_scene_from_source(scene)
    end

    c_scenes = c_scenes + 1
    scene_source = obs.obs_scene_from_source(scene)
    items = obs.obs_scene_enum_items(scene_source)

    for _,scene_item in pairs(items) do
      c_scene_items = c_scene_items + 1
    end
    obs.sceneitem_list_release(items)
  end

  result = "scenes " .. c_scenes .. "scene_items " .. c_scene_items 
  first_scene = obs.obs_scene_get_source(first_scene)
  obs.obs_source_set_name(first_scene,result)

  obs.source_list_release(scenes)
end

function count_btn_cb(props,p)
  count()
end

function script_properties()
  props = obs.obs_properties_create()
  obs.obs_properties_add_button(props, "button", "Count", count_btn_cb)
  return props
end
