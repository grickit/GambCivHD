local helper = wesnoth.require "lua/helper.lua"
local gambciv = wesnoth.require "~/add-ons/GambCivHD/lua/gambciv_base.lua"
local wml_actions = wesnoth.wml_actions
local tag = helper.set_wml_tag_metatable {}

-- [harvest_reed]
--  x,y = 5,5
--  side = 1
--  amount = 50
-- [/harvest_reed]

function wml_actions.harvest_reed(cfg)
	local side = cfg.side
	local locations = wesnoth.get_locations { terrain = "Ss", tag["not"]{ find_in = "just_modified"}, tag["and"](cfg)}
	local amount = cfg.amount or wesnoth.get_variable("GAMBCIVHD_MODCONFIG_DEFAULT_REED_MATERIAL")
  local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].reed_material", side)) or 0

  local cost_actions = cfg.cost_actions or 1
  local cost_gold = cfg.cost_gold or 0
  local cost_food = cfg.cost_food or 0
  local cost_material = cfg.cost_material or 0

	for i, loc in ipairs(locations) do
    if gambciv.check_resources(side, cost_actions, cost_gold, cost_food, cost_material) == false then
      break
    end

    gambciv.modify_terrain(loc[1], loc[2], "Ww", "both", "wose-die.ogg")
    wml_actions.modify_resources(side, -cost_actions, -cost_gold, -cost_food, (amount+current_bonus-cost_material))
    wml_actions.harvest_label(loc[1], loc[2], 0, 0, (amount+current_bonus))
    wml_actions.cost_label(loc[1], loc[2], cost_actions, cost_gold, cost_food, cost_material)

	end
end