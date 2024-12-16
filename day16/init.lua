local util = require("util")

local M = {}

local inf = math.huge
local directions = { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }

local function dfs(grid, x, y, direction, score, visited)
	if visited[x] and visited[x][y] ~= nil and visited[x][y] < score then
		return inf
	end

	if grid[x][y] == "#" then
		return inf
	end

	if grid[x][y] == "E" then
		return score
	end

	visited[x] = visited[x] or {}
	visited[x][y] = score

	local scores = {}
	local dx, dy = direction[1], direction[2]
	for _, d in ipairs(directions) do
		local ddx, ddy = d[1], d[2]
		if ddx == dx and ddy == dy then
			scores[#scores + 1] = dfs(grid, x + ddx, y + ddy, d, score + 1, visited)
		else
			scores[#scores + 1] = dfs(grid, x + ddx, y + ddy, d, score + 1001, visited)
		end
	end

	return math.min(table.unpack(scores))
end

function M.part1(lines)
	lines = lines or util.lines_from("./day16/input.txt")
	local grid = util.to_grid(lines)
	local start = util.find_all_positions_of(grid, "S")

	local x, y = start[1][1], start[1][2]

	return dfs(grid, x, y, { 0, 1 }, 0, {})
end

function M.part2(lines)
	lines = lines or util.lines_from("./day16/input.txt")
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.tests()
	local input = util.lines_from("./day16/test.txt")
	util.run_test(M.part1, input, 7036)
	util.run_test(M.part2, input, 45)
end

return M
