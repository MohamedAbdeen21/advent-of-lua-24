local util = require("util")

local M = {}

local function split(input)
	local targets, lines = {}, {}

	for _, inp in ipairs(input) do
		local target, remainder = inp:match("(%d+):(.+)$")
		table.insert(targets, tonumber(target))

		local line = {}
		for number in remainder:gmatch("(%d+)[%s|\n]*") do
			table.insert(line, tonumber(number))
		end
		table.insert(lines, line)
	end

	return targets, lines
end

local function concat_numbers(a, b)
	return tonumber(tostring(a) .. tostring(b))
end

local function can_achieve_target(part, target, line)
	local function backtrack(target_, line_, accum, index)
		if accum == target_ and index == #line_ + 1 then
			return true
		end

		if accum > target_ or index > #line_ then
			return false
		end

		local value = line_[index]

		return backtrack(target_, line_, accum + value, index + 1)
			or backtrack(target_, line_, accum * value, index + 1)
			or part == 2 and backtrack(target_, line_, concat_numbers(accum, value), index + 1)
	end

	return backtrack(target, line, line[1], 2)
end

function M.part1(lines)
	lines = lines or util.lines_from("./day7/input.txt")
	local targets, values = split(lines)

	local sum = 0

	for i = 1, #targets do
		if can_achieve_target(1, targets[i], values[i]) then
			sum = sum + targets[i]
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day7/input.txt")
	local targets, values = split(lines)

	local sum = 0

	for i = 1, #targets do
		if can_achieve_target(2, targets[i], values[i]) then
			sum = sum + targets[i]
		end
	end

	return sum
end

function M.tests()
	local input = util.lines_from("./day7/test.txt")
	util.run_test(M.part1, input, 3749)
	util.run_test(M.part2, input, 11387)
end

return M
