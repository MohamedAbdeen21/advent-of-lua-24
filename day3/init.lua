local util = require("util")

local lines = util.lines_from("./day3/input.txt")

local numbers = {}

-- part1
for _, line in ipairs(lines) do
	for a, b in line:gmatch("mul%((%d+),(%d+)%)") do
		table.insert(numbers, tonumber(a))
		table.insert(numbers, tonumber(b))
	end
	assert(#numbers % 2 == 0)
end

local sum1 = 0

for i = 1, #numbers, 2 do
	sum1 = sum1 + numbers[i] * numbers[i + 1]
end

print("Part 1:", sum1)

-- part2
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

local sum2 = 0

for i = 1, #do_numbers, 2 do
	sum2 = sum2 + do_numbers[i] * do_numbers[i + 1]
end

print("Part 2:", sum2)
