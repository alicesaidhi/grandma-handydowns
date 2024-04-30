local vide = require(script.Parent.Parent.vide)
local videx = require(script.Parent.libraries.videx)

local source = vide.source

local settings = videx.new(source {
	text_size = 16,
	font = Enum.Font.Code
}, source {
	
})

return settings