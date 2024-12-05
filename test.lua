local red = "\27[31m" -- Red text
local green = "\27[32m" -- Green text
local reset = "\27[0m" -- Reset to default color

local function test(module)
	local m = require(module)
	if pcall(m.tests) then
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
