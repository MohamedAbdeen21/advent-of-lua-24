local util = require("util")

local M = {}

-- Yes, we don't need this. We can just do a dfs
-- where zXX gates call their inputs dfs-style
-- but I'm doing AOC to practice language features
-- and I haven't used classes yet, so ...

---@class Module
---@field type string -- "AND", "OR", "XOR", "ROOT"
---@Field name string
---@field inputs boolean[]
---@field outputs Module[]
---@field eval fun(self: Module, part1: boolean): boolean | nil
---@Field send_signal fun(self: Module, signal: boolean)
---@Field register_output fun(self: Module, output: Module)
local module = {
	type = "",
	name = "",
	inputs = {},
	outputs = {},
}

local new = function(type, name)
	type = type or "ROOT"
	local mod = {}
	setmetatable(mod, { __index = module })
	mod.type = type
	mod.name = name
	mod.inputs = {}
	mod.outputs = {}
	return mod
end

function module:send_signal(signal)
	table.insert(self.inputs, signal)
end

function module:register_output(output)
	table.insert(self.outputs, output)
end

--- evaluate the inputs and propagate the result to outputs, return the result as well
--- returns nil if the node still needs more inputs
function module:eval(p1)
	if self.type == "ROOT" then
		assert(#self.inputs == 1, "ROOT module didn't receive an input")
		for _, output in ipairs(self.outputs) do
			output:send_signal(self.inputs[1])
			output:eval(p1)
		end
	end

	if #self.inputs ~= 2 then
		-- not ready to execute yet, has to wait for the second input
		return nil
	end

	local value = nil

	local a, b = self.inputs[1], self.inputs[2]

	if self.type == "AND" then
		-- Part 2, check a picture of a "full adder"
		-- all AND gates output ONLY to ORs (EXCEPT FOR THE FIRST BIT)
		-- run this only for p1, as p2 below loops over some inputs
		for _, output in ipairs(self.outputs) do
			if p1 and output.type ~= "OR" then
				print("Exepcted AND " .. self.name .. " output to be ORs only, got " .. output.type)
			end
		end
		value = a and b
	end

	if self.type == "OR" then
		-- same thing here, ORs only output to ANDs and ORs
		-- no exceptions to this one though
		for _, output in ipairs(self.outputs) do
			if p1 and output.type == "OR" then
				print("Exepcted OR " .. self.name .. " output to be XORs or ANDs only, got " .. output.type)
			end
		end
		value = a or b
	end

	if self.type == "XOR" then
		for _, output in ipairs(self.outputs) do
			if p1 and output.type == "OR" then
				print("Exepcted OR " .. self.name .. " output to be XORs or ANDs only, got " .. output.type)
			end
		end
		value = not (a == b)
	end

	assert(value ~= nil, "Evaluation failed for " .. self.type)

	for _, output in ipairs(self.outputs) do
		output:send_signal(value)
		output:eval(p1)
	end

	return value
end

local function parse(lines)
	---@type table<string, Module>
	local roots = {}
	---@type table<string, Module>
	local modules = {}

	local sections = util.section_input(lines)
	local inputs = sections[1]
	local system = sections[2]

	for _, line in ipairs(system) do
		local l, op, r, output = line:match("^(%w+)%s+(%u+)%s+(%w+)%s*->%s*(%w+)$")

		local out = {}
		if modules[output] then
			out = modules[output]
			out.type = op
		else
			out = new(op, output)
			modules[output] = out
		end

		if not modules[l] then
			modules[l] = new(nil, l)
		end

		modules[l]:register_output(out)

		if not modules[r] then
			modules[r] = new(nil, r)
		end

		modules[r]:register_output(out)
	end

	-- prime the inputs/roots
	for _, line in ipairs(inputs) do
		local node, value = line:match("(.*): (%d+)")
		roots[node] = modules[node]
		if value == "1" then
			modules[node]:send_signal(true)
		else
			modules[node]:send_signal(false)
		end
	end

	return modules, roots
end

function M.part1(lines, p1)
	lines = lines or util.lines_from("./day24/input.txt")
	-- controls print
	if p1 == nil then
		p1 = true
	end

	local modules, roots = parse(lines)

	for _, root in pairs(roots) do
		root:eval(p1)
	end

	local outputs = {}
	for name, _ in pairs(modules) do
		if name:sub(1, 1) == "z" then
			table.insert(outputs, name)
		end
	end

	table.sort(outputs)
	local sum = 0
	for i, output in ipairs(outputs) do
		if modules[output]:eval(p1) then
			sum = sum | (1 << (i - 1))
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day24/input.txt")

	-- This is a manual inspection part, it's not a general solution.
	-- We rely on hints, the first hint is the print
	-- inside the evaluation of ANDs and ORs (check comment above)
	-- and then try some inputs and manually inspect their respective circuits
	-- the problem is usually the value itself or the carry generated
	-- once you find the problem wires, swap them and re-run
	-- a pen and a paper also helps in tracking the names of the gates

	for i = 0, 44 do
		local modules, roots = parse(lines)
		local bit = ""
		if i < 10 then
			bit = "0" .. i
		else
			bit = string.format("%d", i)
		end

		for name, root in pairs(roots) do
			if name == "x" .. bit or name == "y" .. bit then
				root.inputs[1] = true
			else
				root.inputs[1] = false
			end
		end

		for _, root in pairs(roots) do
			root:eval(false)
		end

		local outputs = {}
		for name, _ in pairs(modules) do
			if name:sub(1, 1) == "z" then
				table.insert(outputs, name)
			end
		end

		table.sort(outputs)
		local sum = 0
		for j, output in ipairs(outputs) do
			if modules[output]:eval(false) then
				sum = sum | (1 << (j - 1))
			end
		end

		if sum ~= (1 << (i + 1)) then
			print("bit", bit, "got", sum, "expected", 1 << (i + 1))
		end
	end

	return 0
end

function M.tests()
	local input = util.lines_from("./day24/test.txt")
	util.run_test_args(2024, M.part1, input, false)
	-- util.run_test(M.part2, input, 0)
end

return M
