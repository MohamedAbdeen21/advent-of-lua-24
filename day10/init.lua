local util = require("util")

local M = {}

local function grid_at(grid, x, y)
	if x < 1 or x > #grid or y < 1 or y > #grid[x] then
		return -1
	end
	return grid[x][y]
end

local function dfs(grid, x, y, value, visited)
	-- part 2 doesn't need a visited map
	if visited ~= nil and visited[x] ~= nil then
		if visited[x][y] then
			return 0
		end
	end

	local cell = grid_at(grid, x, y)

	if cell == -1 or cell ~= value + 1 then
		return 0
	end

	-- part 2 doesn't need a visited map
	if visited ~= nil then
		visited[x] = visited[x] or {}
		visited[x][y] = true
	end

	if cell == 9 then
		return 1
	end

	return dfs(grid, x + 1, y, cell, visited)
		+ dfs(grid, x - 1, y, cell, visited)
		+ dfs(grid, x, y + 1, cell, visited)
		+ dfs(grid, x, y - 1, cell, visited)
end

function M.part1(lines)
	lines = lines or util.lines_from("./day10/input.txt")
	local grid = util.to_grid(lines)

	for i, row in ipairs(grid) do
		for j, cell in ipairs(row) do
			grid[i][j] = tonumber(cell)
		end
	end

	local start_positions = util.find_all_positions_of(grid, 0)

	local sum = 0
	for _, pos in ipairs(start_positions) do
		local x, y = pos[1], pos[2]
		sum = sum + dfs(grid, x, y, -1, {})
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day10/input.txt")
	local grid = util.to_grid(lines)

	for i, row in ipairs(grid) do
		for j, cell in ipairs(row) do
			grid[i][j] = tonumber(cell)
		end
	end

	local start_positions = util.find_all_positions_of(grid, 0)

	local sum = 0
	for _, pos in ipairs(start_positions) do
		local x, y = pos[1], pos[2]
		sum = sum + dfs(grid, x, y, -1, nil)
	end

	return sum
end

function M.tests()
	local input = util.lines_from("./day10/test.txt")
	util.run_test(M.part1, input, 36)
	util.run_test(M.part2, input, 81)
end

return M
