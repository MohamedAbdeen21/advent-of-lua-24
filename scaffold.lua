local lfs = require("lfs")
local http = require("socket.http")
local ltn12 = require("ltn12")
local dotenv = require("lua-dotenv")

dotenv.load_dotenv(".env")

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

local function fetch_input(day)
	local session_token = dotenv.get("AOC_SESSION_TOKEN")
	if not session_token then
		error("AOC_SESSION_TOKEN not found in .env file")
	end

	local year = 2024
	local url = string.format("https://adventofcode.com/%d/day/%d/input", year, day)
	local response_body = {}

	local _, status = http.request({
		url = url,
		sink = ltn12.sink.table(response_body),
		headers = {
			["Cookie"] = "session=" .. session_token,
		},
	})

	if status ~= 200 then
		error(string.format("Failed to fetch input for day %d (HTTP status: %d)", day, status))
	end

	return table.concat(response_body)
end

local function input_only_mode(day, dir_name, input_file)
	local input_content = fetch_input(tonumber(day))
	if not create_directory(dir_name) then
		print("Error creating directory:", dir_name)
		os.exit(1)
	end

	if create_file(input_file, input_content) then
		print("Input successfully fetched and written to", input_file)
	else
		print("Failed to write input to", input_file)
		os.exit(1)
	end
	os.exit(0)
end

local day = arg[1]
local mode = arg[2] -- Optional second argument for mode

assert(day, "missing day")
assert(tonumber(day) ~= nil, "day must be a number")
assert(mode == nil or mode == "--input-only", "invalid mode, nil or --input-only expected")

local dir_name = "./day" .. day
local input_file = dir_name .. "/input.txt"

if mode == "--input-only" then
	input_only_mode(day, dir_name, input_file)
end

-- Regular scaffolding logic
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
    local input = util.lines_from("./day%s/test.txt")
    util.run_test(M.part1, input, 0)
    util.run_test(M.part2, input, 0)
end

return M
]],
	day,
	day,
	day
)

local input_content = fetch_input(tonumber(day))

if
	create_directory(dir_name)
	and create_file(input_file, input_content)
	and create_file(test_file, "")
	and create_file(code_file, boilerplate)
	and append_file(main_test_file, 'test("day' .. day .. '")\n')
then
	print("Scaffolding successful")
else
	print("Scaffolding failed")
end
