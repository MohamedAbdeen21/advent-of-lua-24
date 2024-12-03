local util = require("util")

local M = {}

function M.part1(lines)
	lines = lines or util.lines_from("./day3/input.txt")

	local numbers = {}

	for _, line in ipairs(lines) do
		for a, b in line:gmatch("mul%((%d+),(%d+)%)") do
			table.insert(numbers, tonumber(a))
			table.insert(numbers, tonumber(b))
		end
		assert(#numbers % 2 == 0)
	end

	local sum = 0

	for i = 1, #numbers, 2 do
		sum = sum + numbers[i] * numbers[i + 1]
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day3/input.txt")

	local do_numbers = {}

	local word = ""
	local mul = true

	for _, line in ipairs(lines) do
		for char in line:gmatch(".") do
			word = word .. char
			if word:match("do%(%)") then
				mul, word = true, ""
			elseif word:match("don't%(%)") then
				mul, word = false, ""
			elseif word:match("mul%((%d+),(%d+)%)") then
				local a, b = word:match("mul%((%d+),(%d+)%)")
				if mul then
					table.insert(do_numbers, tonumber(a))
					table.insert(do_numbers, tonumber(b))
				end
				word = ""
			end
		end
		assert(#do_numbers % 2 == 0)
	end

	local sum = 0

	for i = 1, #do_numbers, 2 do
		sum = sum + do_numbers[i] * do_numbers[i + 1]
	end

	return sum
end

function M.tests()
	assert(M.part1(util.lines_from("./day3/test1.txt")) == 161)
	assert(M.part2(util.lines_from("./day3/test2.txt")) == 48)
end

return M
