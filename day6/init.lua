local util = require("util")

local M = {}

local function grid_at(grid, x, y)
	if x < 1 or x > #grid or y < 1 or y > #grid[x] then
		return ""
	end
	return grid[x][y]
end

local function turn_right(direction)
	local x, y = direction[1], direction[2]
	if x == 0 and y == 1 then
		return { 1, 0 }
	elseif x == 1 and y == 0 then
		return { 0, -1 }
	elseif x == 0 and y == -1 then
		return { -1, 0 }
	elseif x == -1 and y == 0 then
		return { 0, 1 }
	end
end

local function dfs(grid, x, y, direction, visited)
	visited[x .. "," .. y] = true
	local dx, dy = direction[1], direction[2]
	x, y = x + dx, y + dy
	if grid_at(grid, x, y) == "" then
		return
	end
	if grid_at(grid, x, y) == "#" then
		return dfs(grid, x - dx, y - dy, turn_right(direction), visited)
	end
	if grid_at(grid, x, y) == "." or grid_at(grid, x, y) == "^" then
		return dfs(grid, x, y, direction, visited)
	end
end

local function is_loop(grid, x, y, direction, visited_with_dir)
	local dx, dy = direction[1], direction[2]

	local key = x .. "," .. y .. "," .. dx .. "," .. dy

	if visited_with_dir[key] then
		return true
	end

	visited_with_dir[key] = true

	x, y = x + dx, y + dy
	local cell = grid_at(grid, x, y)
	if cell == "" then
		return false
	elseif cell == "#" then
		return is_loop(grid, x - dx, y - dy, turn_right(direction), visited_with_dir)
	elseif cell == "." or cell == "^" then
		return is_loop(grid, x, y, direction, visited_with_dir)
	end
end

function M.part1(lines)
	lines = lines or util.lines_from("./day6/input.txt")
	local grid = util.to_grid(lines)
	local start = util.find_all_positions_of(grid, "^")[1]
	local x, y = start[1], start[2]
	local direction = { -1, 0 } -- starts facing up

	local visited = {}
	dfs(grid, x, y, direction, visited)

	local sum = 0

	for _, _ in pairs(visited) do
		sum = sum + 1
	end

	return sum
end

function M.part2(lines)
	print("Day 6 Part 2 takes about 10 seconds to complete")
	lines = lines or util.lines_from("./day6/input.txt")
	---@type table{number, table{number, string}}
	local grid = util.to_grid(lines)
	local start = util.find_all_positions_of(grid, "^")[1]
	local direction = { -1, 0 } -- starts facing up

	local visited = {}
	dfs(grid, start[1], start[2], direction, visited)

	-- can't place obstacle in the start position
	visited[start[1] .. "," .. start[2]] = nil

	local sum = 0

	for key, _ in pairs(visited) do
		local x, y = string.match(key, "(%d+),(%d+)")
		x, y = tonumber(x), tonumber(y)

		---@diagnostic disable-next-line: need-check-nil
		grid[x][y] = "#"

		if is_loop(grid, start[1], start[2], direction, {}) then
			sum = sum + 1
		end

		---@diagnostic disable-next-line: need-check-nil
		grid[x][y] = "."
	end

	return sum
end

function M.tests()
	local input = util.lines_from("./day6/test.txt")
	util.run_test(M.part1, input, 41)
	util.run_test(M.part2, input, 6)
end

return M
