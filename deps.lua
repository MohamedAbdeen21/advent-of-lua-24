local dependencies = {
	{ "luafilesystem", "1.8.0-1" },
}

local function install_dependencies()
	for _, dep in ipairs(dependencies) do
		local name, version = dep[1], dep[2]
		local cmd = string.format("luarocks install %s %s", name, version)
		print("Installing:", name, version)
		os.execute(cmd)
	end
	print("All dependencies installed.")
end

install_dependencies()
