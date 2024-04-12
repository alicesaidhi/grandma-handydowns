local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local vide = require(script.Parent.Parent.Parent.vide)
local videkit = require(script.Parent.Parent.Parent.videkit)
local class_swap = require(script.Parent.Parent.class_swap)
local filter = require(script.Parent.Parent.filter)
local classes = require(script.Parent.classes)

local source = vide.source
local effect = vide.effect
local cleanup = vide.cleanup

local function app()

	local selected_classname = source("") -- this is the one we selected in studio
	local search = source("")

	local selected = source("") -- this is the one we selected in the ui

	local available_classes = filter(search, selected_classname)

	effect(function()
		selected(available_classes()[1] or "")
	end)

	local function set_selected()
		local selection = Selection:Get()
		if #selection == 1 then
			selected_classname(selection[1].ClassName)
		else
			selected_classname("")
		end
	end

	cleanup(Selection.SelectionChanged:Connect(set_selected))
	set_selected()
	
	cleanup(UserInputService.InputBegan:Connect(function(input)
		print(input.KeyCode)
	end))

	local function swap_classes()
		local recording = ChangeHistoryService:TryBeginRecording("swap_class", "Begin Swap Classes")
		if not recording and RunService:IsRunning() == false then
			ChangeHistoryService:FinishRecording("", Enum.FinishRecordingOperation.Cancel)
			swap_classes()
			return
		end

		local ok, result = pcall(function()
			for _, object in Selection:Get() do
				Selection:Add({class_swap(object, selected())})
			end
		end)

		if not ok then
			warn(result)
		end

		if recording then
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end
	end

	local function process_input(keycode: Enum.KeyCode)

		if keycode == Enum.KeyCode.Return then swap_classes() end

		local index = table.find(available_classes(), selected())
		if not index then return end
		if keycode == Enum.KeyCode.Up then
			selected(available_classes()[index - 1] or selected())
		elseif keycode == Enum.KeyCode.Down then
			selected(available_classes()[index + 1] or selected())
		end
	end

	return videkit.background {

		InputBegan = function(input)
			process_input(input.KeyCode)
		end,

		videkit.padding {},

		classes {
			classes = available_classes,
	
			activated = selected,
			selected = function(class_name)
				return selected() == class_name
			end,

			layout = {
				Size = UDim2.new(1, 0, 1, -32)
			}
		},

		videkit.row {

			layout = {
				Size = UDim2.new(1, 0, 0, 24),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				AutomaticSize = Enum.AutomaticSize.None,
			},

			list = {VerticalAlignment = Enum.VerticalAlignment.Center},

			videkit.text_input {
				update_text = search,
				text = search,

				focus_lost = function(_, enter)
					if enter then
						swap_classes()
					end
				end,

				layout = {
					Size = UDim2.new(1, -68, 1, 0),
					InputBegan = function(input)
						process_input(input.KeyCode)
					end
				},
			},

			videkit.button {
				text = "Convert",

				activated = swap_classes,

				layout = {
					Size = UDim2.new(0, 60, 1, 0)
				}
			}

		}

	}

end

return app