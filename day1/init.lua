local util = require("util")

local lines = util.lines_from("./day1/input.txt")

-- part 1
local left, right = {}, {}

for _, line in ipairs(lines) do
	local a, b = line:match("(%d+)%s+(%d+)")
	assert(a and b, "Malformed line: " .. line) -- Ensure correct format
	table.insert(left, tonumber(a))
	table.insert(right, tonumber(b))
end

table.sort(left)
table.sort(right)

local sum1 = 0

for i = 1, #left do
	sum1 = sum1 + math.abs(left[i] - right[i])
end

print("Part 1:", sum1)

-- part 2
local frequency = {}

for _, value in ipairs(right) do
	frequency[value] = (frequency[value] or 0) + 1
end

local sum2 = 0

for _, value in ipairs(left) do
	if frequency[value] then
		sum2 = sum2 + value * frequency[value]
	end
end

print("Part 2:", sum2)
