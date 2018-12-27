function minetest.on_flood_drop_self(pos, oldnode, newnode)
	local drops = minetest.get_node_drops(oldnode, newnode.name)
	for i, v in ipairs(drops) do
		minetest.add_item(pos, v)
	end
	return false	-- otherwise we don't get flooded
end
