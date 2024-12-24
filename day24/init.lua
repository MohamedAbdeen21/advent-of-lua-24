local util = require("util")

local M = {}

-- Yes, we don't need this. We can just do a dfs
-- where zXX gates call their inputs dfs-style
-- but I'm doing AOC to practice language features
-- and I haven't used classes yet, so ...

---@class Module
---@field type string -- "AND", "OR", "XOR", "ROOT"
---@field inputs boolean[]
---@field outputs Module[]
---@field eval fun(self: Module): boolean | nil
---@Field send_signal fun(self: Module, signal: boolean)
---@Field register_output fun(self: Module, output: Module)
local module = {
	type = "",
	inputs = {},
	outputs = {},
}

local new = function(type)
	type = type or "ROOT"
	local mod = {}
	setmetatable(mod, { __index = module })
	mod.type = type
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
function module:eval()
	if self.type == "ROOT" then
		assert(#self.inputs == 1, "ROOT module didn't receive an input")
		for _, output in ipairs(self.outputs) do
			output:send_signal(self.inputs[1])
			output:eval()
		end
	end

	if #self.inputs ~= 2 then
		-- not ready to execute yet, has to wait for the second input
		return nil
	end

	local value = nil

	local a, b = self.inputs[1], self.inputs[2]

	if self.type == "AND" then
		value = a and b
	end

	if self.type == "OR" then
		value = a or b
	end

	if self.type == "XOR" then
		value = not (a == b)
	end

	assert(value ~= nil, "Evaluation failed for " .. self.type)

	for _, output in ipairs(self.outputs) do
		output:send_signal(value)
		output:eval()
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
			out = new(op)
			modules[output] = out
		end

		if not modules[l] then
			modules[l] = new()
		end

		modules[l]:register_output(out)

		if not modules[r] then
			modules[r] = new()
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

function M.part1(lines)
	lines = lines or util.lines_from("./day24/input.txt")
	local modules, roots = parse(lines)

	for _, root in pairs(roots) do
		root:eval()
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
		if modules[output]:eval() then
			sum = sum | (1 << (i - 1))
		end
	end

	return sum
end

function M.part2(lines)
	lines = lines or util.lines_from("./day24/input.txt")
	for _, line in ipairs(lines) do
		print(line)
	end
	return 0
end

function M.tests()
	local input = util.lines_from("./day24/test.txt")
	util.run_test(M.part1, input, 2024)
	util.run_test(M.part2, input, 0)
end

return M
