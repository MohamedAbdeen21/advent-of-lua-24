local lfs = require("lfs")

local function create_directory(dir_name)
	local success, err = lfs.mkdir(dir_name)
	if not success then
		print("Error creating directory:", err)
		return false
	end
	return true
end

local function touch_file(file_name, content, mode)
	local file, err = io.open(file_name, mode or "w")
	if not file then
		print("Error creating file:", err)
		return false
	end
	file:write(content or "")
	file:close()
	return true
end

local function create_file(file_name, content)
	return touch_file(file_name, content, "w")
end

local function append_file(file_name, content)
	return touch_file(file_name, content, "a+")
end

local day = arg[1]

assert(day, "missing day")
assert(tonumber(day) ~= nil, "day must be a number")

local dir_name = "./day" .. day
local input_file = dir_name .. "/input.txt"
local test_file = dir_name .. "/test.txt"
local code_file = dir_name .. "/init.lua"
local main_test_file = "./test.lua"

local boilerplate = string.format(
	[[
local util = require("util")

local M = {}

function M.part1(lines)
	lines = lines or util.lines_from("./day%s/input.txt")
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.part2(lines)
	lines = lines or util.lines_from("./day%s/input.txt")
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.tests()
	assert(M.part1(util.lines_from("./day%s/test.txt")) == 0)
	assert(M.part2(util.lines_from("./day%s/test.txt")) == 0)
end

return M
]],
	day,
	day,
	day,
	day
)

if
	create_directory(dir_name)
	and create_file(input_file, "")
	and create_file(test_file, "")
	and create_file(code_file, boilerplate)
	and append_file(main_test_file, 'test("day' .. day .. '")\n')
then
	print("Scaffolding successfull")
else
	print("Scaffolding failed")
end
