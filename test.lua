local red = "\27[31m" -- Red text
local green = "\27[32m" -- Green text
local reset = "\27[0m" -- Reset to default color

local function test(module)
	local m = require(module)

	-- suppress calls to print
	local p = print
	print = function() end

	local test_success = pcall(m.tests)

	-- restore print functionality
	print = p

	if test_success then
		print(green .. "Tests for " .. module .. " passed!" .. reset)
	else
		print(red .. "Tests for " .. module .. " failed!" .. reset)
	end
end

test("day1")
test("day2")
test("day3")
test("day4")
test("day5")
test("day6")
