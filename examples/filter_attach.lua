local obs = obslua
local bit = require("bit")

local info = {} -- obs_source_info https://obsproject.com/docs/reference-sources.html
info.id = "uniq_filter_id"
info.type = obs.OBS_SOURCE_TYPE_FILTER
info.output_flags = bit.bor(obs.OBS_SOURCE_VIDEO)

info.get_name = function() return 'default filter name' end

info.create = function(settings,source) 
  local filter = {}
  filter.context = source
  filter.flag = true
  filter._toggle = function()
    info.toggle(filter,settings)
  end
  obs.timer_add(filter._toggle,2000)
  return filter
end

info.toggle = function(filter,settings)
  local target = obs.obs_filter_get_parent(filter.context)
  local flag = filter.flag
  flag = not flag 
  filter.flag = flag
  obs.obs_source_set_enabled(target,flag) -- not synchronized with ui
end

--info.video_tick = function(filter,seconds) -- not working properly ,multithreading ??
--end

info.video_render = function(filter, effect) 
  -- called every frame
  local target = obs.obs_filter_get_target(filter.context)
  if target ~= nil then
    filter.width = obs.obs_source_get_base_width(target)
    filter.height = obs.obs_source_get_base_height(target)
  end
  obs.obs_source_skip_video_filter(filter.context)
end

info.get_width = function(filter)
  return filter.width
end

info.get_height = function(filter)
  return filter.height
end

obs.obs_register_source(info)
