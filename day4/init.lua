local util = require("util")

local M = {}

local function find_all_positions_of(grid, target)
	---@type {x: number, y: number}[]
	local xs = {}

	for i, row in ipairs(grid) do
		for j, col in ipairs(row) do
			if col == target then
				xs[#xs + 1] = { i, j }
			end
		end
	end

	return xs
end

local function grid_at(grid, x, y)
	if x < 1 or x > #grid or y < 1 or y > #grid[x] then
		return "."
	end
	return grid[x][y]
end

local function dfs(grid, x, y, target, direction)
	local dx, dy = direction[1], direction[2]

	local i = x + dx
	local j = y + dy

	if i < 1 or i > #grid or j < 1 or j > #grid[i] or grid[i][j] ~= target then
		return false
	end

	local next_target
	if target == "M" then
		next_target = "A"
	elseif target == "A" then
		next_target = "S"
	end

	if target == "S" and grid[i][j] == target then
		return true
	else
		return dfs(grid, i, j, next_target, direction)
	end
end

function M.part1(lines)
	lines = lines or util.lines_from("./day4/input.txt")
	local grid = util.to_grid(lines)

	local xs = find_all_positions_of(grid, "X")

	local directions = {
		{ 1, 0 },
		{ -1, 0 },
		{ 0, 1 },
		{ 0, -1 },
		{ 1, 1 },
		{ 1, -1 },
		{ -1, 1 },
		{ -1, -1 },
	}

	local sum = 0

	for _, x in ipairs(xs) do
		for _, direction in ipairs(directions) do
			if dfs(grid, x[1], x[2], "M", direction) then
				sum = sum + 1
			end
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day4/input.txt")
	local grid = util.to_grid(lines)

	local xs = find_all_positions_of(grid, "A")

	local sum = 0

	for _, x in ipairs(xs) do
		local freq = {}

		local ur = grid_at(grid, x[1] + 1, x[2] + 1)
		local ll = grid_at(grid, x[1] - 1, x[2] - 1)
		local lr = grid_at(grid, x[1] + 1, x[2] - 1)
		local ul = grid_at(grid, x[1] - 1, x[2] + 1)

		freq[ur] = (freq[ur] or 0) + 1
		freq[ll] = (freq[ll] or 0) + 1
		freq[lr] = (freq[lr] or 0) + 1
		freq[ul] = (freq[ul] or 0) + 1

		if freq["M"] == 2 and freq["S"] == 2 and ur ~= ll and ul ~= lr then
			sum = sum + 1
		end
	end

	return sum
end

function M.tests()
	assert(M.part1(util.lines_from("./day4/test.txt")) == 18)
	assert(M.part2(util.lines_from("./day4/test.txt")) == 9)
end

return M
