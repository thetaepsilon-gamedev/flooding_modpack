local patch_node = function(nodename)
	local def = minetest.registered_nodes[nodename]
	if not def then
		return
	end
	minetest.override_item(nodename, {
		floodable = true,
		on_flood = minetest.on_flood_drop_self,
	})
end

local targets = {
	"default:torch",
	"default:torch_wall",
	"default:torch_ceiling",
}
local extra_targets = {}
local add = function(n)
	extra_targets[n] = true
end

-- farming wheat
for i = 1, 8, 1 do
	add("farming:wheat_"..i)
end





for i, n in ipairs(targets) do
	patch_node(n)
end
for n, _ in pairs(extra_targets) do
	patch_node(n)
end




-- papyrus is a little bit more complex due to it's cascading behaviour;
-- to call it's after_dig_node function we'd normally have to pass some data in,
-- notably a digger object that quacks enough like a player to not crash.
-- fortunately minetest.dig_node takes care of that for us here.
local ghost_dig = minetest.on_flood_dig_node
local custom_patches = {
	["default:papyrus"] = {
		on_flood = ghost_dig,
	}
}
for node, patch in pairs(custom_patches) do
	if minetest.registered_nodes[node] then
		-- do this automatically as why else would we be here...
		patch.floodable = true
		minetest.override_item(node, patch)
	end
end

