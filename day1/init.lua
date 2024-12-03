local util = require("util")

local M = {}

local function split(lines)
	local left, right = {}, {}

	for _, line in ipairs(lines) do
		local a, b = line:match("(%d+)%s+(%d+)")
		assert(a and b, "Malformed line: " .. line) -- Ensure correct format
		table.insert(left, tonumber(a))
		table.insert(right, tonumber(b))
	end

	return left, right
end

function M.part1(lines)
	lines = lines or util.lines_from("./day1/input.txt")
	local left, right = split(lines)

	table.sort(left)
	table.sort(right)

	local sum = 0

	for i = 1, #left do
		sum = sum + math.abs(left[i] - right[i])
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day1/input.txt")
	local left, right = split(lines)

	local frequency = {}

	for _, value in ipairs(right) do
		frequency[value] = (frequency[value] or 0) + 1
	end

	local sum = 0

	for _, value in ipairs(left) do
		if frequency[value] then
			sum = sum + value * frequency[value]
		end
	end

	return sum
end

function M.tests()
	assert(M.part1(util.lines_from("./day1/test.txt")) == 11)
	assert(M.part2(util.lines_from("./day1/test.txt")) == 31)
end

return M
