local util = require("util")

local M = {}

local function calculate(number, cycles, numbers)
	local result = 0

	for _ = 1, cycles do
		if numbers then
			table.insert(numbers, number % 10)
		end
		result = number << 6
		number = number ~ result % 16777216
		result = number >> 5
		number = number ~ result % 16777216
		result = number << 11
		number = number ~ result % 16777216
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

	local all_prices = {}
	local prices = {}
	for _, line in ipairs(lines) do
		calculate(tonumber(line), 2000, prices)
		table.insert(all_prices, prices)
		prices = {}
	end

	local all_changes = {}
	for _, number in ipairs(all_prices) do
		local seen = {}
		for i = 1, #number - 4 do
			local change = number[i + 1] - number[i]
				.. number[i + 2] - number[i + 1]
				.. number[i + 3] - number[i + 2]
				.. number[i + 4] - number[i + 3]

			if not seen[change] then
				seen[change] = true
				all_changes[change] = (all_changes[change] or 0) + number[i + 4]
			end
		end
	end

	local maximum = 0
	for _, count in pairs(all_changes) do
		if count > maximum then
			maximum = count
		end
	end

	return maximum
end

function M.tests()
	local input = util.lines_from("./day22/test.txt")
	local input2 = util.lines_from("./day22/test2.txt")
	util.run_test(M.part1, input, 37327623)
	util.run_test(M.part2, input2, 23)
end

return M
