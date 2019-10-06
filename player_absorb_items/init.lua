-- visual-only item entity.
-- used to allow "wooshing" the item without allowing it to be picked up.
local n = "player_absorb_items:item_dummy"
local s = 0.25
minetest.register_entity(n, {
	visual = "item",
	visual_size = {x = s, y = s},
	physical = false,
	collide_with_objects = false,
	pointable = false,
	static_save = false,
})



local radius = 1.5	-- how far away from player items get absorbed
local min_age = 3.0
	-- how long the item must exist before being automatically picked up.
	-- this is to avoid loops where items are immediately absorbed after being dropped.
local target_inv = "main"	-- player inventory name, should not normally be changed!



local spawn = minetest.add_item
-- helper function to leave leftover item stacks on the ground.
local handle_leftover = function(leftover, dump_pos)
	if leftover and leftover:get_count() > 0 then
		spawn(dump_pos, leftover)
	end
end



local index = 0
local items_in_flight = {}

local process_inflight_item = function(player, itemref, item, last_pos)

	-- the player might have logged off in the meantime.
	-- if that's the case, just dump the item on the ground.
	local tpos = player:get_pos()
	if not tpos then
		spawn(last_pos, item)
		return
	end

	-- try to add it to their inventory now.
	-- again, inventory may have filled in the meantime.
	local leftover = player:get_inventory():add_item(target_inv, item)
	itemref:remove()
	handle_leftover(leftover, tpos)
end

local vscale = 15
local process_item = function(itemref, playerref, ppos, item)
	local inv = playerref:get_inventory()
	local origin = itemref:get_pos()

	-- if the entire item can fit right now,
	-- perform the "wooshing" animation on it and add it a tick later.
	if inv:room_for_item(target_inv, item) then
		itemref:remove()
		-- replace entity with fake so it can't be duplicately picked up.
		itemref = minetest.add_entity(origin, n)
		itemref:set_properties({textures={item}})
		ppos.y = ppos.y + playerref:get_properties().eye_height
		itemref:set_velocity(vector.multiply(vector.subtract(ppos, origin), vscale))

		local current_pos = playerref:get_pos()
		minetest.after(0.15, function()
			process_inflight_item(playerref, itemref, item, current_pos)
		end)

		return
	end

	-- otherwise split and do a partial add.
	local leftover = inv:add_item(target_inv, item)
	-- ensure original entity is killed
	itemref:remove()

	-- leave behind anything which cannot fit.
	handle_leftover(leftover, origin)
end

local handle_entity = function(playerref, ppos, itemref)
	local luadata = itemref:get_luaentity()
	if not luadata then return end
	if not luadata.name == "__builtin:item" then return end
	local age = luadata.age or 0

	if age < min_age then return end
	local item = luadata.itemstring
	if not item then return end

	process_item(itemref, playerref, ppos, item)
end

local find = minetest.get_objects_inside_radius
local run_for_player = function(playerref)
	local pos = playerref:get_pos()
	local objects = find(pos, radius)
	for i, itemref in ipairs(objects) do
		handle_entity(playerref, pos, itemref)
	end
end


--[[
local handle_item_in_flight = function(data)
	assert(data)
	local player = data[1]
	local itemref = data[2]
	local item = data[3]
	local last_pos = data[4]

	return process_inflight_item(player, itemref, item, last_pos)
end
]]

local players = minetest.get_connected_players
local forall = function()
	-- firstly handle items in flight.
	-- it's still possible their inv was filled in the meantime;
	-- so we still have to handle "leftovers" here.
	--for i = 1, index, 1 do
	--	handle_item_in_flight(items_in_flight[i])
	--end
	--index = 0
	--items_in_flight = {}

	for i, playerref in ipairs(players()) do
		run_for_player(playerref)
	end
end

minetest.register_globalstep(forall)

