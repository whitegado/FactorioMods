local usage_detector = require "usage_detector"
local gui_center = require "gui_center"

-- Per player:
-- top.usage_detector
-- center.usage_detector_center frame
--   list?
--     header panel
--       start, stop, choose item/fluid
--     results table
--       rows with: recipe name, amount, count, sum, machine_count

local function setupGui(player)
  local top = player.gui.top
  if top["usage_detector"] == nil then
    top.add({
      type = "button",
      name = "usage_detector",
      caption = "U",
      style = "usage_detector_small_button"
    })
  end
end

local function on_chosen_element_changed(event)
  local player = game.players[event.player_index]
  if not player.gui.center["usage_detector_center"] then
    return
  end
  local player_data = global.player_data[event.player_index] or {}
  for job_name in pairs(player_data.jobs) do
    local job_gui = player.gui.center.usage_detector_center[job_name]
    if event.element == job_gui.header.item then
      job_gui.header.fluid.elem_value = nil
    end
    if event.element == job_gui.header.fluid then
      job_gui.header.item.elem_value = nil
    end
  end
end

local function onClick(event)
  local player = game.players[event.player_index]
  if event.element.name == "usage_detector" then
    global.player_data = global.player_data or {} -- TODO: temporary code for me while debugging
    if player.gui.center["usage_detector_center"] then
      player.gui.center["usage_detector_center"].destroy()
    else
      gui_center.create(player)
    end
    return
  end
  gui_center.click(player, event, usage_detector)
end

local function on_game_tick()
  local player_data = global.player_data
  if not player_data then player_data = {} end -- TODO: temporary code for me while debugging
  for player_index, player_data in pairs(player_data) do
    local player = game.players[player_index]
    for section_name, job in pairs(player_data.jobs) do
      usage_detector.onTick(job)
    end
    gui_center.update_gui(player, player_data)
  end
end

script.on_event(defines.events.on_gui_click, onClick)
script.on_event(defines.events.on_gui_elem_changed, on_chosen_element_changed)

return {
  setupGui = setupGui,
  onTick = on_game_tick
}