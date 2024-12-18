local util = require("util")

local M = {}
local int = math.tointeger

local pc = 0
local stdout = {}

local function get_combo_operand(operand, registers)
	if operand >= 0 and operand <= 3 then
		return operand
	elseif operand == 4 then
		return registers["A"]
	elseif operand == 5 then
		return registers["B"]
	elseif operand == 6 then
		return registers["C"]
	else
		assert(false, "invalid operand" .. operand)
	end
end

local function adv(operand, registers)
	operand = get_combo_operand(operand, registers)
	registers["A"] = registers["A"] // 2 ^ operand
	pc = pc + 2
end

local function bxl(operand, registers)
	registers["B"] = int(registers["B"] ~ operand)
	pc = pc + 2
end

local function bst(operand, registers)
	operand = get_combo_operand(operand, registers)
	registers["B"] = int(operand % 8)
	pc = pc + 2
end

local function jnz(operand, registers)
	if registers["A"] == 0 then
		pc = pc + 2
		return
	end

	pc = operand
end

local function bxc(_, registers)
	registers["B"] = int(registers["B"] ~ registers["C"])
	pc = pc + 2
end

local function out(operand, registers)
	operand = get_combo_operand(operand, registers) % 8
	table.insert(stdout, int(operand))
	pc = pc + 2
end

local function bdv(operand, registers)
	operand = get_combo_operand(operand, registers)
	registers["B"] = registers["A"] // 2 ^ operand
	pc = pc + 2
end

local function cdv(operand, registers)
	operand = get_combo_operand(operand, registers)
	registers["C"] = registers["A"] // (2 ^ operand)
	pc = pc + 2
end

local function map_function(opcode)
	if opcode == 0 then
		return adv
	elseif opcode == 1 then
		return bxl
	elseif opcode == 2 then
		return bst
	elseif opcode == 3 then
		return jnz
	elseif opcode == 4 then
		return bxc
	elseif opcode == 5 then
		return out
	elseif opcode == 6 then
		return bdv
	elseif opcode == 7 then
		return cdv
	end
end

local function parse(lines)
	local sections = util.section_input(lines)

	local regs, prog = sections[1], sections[2]

	local registers = {}
	local instructions = {}

	registers["A"] = regs[1]:match("(%d+)")
	registers["B"] = regs[2]:match("(%d+)")
	registers["C"] = regs[3]:match("(%d+)")

	for _, line in ipairs(prog) do
		for ins in line:gmatch("%d+") do
			instructions[#instructions + 1] = tonumber(ins)
		end
	end

	return registers, instructions
end

function M.part1(lines)
	lines = lines or util.lines_from("./day17/input.txt")
	local registers, instructions = parse(lines)

	while pc < #instructions do
		map_function(instructions[pc + 1])(instructions[pc + 2], registers)
	end

	return table.concat(stdout, ",")
end

local function backtrack(octals, i, registers, instructions)
	for v = 0, 7 do
		pc = 0
		stdout = {}

		octals[i] = v

		local octal = table.concat(octals, "")
		local value = tonumber(octal, 8)
		registers["A"] = value

		while pc < #instructions do
			map_function(instructions[pc + 1])(instructions[pc + 2], registers)
		end

		local output = stdout[#stdout + 1 - i]
		local program = instructions[#instructions + 1 - i]
		if output == program then
			-- base case
			if i == #octals then
				return value
			end

			-- recurse
			local ans = backtrack(octals, i + 1, registers, instructions)
			if ans > 0 then
				return ans
			end
		end
	end

	return -1
end

function M.part2(lines)
	lines = lines or util.lines_from("./day17/input.txt")
	local registers, instructions = parse(lines)

	local octals = {}

	for _ = 1, #instructions do
		octals[#octals + 1] = 0
	end

	return backtrack(octals, 1, registers, instructions)
end

function M.tests()
	local input = util.lines_from("./day17/test.txt")
	local input2 = util.lines_from("./day17/test2.txt")
	util.run_test(M.part1, input, "4,6,3,5,6,3,5,2,1,0")
	util.run_test(M.part2, input2, 117440)
end

return M
