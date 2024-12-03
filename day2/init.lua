local util = require("util")

local lines = util.lines_from("./day2/input.txt")

local reports = {}

for _, line in ipairs(lines) do
	local report = {}
	for number in line:gmatch("(%d+)[%s|\n]*") do
		table.insert(report, tonumber(number))
	end
	table.insert(reports, report)
end

local function is_safe(report)
	do
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
end

-- part 1
local sum1 = 0

for _, report in ipairs(reports) do
	if is_safe(report) then
		sum1 = sum1 + 1
	end
end

print("Part 1:", sum1)

-- part 2
local sum2 = 0

for _, report in ipairs(reports) do
	for i = 1, #report do
		local value = table.remove(report, i)
		if is_safe(report) then
			sum2 = sum2 + 1
			break
		end
		table.insert(report, i, value)
	end
end

print("Part 2:", sum2)
