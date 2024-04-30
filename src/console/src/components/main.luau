--!strict

local vide = require(script.Parent.Parent.Parent.vide)
local videkit = require(script.Parent.Parent.Parent.videkit)
local ansi = require(script.Parent.Parent.libraries.ansi)
local stream = require(script.Parent.Parent.libraries.stream)
local settings = require(script.Parent.Parent.settings)
local state = require(script.Parent.Parent.state)

local changed = vide.changed
local untrack = vide.untrack
local source = vide.source
local effect = vide.effect

return function()

	local canvas_position = source(Vector2.zero)
	local absolute_size = source(Vector2.zero)
	local canvas_size = source(Vector2.zero)
	
	local function at_bottom()
		local canvas_size = canvas_size()
		local canvas_pos = canvas_position()
		local size = absolute_size()

		local min = canvas_size.Y - size.Y - 16
		return canvas_pos.Y > min
	end

	task.delay(0, function()
		canvas_position(Vector2.new(0, canvas_size().Y))
	end)

	effect(function()
		local pos = untrack(canvas_position)
		state.stream() -- to track
		if not untrack(at_bottom) then return end
		task.defer(canvas_position, Vector2.new(pos.X, canvas_size().Y))
		state.added = 0
	end)

	return videkit.background {

		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BackgroundTransparency = 0,

		videkit.padding {
			padding = UDim.new(0, 4)
		},

		videkit.button {
			layout = {
				Size = UDim2.fromOffset(0, 26),
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.X
			},
			
			text = "Clear",

			activated = function()
				stream.clear()
				state.stream("")
			end
		},

		videkit.scroll_frame {

			CanvasPosition = canvas_position,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
	
			HorizontalScrollBarInset = Enum.ScrollBarInset.None,
			VerticalScrollBarInset = Enum.ScrollBarInset.None,
	
			changed("CanvasPosition", canvas_position),
			changed("AbsoluteSize", absolute_size),
			changed("AbsoluteCanvasSize", canvas_size),

			videkit.text {
	
				Size = UDim2.fromScale(1, 1),
				
				TextWrapped = true,
				RichText = true,
	
				TextColor3 = Color3.fromHex(ansi.colors.black),
	
				Text = state.stream,
				TextSize = function() return settings.text_size end,
				Font = function() return settings.font end,
	
				TextYAlignment = Enum.TextYAlignment.Top,
	
			}
	
		}

	}

end