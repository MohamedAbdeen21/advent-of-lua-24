local util = require("util")

local M = {}

local function parse(lines)
	local sections = util.section_input(lines)
	local pats = sections[1][1] -- only 1 line
	local patterns = {}

	for pat in pats:gmatch("(%w+),?") do
		patterns[pat] = true
	end

	local designs = {}
	for _, design in ipairs(sections[2]) do
		designs[design] = true
	end

	return patterns, designs
end

local function can_make_design(design, patterns)
	if design == "" then
		return true
	end

	-- limiting this to the length of the longest pattern doesn't impact perf that much
	for i = 1, #design do
		if patterns[design:sub(1, i)] and can_make_design(design:sub(i + 1), patterns) then
			return true
		end
	end

	return false
end

local function count_combinations(design, patterns)
	if design == "" then
		return 1
	end

	local count = 0
	for i = 1, #design do
		if patterns[design:sub(1, i)] then
			count = count + count_combinations(design:sub(i + 1), patterns)
		end
	end

	return count
end

function M.part1(lines)
	lines = lines or util.lines_from("./day19/input.txt")
	local patterns, designs = parse(lines)

	can_make_design = util.cache_decorator(can_make_design)

	-- yes can just use part 2's function and do > 0
	-- but I prefer this for clarity
	local count = 0
	for design in pairs(designs) do
		if can_make_design(design, patterns) then
			count = count + 1
		end
	end

	return count
end

function M.part2(lines)
	lines = lines or util.lines_from("./day19/input.txt")
	local patterns, designs = parse(lines)

	count_combinations = util.cache_decorator(count_combinations)

	local count = 0
	for design in pairs(designs) do
		count = count + count_combinations(design, patterns)
	end

	return count
end

function M.tests()
	local input = util.lines_from("./day19/test.txt")
	util.run_test(M.part1, input, 6)
	util.run_test(M.part2, input, 16)
end

return M
