local util = require("util")

local M = {}

local function split_input(input)
	local result = {}
	for stone in input:gmatch("(%d+)%s?") do
		table.insert(result, tonumber(stone))
	end
	return result
end

local function apply_rules(stones)
	local result = {}
	for _, stone in ipairs(stones) do
		local repr = tostring(stone)
		local size = #repr

		if stone == 0 then
			table.insert(result, 1)
		elseif size % 2 == 0 then
			local left, right = repr:sub(1, size / 2), repr:sub(size / 2 + 1, size)
			table.insert(result, tonumber(left))
			table.insert(result, tonumber(right))
		else
			table.insert(result, stone * 2024)
		end
	end
	return result
end

local function count(stone, depth)
	if depth == 0 then
		return 1
	end

	if stone == 0 then
		return count(1, depth - 1)
	end

	local repr = tostring(stone)
	local size = #repr
	if size % 2 == 0 then
		local left, right = repr:sub(1, size / 2), repr:sub(size / 2 + 1, size)
		return count(tonumber(left), depth - 1) + count(tonumber(right), depth - 1)
	end

	return count(stone * 2024, depth - 1)
end

function M.part1(lines)
	lines = lines or util.lines_from("./day11/input.txt")
	local stones = split_input(lines[1])
	for _ = 1, 25 do
		stones = apply_rules(stones)
	end
	return #stones
end

function M.part2(lines)
	lines = lines or util.lines_from("./day11/input.txt")
	local stones = split_input(lines[1])

	count = util.cache_decorator(count)

	local sum = 0
	for _, stone in ipairs(stones) do
		sum = sum + count(stone, 75)
	end
	return sum
end

function M.tests()
	local input = util.lines_from("./day11/test.txt")
	util.run_test(M.part1, input, 55312)
	util.run_test(M.part2, input, 65601038650482)
end

return M
