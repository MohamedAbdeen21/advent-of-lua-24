local util = require("util")

local M = {}

local function to_robots(lines)
	-- assume the max x and the max y are the size of the grid
	local robots, max_x, max_y = {}, 0, 0

	for _, line in ipairs(lines) do
		local x, y, vx, vy = line:match("p=(%d+),(%d+) v=(-?%d+),(-?%d+)")
		x, y, vx, vy = tonumber(x), tonumber(y), tonumber(vx), tonumber(vy)

		table.insert(robots, { x = x, y = y, vx = vx, vy = vy })

		max_x = math.max(max_x, x)
		max_y = math.max(max_y, y)
	end

	return robots, max_x + 1, max_y + 1
end

local function make_key(x, y)
	return x .. "," .. y
end

local function dfs(positions, x, y, component)
	local key = make_key(x, y)
	if positions[key] ~= -1 then
		return
	end

	positions[key] = component

	dfs(positions, x - 1, y, component)
	dfs(positions, x + 1, y, component)
	dfs(positions, x, y - 1, component)
	dfs(positions, x, y + 1, component)
end

local function connected_components(positions)
	local components = 0
	for key, component in pairs(positions) do
		if component == -1 then
			local x, y = key:match("(%d+),(%d+)")
			x, y = tonumber(x), tonumber(y)

			dfs(positions, x, y, components)
			components = components + 1
		end
	end

	return components
end

function M.part1(lines)
	lines = lines or util.lines_from("./day14/input.txt")
	local seconds = 100
	local robots, x, y = to_robots(lines)

	local hx = x // 2
	local hy = y // 2

	local quadrants = { 0, 0, 0, 0 }
	for _, robot in ipairs(robots) do
		robot.x = (robot.x + robot.vx * seconds) % x
		robot.y = (robot.y + robot.vy * seconds) % y

		if robot.x == hx or robot.y == hy then
		elseif robot.x <= hx and robot.y <= hy then
			quadrants[1] = quadrants[1] + 1
		elseif robot.x <= hx and robot.y > hy then
			quadrants[2] = quadrants[2] + 1
		elseif robot.x > hx and robot.y <= hy then
			quadrants[3] = quadrants[3] + 1
		else
			quadrants[4] = quadrants[4] + 1
		end
	end

	local product = 1

	for _, count in ipairs(quadrants) do
		product = product * count
	end

	return product
end

function M.part2(lines)
	lines = lines or util.lines_from("./day14/input.txt")
	local robots, x, y = to_robots(lines)

	-- most robots are connected means
	-- least number of connected components
	local min_components = 99999999999999999
	local min_seconds = 0

	for i = 1, 10000 do
		local positions = {}
		for _, robot in ipairs(robots) do
			robot.x = (robot.x + robot.vx) % x
			robot.y = (robot.y + robot.vy) % y

			-- position and which component does it belong to
			positions[robot.x .. "," .. robot.y] = -1
		end

		local num_components = connected_components(positions)
		if num_components < min_components then
			min_components = num_components
			min_seconds = i
		end
	end

	return min_seconds
end

function M.tests()
	local input = util.lines_from("./day14/test.txt")
	util.run_test(M.part1, input, 12)
	-- util.run_test(M.part2, input, 0)
end

return M
