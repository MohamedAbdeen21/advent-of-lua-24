local util = require("util")

local M = {}

function M.part1(lines)
	lines = lines or util.lines_from("./day23/input.txt")
	---@type table<string, table<string, boolean>>
	local connections = {}

	for _, line in ipairs(lines) do
		local l, r = line:match("(%w+)-(%w+)")
		connections[l] = connections[l] or {}
		connections[l][r] = true
		connections[r] = connections[r] or {}
		connections[r][l] = true
	end

	local sets = {}

	-- c1 and all of its connections, two of these connections should be connected
	for c1, c1_connections in pairs(connections) do
		for c2, _ in pairs(c1_connections) do
			-- one of c2 connections should exist in c1 connections
			for c3, _ in pairs(connections[c2]) do
				if c1_connections[c3] and (c3:sub(1, 1) == "t" or c1:sub(1, 1) == "t" or c2:sub(1, 1) == "t") then
					local s = { c1, c2, c3 }
					table.sort(s)
					sets[s[1] .. s[2] .. s[3]] = true
				end
			end
		end
	end

	local count = 0
	for _, _ in pairs(sets) do
		count = count + 1
	end

	return count
end
function M.part2(lines)
	lines = lines or util.lines_from("./day23/input.txt")

	---@type table<string, table<string, boolean>>
	local connections = {}

	for _, line in ipairs(lines) do
		local l, r = line:match("(%w+)-(%w+)")
		connections[l] = connections[l] or {}
		connections[l][r] = true
		connections[r] = connections[r] or {}
		connections[r][l] = true
	end

	local connection_sets = {}
	for c1, conns in pairs(connections) do
		local set = util.copy_table(conns)
		set[c1] = true

		for c2, _ in pairs(conns) do
			local set2 = util.copy_table(connections[c2])
			set2[c2] = true

			local diff = util.difference(set2, set)
			-- either disconnect the current node
			if util.set_size(diff) >= util.set_size(set) then
				set[c2] = nil
			else
				-- or the different nodes (i.e. keep the intersection)
				set = util.intersection(set, set2)
			end
		end

		table.insert(connection_sets, set)
	end

	local biggest_set = {}
	for _, set in ipairs(connection_sets) do
		local size = util.set_size(set)
		if size > util.set_size(biggest_set) then
			biggest_set = set
		end
	end

	local sorted_ring = {}
	for c, _ in pairs(biggest_set) do
		table.insert(sorted_ring, c)
	end
	table.sort(sorted_ring)

	return table.concat(sorted_ring, ",")
end

function M.tests()
	local input = util.lines_from("./day23/test.txt")
	util.run_test(M.part1, input, 7)
	util.run_test(M.part2, input, "co,de,ka,ta")
end

return M
