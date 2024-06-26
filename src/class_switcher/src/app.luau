local CoreGui = game:GetService("CoreGui")

local shared_toolbar = require(script.Parent.Parent.shared_toolbar)
local vide = require(script.Parent.Parent.vide)
local app = require(script.Parent.components.app)
local quick = require(script.Parent.components.quick)
local radium = require(script.Parent.libraries.radium)

local source = vide.source
local effect = vide.effect
local cleanup = vide.cleanup
local mount = vide.mount

return function(plugin: Plugin)

	vide.strict = false

	local action: PluginAction = plugin:CreatePluginAction(
		"QuickSwitch",
		"Quick Class Switch",
		"Creates a widget within the Viewport that allows you to quickly switch classes.",
		"rbxassetid://17115243150",
		true
	)
	local screen_gui = Instance.new("ScreenGui")
	screen_gui.Name = "ClassSwitch"
	screen_gui.Parent = CoreGui

	local destroy
	action.Triggered:Connect(function()
		if destroy then destroy() end
		destroy = vide.mount(function()
			local quick = quick(function()
				destroy()
				destroy = nil
			end)
			cleanup(quick)
			return quick
		end, screen_gui)
	end)

	radium.download()
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

	dock_widget.Name = "ClassSwitcher"
	dock_widget.Title = "Class Switcher"

	dock_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		activated(dock_widget.Enabled)
	end)

	dock_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		activated(dock_widget.Enabled)
	end)

	local shared_toolbar_settings = {
		CombinerName = "alice_plugins_1160098333",
		ToolbarName = "grandma's handy downs",
		
		ButtonName = "Class Switcher",
		ButtonIcon = "rbxassetid://17248497810",
		ButtonTooltip = "Opens the Dock Widget that allows you to switch classes",
		ClickedFn = function()
			activated(not activated())
		end
	} :: shared_toolbar.SharedToolbarSettings

	shared_toolbar(plugin, shared_toolbar_settings)

	local unmount

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