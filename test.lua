local red = "\27[31m" -- Red text
local green = "\27[32m" -- Green text
local reset = "\27[0m" -- Reset to default color

local function test(module)
	local m = require(module)

	local test_success, error = pcall(m.tests)

	if test_success then
		print(green .. "Tests for " .. module .. " passed!" .. reset)
	else
		print(red .. "Tests for " .. module .. " failed!" .. reset .. "\n" .. error)
	end
end

test("day1")
test("day2")
test("day3")
test("day4")
test("day5")
test("day6")
test("day7")
test("day8")
test("day9")
test("day10")
test("day11")
test("day12")
test("day13")
test("day14")
test("day15")
test("day16")
test("day17")
test("day18")
test("day19")
test("day20")
-- test("day21")
test("day22")
test("day23")
test("day24")
