local util = require("util")

local M = {}

local pc = 0
local stdout = {}

local function get_combo_operand(operand, registers)
	if operand >= 0 and operand <= 3 then
		return operand
	elseif operand == 4 then
		return registers["A"]
	elseif operand == 5 then
		print(registers["B"])
		return registers["B"]
	elseif operand == 6 then
		return registers["C"]
	else
		assert(false, "invalid operand" .. operand)
	end
end

local function adv(operand, registers)
	operand = get_combo_operand(operand)
	registers["A"] = registers["A"] // 2 ^ operand
	pc = pc + 2
end

local function bxl(operand, registers)
	registers["B"] = registers["B"] ~ operand
	pc = pc + 2
end

local function bst(operand, registers)
	operand = get_combo_operand(operand, registers)
	registers["B"] = operand % 8
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
	registers["B"] = registers["B"] ~ registers["C"]
	pc = pc + 2
end

local function out(operand, registers)
	operand = get_combo_operand(operand, registers) % 8
	table.insert(stdout, math.tointeger(operand))
	pc = pc + 2
end

local function bdv(operand, registers)
	operand = get_combo_operand(operand)
	registers["B"] = registers["A"] // 2 ^ operand
	pc = pc + 2
end

local function cdv(operand, registers)
	operand = get_combo_operand(operand)
	registers["C"] = registers["A"] // 2 ^ operand
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

	-- for k, v in pairs(registers) do
	-- 	print(k, v)
	-- end
	-- print(table.concat(instructions, ", "))

	while pc < #instructions do
		map_function(instructions[pc + 1])(instructions[pc + 2], registers)
	end

	return table.concat(stdout, ",")
end

function M.part2(lines)
	lines = lines or util.lines_from("./day17/input.txt")
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.tests()
	local input = util.lines_from("./day17/test.txt")
	util.run_test(M.part1, input, "4,6,3,5,6,3,5,2,1,0")
	util.run_test(M.part2, input, 0)
end

return M
