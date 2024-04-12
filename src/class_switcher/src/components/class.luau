
local vide = require(script.Parent.Parent.Parent.vide)
local videkit = require(script.Parent.Parent.Parent.videkit)

local create = vide.create

type can<T> = T | () -> T
type class = {
	class_name: can<string>,
	selected: () -> boolean,
	activated: (class_name: string) -> ()
}

local function class(props: class)
	
	local class_name = props.class_name
	local activated = props.activated
	local selected = props.selected

	return videkit.button {

		text = function()
			return class_name() or ""
		end,

		child = {
			create "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				Padding = UDim.new(0, 6)
			},

			videkit.padding {
				x = UDim.new(0, 6),
				y = UDim.new()
			},

			videkit.class_icon {
				class = function()
					return class_name() or "Instance"
				end,
				layout = {LayoutOrder = -1}
			}
		},

		layout = {
			Size = UDim2.new(1, -12, 0, 20)
		},

		layout_text = {
			TextSize = 14,
		},

		activated = function()
			activated(class_name())
		end,

		_custom = "TableItem",
		_noborder = true,
		_nopadding = true,
		_selected = selected,

	}
	
end

return class