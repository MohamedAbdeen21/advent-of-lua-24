local util = require("util")

local M = {}

local function is_target_after_num(update, num, target)
	local num_index = -1
	local target_index = -1
	for i, n in ipairs(update) do
		if n == num then
			num_index = i
		elseif n == target then
			target_index = i
		end
	end

	if num_index == -1 or target_index == -1 then
		return true
	end

	return num_index < target_index
end

local function split_input(lines)
	local ordering = {}
	local updates = {}
	local switch = true

	for _, line in ipairs(lines) do
		if line:match("^%s*$") then
			switch = false
		elseif switch then
			local a, b = line:match("(%d+)|(%d+)")
			ordering[#ordering + 1] = { tonumber(a), tonumber(b) }
		else
			local nums = {}
			for num in line:gmatch("%d+") do
				nums[#nums + 1] = tonumber(num)
			end
			updates[#updates + 1] = nums
		end
	end

	return ordering, updates
end

local function span_updates(ordering, updates)
	local correct_updates = {}
	local incorrect_updates = {}

	for _, update in ipairs(updates) do
		for _, order in ipairs(ordering) do
			if not is_target_after_num(update, order[1], order[2]) then
				incorrect_updates[#incorrect_updates + 1] = update
				goto continue
			end
		end
		correct_updates[#correct_updates + 1] = update
		::continue::
	end

	return correct_updates, incorrect_updates
end

function M.part1(lines)
	lines = lines or util.lines_from("./day5/input.txt")
	local ordering, updates = split_input(lines)

	local correct_updates, _ = span_updates(ordering, updates)

	local sum = 0
	for _, update in ipairs(correct_updates) do
		sum = sum + update[math.ceil(#update/2)]
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day5/input.txt")
	local ordering, updates = split_input(lines)

	---@type table<number, table<number>>
	local before = {}

	for _, order in ipairs(ordering) do
		before[order[2]] = before[order[2]] or {}
		before[order[2]][order[1]] = true
	end

	-- This relies on SO many assumptions ... I'm sorry, but it works
	local _, incorrect_updates = span_updates(ordering, updates)

	for _, update in ipairs(incorrect_updates) do
		table.sort(update, function(a, b)
			return before[a] ~= nil and before[a][b] == true
		end)
	end


	local sum = 0
	for _, update in ipairs(incorrect_updates) do
		sum = sum + update[math.ceil(#update/2)]
	end

	return sum
end

function M.tests()
	assert(M.part1(util.lines_from("./day5/test.txt")) == 143)
	assert(M.part2(util.lines_from("./day5/test.txt")) == 123)
end

return M
