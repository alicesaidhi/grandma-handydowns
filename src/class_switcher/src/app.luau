local CoreGui = game:GetService("CoreGui")

local vide = require(script.Parent.Parent.vide)
local app = require(script.Parent.components.app)
local quick = require(script.Parent.components.quick)
local radium = require(script.Parent.libraries.radium)

local source = vide.source
local effect = vide.effect
local cleanup = vide.cleanup
local mount = vide.mount

return function(plugin: Plugin)

	local toolbar: PluginToolbar = plugin:CreateToolbar("Class Switcher")
	local button1: PluginToolbarButton = toolbar:CreateButton(
		"Class Switcher",
		"Opens the UI to switch classes",
		""
	)

	local dock_widget_plugin_info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		200,
		200,
		200,
		200
	)
	local dock_widget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("ClassSwitcher", dock_widget_plugin_info)

	local action: PluginAction = plugin:CreatePluginAction("QuickSwitch", "Class Switch", "Switch Class", "", true)
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

	local activated = source(dock_widget.Enabled)

	dock_widget.Name = "ClassSwitcher"
	dock_widget.Title = "Class Switcher"

	radium.download()

	local unmount

	vide.strict = false

	effect(function()
		button1:SetActive(activated())
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

	dock_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		activated(dock_widget.Enabled)
	end)

	button1.Click:Connect(function()
		activated(not activated())
	end)

end