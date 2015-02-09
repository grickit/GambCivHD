local helper = wesnoth.require "lua/helper.lua"
local wml_actions = wesnoth.wml_actions

function wml_actions.harvest_tree(cfg)
	local sides = wesnoth.get_sides(cfg)
	local locations = wesnoth.get_locations(cfg)
	local amount = cfg.amount or 10

	for i, loc in ipairs(locations) do
		local x, y = loc[1], loc[2]
		if wesnoth.match_location(x, y, { terrain = "*^F*" }) then
			wesnoth.scroll_to_tile(x, y, true)
			wesnoth.play_sound('wose-die.ogg',false)
			wesnoth.set_terrain(x, y, "^", "overlay")
			wml_actions.redraw {}

			for i, side in ipairs(sides) do
				local current_wood = wesnoth.get_variable(string.format("side_stats[%i].material", side.side)) or 0
				local current_bonus = wesnoth.get_variable(string.format("side_bonuses[%i].tree", side.side)) or 0
				local gain = amount + current_bonus
				wesnoth.set_variable(string.format("side_stats[%i].material", side.side), (current_wood+gain))
				wesnoth.float_label(x, y, string.format("<span foreground='#BCB088'>+%i material</span>", gain))
			end
		end
	end
end