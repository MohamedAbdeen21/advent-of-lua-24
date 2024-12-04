local lfs = require("lfs")

local function create_directory(dir_name)
	local success, err = lfs.mkdir(dir_name)
	if not success then
		print("Error creating directory:", err)
		return false
	end
	return true
end

local function create_file(file_name, content)
	local file, err = io.open(file_name, "w")
	if not file then
		print("Error creating file:", err)
		return false
	end
	file:write(content or "")
	file:close()
	return true
end

local day = arg[1]

assert(day, "missing day")
assert(tonumber(day) ~= nil, "day must be a number")

local dir_name = "./day" .. day
local input_file = dir_name .. "/input.txt"
local test_file = dir_name .. "/test.txt"
local code_file = dir_name .. "/init.lua"

local boilerplate = string.format(
	[[
local util = require("util")

local M = {}

function M.part1(lines)
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.part2(lines)
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
	day
)

if
	create_directory(dir_name)
	and create_file(input_file, "")
	and create_file(test_file, "")
	and create_file(code_file, boilerplate)
then
	print("Done scaffolding")
else
	print("Failed to scaffold")
end
