local helper = wesnoth.require "lua/helper.lua"
local wml_actions = wesnoth.wml_actions

local COLOR_ACTION = "#00CDFF"
local COLOR_GOLD = "#FFE700"
local COLOR_FOOD = "#00FF22"
local COLOR_MATERIAL = "#BCB088"
local DEFAULT_TREE_MATERIAL = 10
local DEFAULT_REED_MATERIAL = 5
local DEFAULT_MUSHROOM_GOLD = 30

function modify_terrain(x, y, terrain, layer, sound)
	wesnoth.scroll_to_tile(x, y, true)
	wesnoth.play_sound(sound,false)
	wesnoth.set_terrain(x, y, terrain, layer)
	wml_actions.redraw {}
end

function located_harvest(x, y, side, gold, food, material)
	local current_gold = wesnoth.sides[side].gold or 0
	local current_food = wesnoth.get_variable(string.format("side_stats[%i].food", side)) or 0
	local current_material = wesnoth.get_variable(string.format("side_stats[%i].material", side)) or 0

	wesnoth.sides[side].gold = (current_gold+gold)
	wesnoth.set_variable(string.format("side_stats[%i].food", side), (current_food+food))
	wesnoth.set_variable(string.format("side_stats[%i].material", side), (current_material+material))

	local label = ""

	if gold ~= 0 then
		label = label .. string.format("<span foreground='%s'>+%i gold</span> ",COLOR_GOLD,gold)
	end

	if food ~= 0 then
		label = label .. string.format("<span foreground='%s'>+%i food</span> ",COLOR_FOOD,food)
	end

	if material ~= 0 then
		label = label .. string.format("<span foreground='%s'>+%i material</span> ",COLOR_MATERIAL,material)
	end

	wesnoth.float_label(x, y, label)
end

function wml_actions.harvest_tree(cfg)
	local sides = wesnoth.get_sides(cfg)
	local locations = wesnoth.get_locations(cfg)
	local amount = cfg.amount or DEFAULT_TREE_MATERIAL

	for i, loc in ipairs(locations) do
		local x, y = loc[1], loc[2]
		if wesnoth.match_location(x, y, { terrain = "*^F*" }) then
			modify_terrain(x, y, "^", "overlay", "wose-die.ogg")

			for i, side in ipairs(sides) do
				local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].tree", side.side)) or 0
				located_harvest(x, y, side.side, 0, 0, (amount+current_bonus))
			end
		end
	end
end

function wml_actions.harvest_reed(cfg)
	local sides = wesnoth.get_sides(cfg)
	local locations = wesnoth.get_locations(cfg)
	local amount = cfg.amount or DEFAULT_REED_MATERIAL

	for i, loc in ipairs(locations) do
		local x, y = loc[1], loc[2]
		if wesnoth.match_location(x, y, { terrain = "Ss" }) then
			modify_terrain(x, y, "Ww", "both", "wose-die.ogg")

			for i, side in ipairs(sides) do
				local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].reed", side.side)) or 0
				located_harvest(x, y, side.side, 0, 0, (amount+current_bonus))
			end
		end
	end
end

function wml_actions.harvest_mushroom(cfg)
	local sides = wesnoth.get_sides(cfg)
	local locations = wesnoth.get_locations(cfg)
	local amount = cfg.amount or DEFAULT_MUSHROOM_GOLD

	for i, loc in ipairs(locations) do
		local x, y = loc[1], loc[2]
		if wesnoth.match_location(x, y, { terrain = "*^Em*,*^Uf" }) then
			modify_terrain(x, y, "Re", "both", "hatchet-miss.wav")

			for i, side in ipairs(sides) do
				local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].mushroom", side.side)) or 0
				located_harvest(x, y, side.side, (amount+current_bonus), 0, 0)
			end
		end
	end
end