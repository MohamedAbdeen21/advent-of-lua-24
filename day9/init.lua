local util = require("util")

local M = {}

local function to_memory(line)
	local fid = 0
	local disk = {}
	local i = 0
	for char in line:gmatch(".") do
		i = i + 1
		if i % 2 ~= 0 then
			for _ = 1, tonumber(char) do
				table.insert(disk, fid)
			end
			fid = fid + 1
		else
			for _ = 1, tonumber(char) do
				table.insert(disk, -1)
			end
		end
	end
	return disk
end

function M.part1(lines)
	lines = lines or util.lines_from("./day9/input.txt")

	local disk = to_memory(lines[1])

	local right = #disk
	local left = 1

	while left < right do
		if disk[left] == -1 then
			disk[left] = disk[right]
			disk[right] = -1
			while disk[right] == -1 and right > left do
				right = right - 1
			end
		end
		left = left + 1
	end

	local checksum = 0
	for i, cell in ipairs(disk) do
		if cell == -1 then
			break
		end
		checksum = checksum + ((i - 1) * cell)
	end

	return checksum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day9/input.txt")
	local line = lines[1]

	-- file fid -> { start, size }
	---@type { number: {start: number, size: number} }
	local files = {}
	---@type  {start: number, size: number}[]
	local blanks = {}

	local current_fid = 0
	local pos = 1

	for i = 1, #line do
		local size = tonumber(line:sub(i, i))
		if i % 2 == 0 then
			table.insert(blanks, { start = pos, size = size })
		else
			files[current_fid] = { start = pos, size = size }
			current_fid = current_fid + 1
		end
		pos = pos + size
	end

	local sorted_fids = {}
	for fid, _ in pairs(files) do
		table.insert(sorted_fids, fid)
	end
	table.sort(sorted_fids, util.cmp_desc)

	local i = 1
	local len = #sorted_fids

	for _, blank in ipairs(blanks) do
		-- for perf reasons, I need to delete elements while iterating
		-- this is the best way to do it AFAIK
		while i <= len do
			local fid = sorted_fids[i]
			local file = files[fid]
			if file == nil or file.size > blank.size then
				goto continue
			elseif file.start < blank.start then
				table.remove(sorted_fids, i)
				i = i - 1
				len = len - 1

				goto continue
			elseif file.size <= blank.size then
				table.remove(sorted_fids, i)
				i = i - 1
				len = len - 1

				files[fid].start = blank.start

				blank.size = blank.size - file.size
				blank.start = blank.start + file.size

				if blank.size == 0 then
					break
				end
			end
			::continue::
			i = i + 1
		end
		i = 1
	end

	local checksum = 0

	for fid, file in pairs(files) do
		local start = file.start - 1
		local size = file.size
		local sum = size * (2 * start + size - 1) // 2
		checksum = checksum + sum * fid
	end

	return checksum
end

function M.tests()
	local input = util.lines_from("./day9/test.txt")
	util.run_test(M.part1, input, 1928)
	util.run_test(M.part2, input, 2858)
end

return M
