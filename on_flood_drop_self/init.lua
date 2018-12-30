function minetest.on_flood_drop_self(pos, oldnode, newnode)
	local drops = minetest.get_node_drops(oldnode, newnode.name)
	for i, v in ipairs(drops) do
		minetest.add_item(pos, v)
	end
	return false	-- otherwise we don't get flooded
end

-- for nodes that require something a bit more complex behaviour-wise,
-- we have this (e.g. for papyrus to invoke it's dig_up behaviour).
-- we might not always want to use this in case a more real player is needed by callbacks.
-- note that this function *always* allows flooding;
-- if you need to do something more complex (e.g. because of an inventory)
-- then you really ought to have a proper on_flood for that node.
local ghost_dig = minetest.dig_node
function minetest.on_flood_dig_node(pos, oldnode, newnode)
		ghost_dig(pos)
		return false
end

