local util = require("util")

local M = {}

local function grid_at(grid, x, y)
	if x < 1 or x > #grid or y < 1 or y > #grid[x] then
		return ""
	end
	return grid[x][y]
end

local function dfs(grid, i, j, cell, visited)
	-- visited map is shared for the same cell/letter
	-- if visited then it's equal and is shared edge, so should
	-- be ignored from perimeter calculations
	if visited[i] and visited[i][j] then
		return -1, 0
	end

	local value = grid_at(grid, i, j)

	if value ~= cell then
		return 0, 0
	end

	visited[i] = visited[i] or {}
	visited[i][j] = true

	local perimeter = 4
	local area = 1

	for _, direction in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
		local di, dj = direction[1], direction[2]
		local adj_perimeter, adj_area = dfs(grid, i + di, j + dj, cell, visited)

		area = area + adj_area
		perimeter = perimeter + adj_perimeter
	end

	-- shared edges don't count, we account for
	-- the root cell in the parent function
	return perimeter - 1, area
end

local function dfs_sum(grid, i, j, cell)
	local visited = {}
	local perimeter, area = dfs(grid, i, j, cell, visited)

	-- mark "island" as visited
	for x, row in pairs(visited) do
		for y, _ in pairs(row) do
			grid[x][y] = "#"
		end
	end

	return visited, perimeter + 1, area
end

-- no shame in a little help: https://youtu.be/KXwKGWSQvS0?t=1620
local function sides(region)
	local corner_candidates = {}

	for r, row in pairs(region) do
		for c, is_present in pairs(row) do
			if is_present then
				for _, offset in ipairs({ { -0.5, -0.5 }, { 0.5, -0.5 }, { 0.5, 0.5 }, { -0.5, 0.5 } }) do
					local cr, cc = r + offset[1], c + offset[2]
					corner_candidates[cr] = corner_candidates[cr] or {}
					corner_candidates[cr][cc] = true
				end
			end
		end
	end

	local total_sides = 0

	for corner_row, row in pairs(corner_candidates) do
		for corner_col, _ in pairs(row) do
			local nearby_cells = {}
			for _, offset in ipairs({ { -0.5, -0.5 }, { 0.5, -0.5 }, { 0.5, 0.5 }, { -0.5, 0.5 } }) do
				local sr, sc = corner_row + offset[1], corner_col + offset[2]
				table.insert(nearby_cells, region[sr] and region[sr][sc] or false)
			end

			local total_nearby_cells = 0
			for _, val in ipairs(nearby_cells) do
				if val then
					total_nearby_cells = total_nearby_cells + 1
				end
			end

			if total_nearby_cells == 1 or total_nearby_cells == 3 then
				total_sides = total_sides + 1
			elseif total_nearby_cells == 2 then
				if (nearby_cells[1] and nearby_cells[3]) or (nearby_cells[2] and nearby_cells[4]) then
					total_sides = total_sides + 2
				end
			end
		end
	end

	return total_sides
end

function M.part1(lines)
	lines = lines or util.lines_from("./day12/input.txt")
	local grid = util.to_grid(lines)

	local sum = 0
	for i, row in ipairs(grid) do
		for j, cell in ipairs(row) do
			if grid[i][j] ~= "#" then
				local _, perimeter, area = dfs_sum(grid, i, j, cell)
				sum = sum + perimeter * area
			end
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day12/input.txt")
	local grid = util.to_grid(lines)

	local sum = 0

	for i, row in ipairs(grid) do
		for j, cell in ipairs(row) do
			if grid[i][j] ~= "#" then
				local region, _, area = dfs_sum(grid, i, j, cell)
				sum = sum + sides(region) * area
			end
		end
	end

	return sum
end

function M.tests()
	local input = util.lines_from("./day12/test.txt")
	util.run_test(M.part1, input, 1930)
	util.run_test(M.part2, input, 1206)
end

return M
