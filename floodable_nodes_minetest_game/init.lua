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

-- flowers mod plants
local flowers = {
	"rose", "tulip", "dandelion_yellow",
	"geranium", "viola", "dandelion_white",
	"mushroom_red", "mushroom_brown",
}
for _, flower in ipairs(flowers) do
	add("flowers:"..flower)
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
-- minetest.dig_node does not appear to work in multiplayer for some weird reason;
-- it will seemingly mysteriously fail even in the absence of protection mods,
-- so we can't really use it.
-- instead we emulate the loop of digging up, sans requiring a digger object.
local gn = minetest.get_node
local drop = minetest.on_flood_drop_self
local remove = minetest.remove_node
local on_flood_dig_up_ = function(nodename)
	local function dig_recursive(pos, oldnode, newnode)
		-- we already know we are a valid node here;
		-- we perform the check for the next one.
		drop(pos, oldnode, newnode)

		pos.y = pos.y + 1
		local nextnode = gn(pos)
		-- return false to work as an on_flood callback and break recursion
		if nextnode.name ~= nodename then return false end
		-- clear out that node as we haven't already done that.
		-- the base node will be replaced by the flooding liquid.
		remove(pos)

		return dig_recursive(pos, nextnode, newnode)
	end

	return dig_recursive
end

local custom_patches = {
	["default:papyrus"] = {
		on_flood = on_flood_dig_up_("default:papyrus"),
	}
}
for node, patch in pairs(custom_patches) do
	if minetest.registered_nodes[node] then
		-- do this automatically as why else would we be here...
		patch.floodable = true
		minetest.override_item(node, patch)
	end
end

