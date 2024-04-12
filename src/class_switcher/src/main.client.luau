local vide = require(script.Parent.Parent.vide)
local app = require(script.Parent.app)

local mount = vide.mount

mount(function()
	app(plugin)
end)