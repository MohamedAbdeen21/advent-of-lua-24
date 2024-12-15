local util = require("util")

local M = {}

local function split(lines)
	local sections = util.section_input(lines)

	local grid, movements = sections[1], sections[2]

	grid = util.to_grid(grid)

	local movement = {}
	for _, mov in ipairs(movements) do
		for m in mov:gmatch(".") do
			table.insert(movement, m)
		end
	end

	return grid, movement
end

local function push_box(grid, x, y, direction)
	local dx, dy = direction[1], direction[2]
	local cell = grid[x][y]

	-- don't have to worry about x existing
	if cell == "." then
		return true
	elseif cell == "#" then
		return false
	elseif push_box(grid, x + dx, y + dy, direction) then
		grid[x][y] = "."
		grid[x + dx][y + dy] = "O"
		return true
	end
end

local function double_width(grid)
	local new_grid = {}

	for i, row in ipairs(grid) do
		new_grid[i] = {}
		for _, cell in ipairs(row) do
			if cell == "O" then
				table.insert(new_grid[i], "[")
				table.insert(new_grid[i], "]")
			elseif cell == "@" then
				table.insert(new_grid[i], "@")
				table.insert(new_grid[i], ".")
			else
				table.insert(new_grid[i], cell)
				table.insert(new_grid[i], cell)
			end
		end
	end

	return new_grid
end

--[[
	 assume this case ...#
					  [][]
					   []
	 need a verification function before actually executing the push
	 and to avoid duplicating the logic, we add the "push" flag here
	 and name the function "process" instead of push
]]
local function process_double_box(grid, x, y, direction, push)
	if grid[x][y] == "#" then
		return false
	elseif grid[x][y] == "." then
		return true
	end

	local dx, dy = direction[1], direction[2]
	local nx, ny = x + dx, y + dy

	-- 1 or -1
	local other_half = 0
	if grid[x][y] == "[" then
		other_half = 1
	elseif grid[x][y] == "]" then
		other_half = -1
	end

	local ignore_half = dy == -1 and other_half == 1 or dy == 1 and other_half == -1
	if ignore_half then
		return process_double_box(grid, nx, ny, direction, push)
	end

	if
		process_double_box(grid, nx, ny, direction, false)
		and process_double_box(grid, nx, ny + other_half, direction, false)
	then
		if push then
			process_double_box(grid, nx, ny + other_half, direction, true)
			process_double_box(grid, nx, ny, direction, true)
			grid[nx][ny + other_half], grid[x][y + other_half] = grid[x][y + other_half], grid[nx][ny + other_half]
			grid[nx][ny], grid[x][y] = grid[x][y], grid[nx][ny]
		end
		return true
	end

	return false
end

function M.part1(lines)
	lines = lines or util.lines_from("./day15/input.txt")
	local grid, movements = split(lines)
	local start = util.find_all_positions_of(grid, "@")

	local x, y = start[1][1], start[1][2]

	for _, m in ipairs(movements) do
		local dx, dy = 0, 0
		if m == "<" then
			dy = -1
		elseif m == ">" then
			dy = 1
		elseif m == "^" then
			dx = -1
		elseif m == "v" then
			dx = 1
		end

		if push_box(grid, x + dx, y + dy, { dx, dy }) then
			grid[x][y] = "."
			x, y = x + dx, y + dy
			grid[x][y] = "@"
		end
	end

	local boxes = util.find_all_positions_of(grid, "O")
	local score = 0

	for _, box in ipairs(boxes) do
		score = score + (box[1] - 1) * 100 + (box[2] - 1)
	end

	return score
end

function M.part2(lines)
	lines = lines or util.lines_from("./day15/input.txt")
	local grid, movements = split(lines)

	grid = double_width(grid)
	local start = util.find_all_positions_of(grid, "@")

	local x, y = start[1][1], start[1][2]

	for _, m in ipairs(movements) do
		local dx, dy = 0, 0
		if m == "<" then
			dy = -1
		elseif m == ">" then
			dy = 1
		elseif m == "^" then
			dx = -1
		elseif m == "v" then
			dx = 1
		end

		if process_double_box(grid, x + dx, y + dy, { dx, dy }, true) then
			grid[x][y] = "."
			x, y = x + dx, y + dy
			grid[x][y] = "@"
		end
	end

	local boxes = util.find_all_positions_of(grid, "[")
	local score = 0

	for _, box in ipairs(boxes) do
		score = score + (box[1] - 1) * 100 + (box[2] - 1)
	end

	return score
end

function M.tests()
	local input = util.lines_from("./day15/test.txt")
	local input2 = util.lines_from("./day15/test2.txt")
	util.run_test(M.part1, input, 10092)
	util.run_test(M.part2, input2, 9021)
end

return M
