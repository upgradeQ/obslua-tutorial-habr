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

  filter.hotkeys = {
    htk_stop = "[stop] ",
    htk_restart = "[start] ",
  }
  filter.hotkey_mapping = function(hotkey,data)
    if hotkey == "htk_stop" then
      print('stop '.. data.srsn .. " : " .. data.filn)
    elseif hotkey == "htk_restart" then
      print('restart ' .. data.srsn .. " : " .. data.filn)
    end
  end

  filter.hk = {}
  for k,v in pairs(filter.hotkeys) do 
    filter.hk[k] = obs.OBS_INVALID_HOTKEY_ID
  end

  filter._reg_htk = function()
    info.reg_htk(filter,settings)
  end
  obs.timer_add(filter._reg_htk,100) -- callback to register hotkeys , one time only

  return filter
end

info.reg_htk = function(filter,settings) -- register hotkeys after 100 ms since filter was created
  local target = obs.obs_filter_get_parent(filter.context)
  local srsn = obs.obs_source_get_name(target) 
  local filn =  obs.obs_source_get_name(filter.context)
  local data = {srsn = srsn, filn = filn} 

  for k, v in pairs(filter.hotkeys) do 
    filter.hk[k] = obs.obs_hotkey_register_frontend(k, v .. srsn .. " : " .. filn, function(pressed)
    if pressed then filter.hotkey_mapping(k,data) end end)
    local a = obs.obs_data_get_array(settings, k)
    obs.obs_hotkey_load(filter.hk[k], a)
    obs.obs_data_array_release(a)
  end

  obs.remove_current_callback()
end


info.video_render = function(filter, effect) 
  -- called every frame
  local target = obs.obs_filter_get_parent(filter.context)
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

--info.load = function(filter,settings) -- restart required
--... same code as in info.reg_htk , but filters will be created from scratch every time
--obs restarts , there is no reason to define it here again becuase hotkeys will be duplicated
--end

info.save = function(filter,settings)
  for k, v in pairs(filter.hotkeys) do
    local a = obs.obs_hotkey_save(filter.hk[k])
    obs.obs_data_set_array(settings, k, a)
    obs.obs_data_array_release(a)
  end
end

obs.obs_register_source(info)
