local util = require("util")

local M = {}

local function setup_grid(n)
	local grid = {}
	for i = 1, n do
		table.insert(grid, {})
		for _ = 1, n do
			table.insert(grid[i], ".")
		end
	end
	return grid
end

local function bytes_positions(lines, m)
	local positions = {}
	for i, line in ipairs(lines) do
		local x, y = line:match("(%d+),(%d+)")
		table.insert(positions, { x = tonumber(x) + 1, y = tonumber(y) + 1 })
		-- part 1
		if m and i == m then
			break
		end
	end
	return positions
end

local function bfs(grid, n)
	local queue = { { 1, 1, 0 } }

	while #queue > 0 do
		local x, y, score = table.unpack(table.remove(queue, 1))
		if x == n and y == n then
			return score
		end

		if x < 1 or x > n or y < 1 or y > n then
			goto continue
		end

		if grid[x][y] == "." then
			grid[x][y] = "O"
			table.insert(queue, { x - 1, y, score + 1 })
			table.insert(queue, { x + 1, y, score + 1 })
			table.insert(queue, { x, y - 1, score + 1 })
			table.insert(queue, { x, y + 1, score + 1 })
		end

		::continue::
	end

	return -1
end

function M.part1(lines, n, m)
	n = n or 70
	m = m or 1024
	lines = lines or util.lines_from("./day18/input.txt")
	n = n + 1

	local grid = setup_grid(n)
	local positions = bytes_positions(lines, m)

	for _, position in ipairs(positions) do
		grid[position.x][position.y] = "#"
	end

	return bfs(grid, n)
end

function M.part2(lines, n)
	n = n or 70
	lines = lines or util.lines_from("./day18/input.txt")
	n = n + 1

	local positions = bytes_positions(lines)
	local left, right = 1, #positions

	while left < right do
		local grid = setup_grid(n)
		local middle = (left + right) // 2

		for i = 1, middle do
			grid[positions[i].x][positions[i].y] = "#"
		end

		if bfs(grid, n) > 0 then
			left = middle + 1
		else
			right = middle
		end
	end

	return string.format("%d,%d", positions[left].x - 1, positions[left].y - 1)
end

function M.tests()
	local input = util.lines_from("./day18/test.txt")
	util.run_test_args(22, M.part1, input, 6, 12)
	util.run_test_args("6,1", M.part2, input, 6)
end

return M
