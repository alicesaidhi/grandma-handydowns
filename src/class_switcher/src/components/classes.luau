
local vide = require(script.Parent.Parent.Parent.vide)
local videkit = require(script.Parent.Parent.Parent.videkit)
local class = require(script.Parent.class)

local read = vide.read

type can<T> = T | () -> T
type classes = {
	classes: can<{string}>,
	selected: (class_name: string) -> boolean,
	activated: (class_name: string) -> (),

	layout: vide.vScrollingFrame?,
}

local function classes(props: classes)
	
	local classes = props.classes
	local activated = props.activated
	local selected = props.selected

	return videkit.infinite_list {
		item = function(index)
			local function class_name()
				return read(classes)[index()]
			end
			
			return class {
				class_name = class_name,
				selected = function()
					return selected(class_name())
				end,
				activated = activated
			}
		end,
		max_items = function()
			return #read(classes)
		end,
		item_size = 24,

		layout = props.layout
	}
	
end

return classes