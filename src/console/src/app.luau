local LogService = game:GetService("LogService")

local shared_toolbar = require(script.Parent.Parent.shared_toolbar)
local vide = require(script.Parent.Parent.vide)
local app = require(script.Parent.components.main)
local ansi = require(script.Parent.libraries.ansi)
local stream = require(script.Parent.libraries.stream)
local state = require(script.Parent.state)

local source = vide.source
local effect = vide.effect
local cleanup = vide.cleanup
local mount = vide.mount

return function(plugin: Plugin)

	vide.strict = false

	local is_deferred = false
	local function defer()
		if is_deferred then return end
		is_deferred = true

		task.defer(function()
			state.stream(stream.get_string())
			is_deferred = false
		end)
	end

	LogService.MessageOut:Connect(function(input, message)
		local line = ansi.convert(input).."\n"
		stream.push_string(line)
		defer()
	end)

	pcall(function()
		
		for i, log in LogService:GetLogHistory() do
			local line = ansi.convert(log.message).."\n"
			stream.push_string(line)
		end

		defer()
		
	end)

	stream.push_string("[grandma/console] started plugin\n")

	
	local dock_widget_plugin_info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		200,
		200,
		200,
		200
	)
	local dock_widget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("Output", dock_widget_plugin_info)

	local activated = source(dock_widget.Enabled)

	dock_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		activated(dock_widget.Enabled)
	end)

	local shared_toolbar_settings = {
		CombinerName = "alice_plugins_1160098333",
		ToolbarName = "grandma's handy downs",
		
		ButtonName = "Output",
		ButtonIcon = "rbxassetid://17247723678",
		ButtonTooltip = "Opens an output widget that supports ANSI color codes",
		ClickedFn = function()
			activated(not activated())
		end
	} :: shared_toolbar.SharedToolbarSettings

	shared_toolbar(plugin, shared_toolbar_settings)

	dock_widget.Name = "Output"
	dock_widget.Title = "Output"

	local unmount

	vide.strict = false

	effect(function()
		shared_toolbar_settings.Button:SetActive(activated())
		dock_widget.Enabled = activated()

		if unmount then
			unmount()
			unmount = nil
		end

		if activated() then
			unmount = mount(function()
				local app = app()
				cleanup(app)
				return app
			end, dock_widget)
		end
	end)

end