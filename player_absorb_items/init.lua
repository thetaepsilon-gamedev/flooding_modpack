local radius = 1	-- how far away from player items get absorbed
local min_age = 3.0
	-- how long the item must exist before being automatically picked up.
	-- this is to avoid loops where items are immediately absorbed after being dropped.
local target_inv = "main"	-- player inventory name, should not normally be changed!



local spawn = minetest.add_item

local process_item = function(itemref, playerref, item)
	local inv = playerref:get_inventory()
	local origin = itemref:get_pos()
	local leftover = inv:add_item(target_inv, item)
	-- ensure original entity is killed
	itemref:remove()

	-- leave behind anything which cannot fit.
	if leftover and leftover:get_count() > 0 then
		spawn(origin, leftover)
	end
end

local handle_entity = function(playerref, itemref)
	local luadata = itemref:get_luaentity()
	if not luadata then return end
	if not luadata.name == "__builtin:item" then return end
	local age = luadata.age or 0

	if age < min_age then return end
	local item = luadata.itemstring
	if not item then return end

	process_item(itemref, playerref, item)
end

local find = minetest.get_objects_inside_radius
local run_for_player = function(playerref)
	local pos = playerref:get_pos()
	local objects = find(pos, radius)
	for i, itemref in ipairs(objects) do
		handle_entity(playerref, itemref)
	end
end

local players = minetest.get_connected_players
local forall = function()
	for i, playerref in ipairs(players()) do
		run_for_player(playerref)
	end
end

minetest.register_globalstep(forall)

