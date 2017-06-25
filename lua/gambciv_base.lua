local helper = wesnoth.require "lua/helper.lua"
local wml_actions = wesnoth.wml_actions
local gambciv = {}

gambciv.COLOR_ACTION = "#00CDFF"
gambciv.COLOR_GOLD = "#FFE700"
gambciv.COLOR_FOOD = "#00FF22"
gambciv.COLOR_MATERIAL = "#BCB088"

for i, side in ipairs(wesnoth.sides) do
	wesnoth.set_variable(string.format("side_bonuses[%i].tobacco_gold", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].tree_material", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].wheat_food", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].mine_gold", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].fish_food", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].quarry_material", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].reed_material", side.side), 0)
	wesnoth.set_variable(string.format("side_bonuses[%i].mushroom_gold", side.side), 0)

	wesnoth.set_variable(string.format("side_stats[%i].actions", side.side), 100)

end

function gambciv.check_resources(side, actions, gold, food, material)
	local current_actions = wesnoth.get_variable(string.format("side_stats[%i].actions", side)) or 0
	local current_gold = wesnoth.sides[side].gold or 0
	local current_food = wesnoth.get_variable(string.format("side_stats[%i].food", side)) or 0
	local current_material = wesnoth.get_variable(string.format("side_stats[%i].material", side)) or 0

	wesnoth.set_variable(string.format("side_stats[%i].gold", side), (current_gold+gold))


	if current_actions < actions then
		if wesnoth.sides[side].controller == "human" then
			wesnoth.message('RESOURCES', 'Not enough actions.')
		end
	end

	if current_gold < gold then
		if wesnoth.sides[side].controller == "human" then
			wesnoth.message('RESOURCES', 'Not enough gold.')
		end
	end

	if current_food < food then
		if wesnoth.sides[side].controller == "human" then
			wesnoth.message('RESOURCES', 'Not enough food.')
		end
	end

	if current_material < material then
		if wesnoth.sides[side].controller == "human" then
			wesnoth.message('RESOURCES', 'Not enough material.')
		end
	end

	if current_actions < actions or current_gold < gold or current_food < food or current_material < material then
		wesnoth.play_sound("miss-2.ogg",false)
		return false
	end

	return true
end

function gambciv.modify_terrain(x, y, terrain, layer, sound)
	wesnoth.scroll_to_tile(x, y, true)
	wesnoth.play_sound(sound,false)
	wesnoth.set_terrain(x, y, terrain, layer)
	wesnoth.add_tile_overlay(x, y, { image = "scenery/rune4-glow.png" })
	wml_actions.store_locations({ variable = "just_modified", x = x, y = y,  { "or", { find_in = "just_modified" }}})
end

function wml_actions.modify_resources(side, actions, gold, food, material)
	local current_actions = wesnoth.get_variable(string.format("side_stats[%i].actions", side)) or 0
	local current_gold = wesnoth.sides[side].gold or 0
	local current_food = wesnoth.get_variable(string.format("side_stats[%i].food", side)) or 0
	local current_material = wesnoth.get_variable(string.format("side_stats[%i].material", side)) or 0

	wesnoth.set_variable(string.format("side_stats[%i].actions", side), (current_actions+actions))
	wesnoth.sides[side].gold = (current_gold+gold)
	wesnoth.set_variable(string.format("side_stats[%i].gold", side), (current_gold+gold))
	wesnoth.set_variable(string.format("side_stats[%i].food", side), (current_food+food))
	wesnoth.set_variable(string.format("side_stats[%i].material", side), (current_material+material))
end

function wml_actions.harvest_label(x, y, gold, food, material)
	local label = ""

	if gold ~= 0 then
		label = label .. string.format("<span foreground='%s'>+%i gold</span> ",gambciv.COLOR_GOLD,gold)
	end

	if food ~= 0 then
		label = label .. string.format("<span foreground='%s'>+%i food</span> ",gambciv.COLOR_FOOD,food)
	end

	if material ~= 0 then
		label = label .. string.format("<span foreground='%s'>+%i material</span> ",gambciv.COLOR_MATERIAL,material)
	end

	wesnoth.float_label(x, y, label)
end

function wml_actions.cost_label(x, y, actions, gold, food, material)
	local label = ""

	if gold ~= 0 then
		label = label .. string.format("<span foreground='%s'>-%i actions</span> ",gambciv.COLOR_ACTION,action)
	end

	if gold ~= 0 then
		label = label .. string.format("<span foreground='%s'>-%i gold</span> ",gambciv.COLOR_GOLD,gold)
	end

	if food ~= 0 then
		label = label .. string.format("<span foreground='%s'>-%i food</span> ",gambciv.COLOR_FOOD,food)
	end

	if material ~= 0 then
		label = label .. string.format("<span foreground='%s'>-%i material</span> ",gambciv.COLOR_MATERIAL,material)
	end

	wesnoth.float_label(x, y, label)
end

function wml_actions.operate_goldmine(cfg)
	local sides = wesnoth.get_sides(cfg)
	local locations = wesnoth.get_locations(cfg)
	local amount = cfg.amount or wesnoth.get_variable("GAMBCIVHD_MODCONFIG_DEFAULT_MINE_GOLD")

	for i, loc in ipairs(locations) do
		if wesnoth.match_location(loc[1], loc[2], { terrain = "M*^Vhh" }) then
			modify_terrain(loc[1], loc[2], "^", "base", "gold.ogg")

			for i, side in ipairs(sides) do
				if check_resources(side.side, 1, 0, 0, 0) then
					local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].mine_gold", side.side)) or 0
					wml_actions.modify_resources(side.side, -1, (amount+current_bonus), 0, 0)
					wml_actions.harvest_label(loc[1], loc[2], (amount+current_bonus), 0, 0)
				end
			end
		end
	end
end

return gambciv