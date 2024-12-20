local util = require("util")

local M = {}

local function grid_at(grid, x, y)
	if x < 1 or x > #grid or y < 1 or y > #grid[x] then
		return ""
	end
	return grid[x][y]
end

local function bfs(grid, start)
	local queue = { { start[1], start[2], 0 } }
	local distances = {}

	while #queue > 0 do
		local x, y, score = table.unpack(table.remove(queue, 1))
		distances[x] = distances[x] or {}

		local cell = grid_at(grid, x, y)

		-- nil entry means either it's a wall or not visited yet
		if (cell == "." or cell == "S" or cell == "E") and distances[x][y] == nil then
			distances[x][y] = score
			table.insert(queue, { x - 1, y, score + 1 })
			table.insert(queue, { x + 1, y, score + 1 })
			table.insert(queue, { x, y - 1, score + 1 })
			table.insert(queue, { x, y + 1, score + 1 })
		end
	end

	return distances
end

local function count_cheats(grid, allowed, save)
	local start = util.find_all_positions_of(grid, "S")[1]

	local distances = bfs(grid, start)

	local cheats = 0

	for x, row in pairs(distances) do
		for y, distance in pairs(row) do
			-- check all the possible places, use a diamond shape and check distance
			for i = -allowed, allowed do
				for j = -allowed, allowed do
					local cheated = math.abs(i) + math.abs(j)

					if cheated <= allowed then
						local nx, ny = x + i, y + j

						if
							distances[nx]
							and distances[nx][ny]
							and math.abs(distances[nx][ny] - distance) >= save + cheated
						then
							cheats = cheats + 1
						end
					end
				end
			end
		end
	end

	return cheats // 2
end

function M.part1(lines, save)
	lines = lines or util.lines_from("./day20/input.txt")
	save = save or 100
	local grid = util.to_grid(lines)

	return count_cheats(grid, 2, save)
end

function M.part2(lines, save)
	lines = lines or util.lines_from("./day20/input.txt")
	save = save or 100
	local grid = util.to_grid(lines)

	return count_cheats(grid, 20, save)
end

function M.tests()
	local input = util.lines_from("./day20/test.txt")
	util.run_test_args(8, M.part1, input, 12)
	util.run_test_args(1, M.part1, input, 64)
	util.run_test_args(29, M.part2, input, 72)
end

return M
