local util = require("util")

local M = {}

local function split(lines)
	local reports = {}

	for _, line in ipairs(lines) do
		local report = {}
		for number in line:gmatch("(%d+)[%s|\n]*") do
			table.insert(report, tonumber(number))
		end
		table.insert(reports, report)
	end

	return reports
end

local function is_safe(report)
	local is_asc = util.is_sorted(report)
	local is_desc = util.is_sorted(report, util.cmp_desc)

	if not (is_asc or is_desc) then
		return false
	end

	for i = 2, #report do
		local diff = math.abs(report[i] - report[i - 1])
		if diff < 1 or diff > 3 then
			return false
		end
	end

	return true
end

function M.part1(lines)
	lines = lines or util.lines_from("./day2/input.txt")
	local reports = split(lines)

	local sum = 0

	for _, report in ipairs(reports) do
		if is_safe(report) then
			sum = sum + 1
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day2/input.txt")
	local reports = split(lines)

	local sum = 0

	for _, report in ipairs(reports) do
		for i = 1, #report do
			local value = table.remove(report, i)
			if is_safe(report) then
				sum = sum + 1
				break
			end
			table.insert(report, i, value)
		end
	end

	return sum
end

function M.tests()
	assert(M.part1(util.lines_from("./day2/test.txt")) == 2)
	assert(M.part2(util.lines_from("./day2/test.txt")) == 4)
end

return M
