M = {}

M.cmp_asc = function(a, b)
	return a < b
end

M.cmp_desc = function(a, b)
	return a > b
end

function M.is_sorted(t, cmp)
	cmp = cmp or M.cmp_asc

	for i = 2, #t do
		if not cmp(t[i - 1], t[i]) then
			return false
		end
	end

	return true
end

function M.copy_table(t)
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = v
	end
	return copy
end

function M.are_tables_equal(t1, t2)
	if #t1 ~= #t2 then
		return false
	end

	for i = 1, #t1 do
		if t1[i] ~= t2[i] then
			return false
		end
	end

	return true
end

function M.file_exists(file)
	local f = io.open(file, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end

function M.lines_from(file)
	if not M.file_exists(file) then
		return {}
	end
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

function M.to_grid(lines)
	local matrix = {}

	for i, line in ipairs(lines) do
		matrix[#matrix + 1] = {}
		for j = 1, #line do
			matrix[i][#matrix[i] + 1] = line:sub(j, j)
		end
	end

	return matrix
end

function M.find_all_positions_of(grid, target)
	---@type {x: number, y: number}[]
	local xs = {}

	for i, row in ipairs(grid) do
		for j, col in ipairs(row) do
			if col == target then
				xs[#xs + 1] = { i, j }
			end
		end
	end

	return xs
end

return M
