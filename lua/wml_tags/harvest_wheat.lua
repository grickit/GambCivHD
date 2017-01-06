local gambciv = wesnoth.require "~/add-ons/GambCivHD/lua/gambciv_base.lua"
local wml_actions = wesnoth.wml_actions

-- [harvest_wheat]
--  x,y = 5,5
--  side = 1
--  amount = 50
-- [/harvest_wheat]

function wml_actions.harvest_wheat(cfg)
	local side = cfg.side
	local locations = wesnoth.get_locations(cfg)
	local amount = cfg.amount or wesnoth.get_variable("GAMBCIVHD_MODCONFIG_DEFAULT_WHEAT_FOOD")
  local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].wheat_food", side)) or 0

  local cost_actions = cfg.cost_actions or 0
  local cost_gold = cfg.cost_gold or 0
  local cost_food = cfg.cost_food or 0
  local cost_material = cfg.cost_material or 0

	for i, loc in ipairs(locations) do
    if gambciv.check_resources(side, cost_actions, cost_gold, cost_food, cost_material) == false then
      break
    end

		if wesnoth.match_location(loc[1], loc[2], { terrain = "Gd^Gvs" }) then
			gambciv.modify_terrain(loc[1], loc[2], "Re", "both", "hatchet-miss.wav")
      wml_actions.modify_resources(side, -cost_actions, -cost_gold, (amount+current_bonus-cost_food), -cost_material)
      wml_actions.harvest_label(loc[1], loc[2], 0, (amount+current_bonus), 0)
      wml_actions.cost_label(loc[1], loc[2], cost_actions, cost_gold, cost_food, cost_material)
    end

	end
end