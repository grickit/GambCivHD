local helper = wesnoth.require "lua/helper.lua"
local gambciv = wesnoth.require "~/add-ons/GambCivHD/lua/gambciv_base.lua"
local wml_actions = wesnoth.wml_actions
local tag = helper.set_wml_tag_metatable {}


function wml_actions.construct_castle(cfg)
  local side = cfg.side
  local locations = wesnoth.get_locations { terrain = "G*,Rd,Re,Rb,Ds,Dd,Aa", tag["not"]{ find_in = "just_modified"}, tag["and"](cfg)}

  local cost_actions = cfg.cost_actions or 1
  local cost_gold = cfg.cost_gold or 0
  local cost_food = cfg.cost_food or 0
  local cost_material = cfg.cost_material or 5

  for i, loc in ipairs(locations) do
    if gambciv.check_resources(side, cost_actions, cost_gold, cost_food, cost_material) == false then
      break
    end

    gambciv.modify_terrain(loc[1], loc[2], "Ch", "both", "spear.wav")
    wml_actions.modify_resources(side, -cost_actions, -cost_gold, -cost_food, -cost_material)
    wml_actions.cost_label(loc[1], loc[2], cost_actions, cost_gold, cost_food, cost_material)

  end
end