local util = require("util")

local M = {}

local function to_machines(lines)
	local data = {}
	local currentEntry = {}

	for _, line in ipairs(lines) do
		if line == "" then
			if currentEntry then
				table.insert(data, currentEntry)
				currentEntry = {}
			end
		else
			local ax, ay = line:match("Button A: X%+([%d]+), Y%+([%d]+)")
			if ax and ay then
				currentEntry.A = { X = tonumber(ax), Y = tonumber(ay) }
			end

			local bx, by = line:match("Button B: X%+([%d]+), Y%+([%d]+)")
			if bx and by then
				currentEntry.B = { X = tonumber(bx), Y = tonumber(by) }
			end

			local px, py = line:match("Prize: X=([%d]+), Y=([%d]+)")
			if px and py then
				currentEntry.Prize = { X = tonumber(px), Y = tonumber(py) }
			end
		end
	end

	table.insert(data, currentEntry)

	return data
end

local function matrix_determinant(matrix)
	return matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]
end

-- Cramer's rule
local function solve_system(matrix, constants)
	local det = matrix_determinant(matrix)
	assert(det ~= 0, "No solution")
	local detA = matrix_determinant({ { constants[1], matrix[1][2] }, { constants[2], matrix[2][2] } })
	local detB = matrix_determinant({ { matrix[1][1], constants[1] }, { matrix[2][1], constants[2] } })

	local x = detA / det
	local y = detB / det

	return x, y
end

local function solve_machine(machine, offset)
	offset = offset or 0

	local constants = { machine.Prize.X + offset, machine.Prize.Y + offset }
	local matrix = { { machine.A.X, machine.B.X }, { machine.A.Y, machine.B.Y } }

	local a, b = solve_system(matrix, constants)
	-- ensure both are integers, can also use math.tointeger(..)
	if a % 1 == 0 and b % 1 == 0 then
		return a * 3 + b
	end

	return 0
end

function M.part1(lines)
	lines = lines or util.lines_from("./day13/input.txt")

	local machines = to_machines(lines)

	local tokens = 0
	for _, machine in ipairs(machines) do
		tokens = tokens + solve_machine(machine)
	end

	return tokens
end

function M.part2(lines)
	lines = lines or util.lines_from("./day13/input.txt")

	local machines = to_machines(lines)

	local offset = 10 * 1000 * 1000 * 1000 * 1000

	local tokens = 0
	for _, machine in ipairs(machines) do
		tokens = tokens + solve_machine(machine, offset)
	end

	return tokens
end

function M.tests()
	local input = util.lines_from("./day13/test.txt")
	util.run_test(M.part1, input, 480)
	util.run_test(M.part2, input, 875318608908)
end

return M
