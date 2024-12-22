local util = require("util")

local M = {}

local function calculate(number, cycles)
	local result = 0

	for _ = 1, cycles do
		result = number << 6
		number = number ~ result
		number = number % 16777216
		result = number >> 5
		number = number ~ result
		number = number % 16777216
		result = number << 11
		number = number ~ result
		number = number % 16777216
	end

	return number
end

function M.part1(lines)
	lines = lines or util.lines_from("./day22/input.txt")

	local sum = 0
	for _, line in ipairs(lines) do
		sum = sum + calculate(tonumber(line), 2000)
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day22/input.txt")
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.tests()
	local input = util.lines_from("./day22/test.txt")
	util.run_test(M.part1, input, 37327623)
	util.run_test(M.part2, input, 0)
end

return M
