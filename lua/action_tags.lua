local helper = wesnoth.require "lua/helper.lua"
local wml_actions = wesnoth.wml_actions

function wml_actions.harvest_tree(cfg)
	local side = tostring(cfg.side)
	local locations = wesnoth.get_locations(cfg)

	for i, loc in ipairs(locations) do
		local x, y = loc[1], loc[2]
		if wesnoth.match_location(x, y, { terrain = "*^F*" }) then
			wesnoth.scroll_to_tile(x, y, true)
			wesnoth.play_sound('wose-die.ogg',false)
			wesnoth.float_label(x, y, string.format( "<span foreground='#BCB088'>%s</span>", "+10 wood"))
			wesnoth.set_terrain(x, y, "^", "overlay")
			wesnoth.message('foobar', x .. ' ' ..y)
			wml_actions.redraw {}
		end
	end
end