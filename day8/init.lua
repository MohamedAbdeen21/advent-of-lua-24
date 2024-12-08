local util = require("util")

local M = {}

local function find_manhatan_distance(a, b)
	return { a[1] - b[1], a[2] - b[2] }
end

local function apply_manhatten_distance(a, b)
	return { a[1] + b[1], a[2] + b[2] }
end

local function apply_negative_manhatten_distance(a, b)
	return { a[1] - b[1], a[2] - b[2] }
end

local function union(a, b)
	for v, _ in pairs(b) do
		a[v[1] .. "," .. v[2]] = true
	end
	return a
end

local function find_anti_nodes(nodes)
	local anti_nodes = {}

	local function cross_match(nodes_, index, anti_nodes_)
		if index > #nodes_ then
			return anti_nodes_
		end

		local node = nodes_[index]

		for i = index + 1, #nodes_ do
			local next_node = nodes_[i]
			local distance = find_manhatan_distance(node, next_node)
			anti_nodes[apply_manhatten_distance(node, distance)] = true
			anti_nodes[apply_negative_manhatten_distance(next_node, distance)] = true
		end

		return cross_match(nodes_, index + 1, anti_nodes_)
	end

	return cross_match(nodes, 1, anti_nodes)
end

local function find_anti_nodes_propagate(nodes, rows, cols)
	local anti_nodes = {}

	local function cross_match(nodes_, index, anti_nodes_)
		if index > #nodes_ then
			return anti_nodes_
		end

		local node = nodes_[index]

		for i = index + 1, #nodes_ do
			local next_node = nodes_[i]
			local anti_node = {}

			anti_nodes[node] = true
			anti_nodes[next_node] = true

			local distance = find_manhatan_distance(node, next_node)

			anti_node = apply_manhatten_distance(node, distance)
			while anti_node[1] >= 1 and anti_node[1] <= rows and anti_node[2] >= 1 and anti_node[2] <= cols do
				anti_nodes[anti_node] = true
				anti_node = apply_manhatten_distance(anti_node, distance)
			end

			anti_node = apply_negative_manhatten_distance(next_node, distance)
			while anti_node[1] >= 1 and anti_node[1] <= rows and anti_node[2] >= 1 and anti_node[2] <= cols do
				anti_nodes[anti_node] = true
				anti_node = apply_negative_manhatten_distance(anti_node, distance)
			end
		end

		return cross_match(nodes_, index + 1, anti_nodes_)
	end

	return cross_match(nodes, 1, anti_nodes)
end

function M.part1(lines)
	lines = lines or util.lines_from("./day8/input.txt")
	local grid = util.to_grid(lines)
	local freq_locations = {}

	for _, row in ipairs(grid) do
		for _, value in ipairs(row) do
			if value ~= "." then
				freq_locations[value] = {}
			end
		end
	end

	for freq, _ in pairs(freq_locations) do
		freq_locations[freq] = util.find_all_positions_of(grid, freq)
	end

	local all_anti_nodes = {}

	for _, locations in pairs(freq_locations) do
		all_anti_nodes = union(all_anti_nodes, find_anti_nodes(locations))
	end

	local sum = 0

	for location, _ in pairs(all_anti_nodes) do
		local x, y = location:match("(-?%d+),(-?%d+)")
		x, y = tonumber(x), tonumber(y)

		if x < 1 or x > #grid or y < 1 or y > #grid[1] then
		else
			sum = sum + 1
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day8/input.txt")
	local grid = util.to_grid(lines)
	local freq_locations = {}

	for _, row in ipairs(grid) do
		for _, value in ipairs(row) do
			if value ~= "." then
				freq_locations[value] = {}
			end
		end
	end

	for freq, _ in pairs(freq_locations) do
		freq_locations[freq] = util.find_all_positions_of(grid, freq)
	end

	local m, n = #grid, #grid[1]

	local all_anti_nodes = {}

	for _, locations in pairs(freq_locations) do
		all_anti_nodes = union(all_anti_nodes, find_anti_nodes_propagate(locations, m, n))
	end

	local sum = 0

	-- already filtered out-of-bounds anti-nodes
	for _, _ in pairs(all_anti_nodes) do
		sum = sum + 1
	end

	return sum
end

function M.tests()
	local input = util.lines_from("./day8/test.txt")
	util.run_test(M.part1, input, 14)
	util.run_test(M.part2, input, 34)
end

return M
