local util = require("util")
local M = {}

local directions = { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }

local function bfs(grid, xi, yi)
	local queue = {}
	local visited = {}
	local best_paths = {}

	queue.front = 1
	queue.rear = 1

	-- encode the path as string to avoid copying a thousand tables
	table.insert(queue, { xi, yi, 0, 1, 0, "" })

	local min_score = math.huge

	while queue.front <= queue.rear do
		local current = queue[queue.front]
		queue.front = queue.front + 1
		local x, y, dx, dy, score, path = current[1], current[2], current[3], current[4], current[5], current[6]

		if score > 100000 or score > min_score then
			goto continue
		end

		local key = x .. "," .. y .. "," .. dx .. "," .. dy
		if visited[key] and visited[key] < score then
			goto continue
		end
		visited[key] = score

		if grid[x][y] == "E" then
			if score < min_score then
				min_score = score
				best_paths = {}
			end

			if score <= min_score then
				table.insert(best_paths, path)
			end
		end

		for _, direction in ipairs(directions) do
			local ddx, ddy = direction[1], direction[2]
			local nx, ny = x + ddx, y + ddy
			if grid[nx][ny] == "#" then
			elseif ddx == dx and ddy == dy then
				queue.rear = queue.rear + 1
				queue[queue.rear] = { nx, ny, dx, dy, score + 1, path .. nx .. "," .. ny .. ";" }
			else
				queue.rear = queue.rear + 1
				queue[queue.rear] = { x, y, ddx, ddy, score + 1000, path }
			end
		end

		::continue::
	end

	return min_score, best_paths
end

function M.part1(lines)
	lines = lines or util.lines_from("./day16/input.txt")
	local grid = util.to_grid(lines)
	local start = util.find_all_positions_of(grid, "S")

	local x, y = start[1][1], start[1][2]

	local score, _ = bfs(grid, x, y)

	return score
end

function M.part2(lines)
	lines = lines or util.lines_from("./day16/input.txt")
	local grid = util.to_grid(lines)
	local start = util.find_all_positions_of(grid, "S")

	local x, y = start[1][1], start[1][2]

	local _, paths = bfs(grid, x, y)

	local unique_paths = {}
	local sum = 0
	for _, path in ipairs(paths) do
		for pair in path:gmatch("([^;]+)") do
			if unique_paths[pair] then
			else
				unique_paths[pair] = true
				sum = sum + 1
			end
		end
	end

	return sum + 1
end

function M.tests()
	local input = util.lines_from("./day16/test.txt")
	util.run_test(M.part1, input, 7036)
	util.run_test(M.part2, input, 45)
end

return M
