local radium = require(script.Parent.libraries.radium)

-- stores where objects would probably be stored
local locations_for_object_properties = {
	game:GetService("Workspace"),
	game:GetService("Lighting"),
	game:GetService("MaterialService"),
	game:GetService("ReplicatedFirst"),
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerScriptService"),
	game:GetService("ServerStorage"),
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("StarterPlayer"),
	game:GetService("SoundService"),
	game:GetService("Teams"),
	game:GetService("TextChatService")
}

local cache = {}
local function get_list_of_object_properties(class: string): {string} | false
	if cache[class] ~= nil then return cache[class] end
	local inherited_members = radium.findAllInheritedMembers(class)
	local object_properties = {}

	for name, member in inherited_members do
		if name == "Parent" then continue end
		if member.MemberType ~= "Property" then continue end
		if
			member.Security == "LocalUserSecurity"
			or member.Security == "RobloxScriptSecurity"
			or member.Security == "RobloxSecurity"
			or member.Security == "NotAccessibleSecurity"
		then continue end
		if member.Tags and table.find(member.Tags, "ReadOnly") then continue end
		if member.ValueType.Category ~= "Class" then continue end

		table.insert(object_properties, name)
	end

	if #object_properties == 0 then
		cache[class] = false
		return false
	end
	cache[class] = object_properties
	return object_properties
end

return function(from: Instance, to: string)
	local inherited_members = radium.findAllInheritedMembers(from.ClassName)
	
	debug.profilebegin("reclassing")
	local from_properties = {}
	for name, member in inherited_members do
		if member.MemberType ~= "Property" then continue end
		if
			member.Security == "LocalUserSecurity"
			or member.Security == "RobloxScriptSecurity"
			or member.Security == "RobloxSecurity"
			or member.Security == "NotAccessibleSecurity"
		then continue end
		if member.Tags and table.find(member.Tags, "ReadOnly") then continue end

		table.insert(from_properties, member)
	end

	local ok, new = pcall(Instance.new, to)
	if ok == false then
		error(`Cannot create class "{to}"`, 2)
	end

	for _, tag in from:GetTags() do
		new:AddTag(tag)
	end

	for key, value in from:GetAttributes() do
		new:SetAttribute(key, value)
	end

	local function set_property(from: Instance, to: Instance, property: string)
		from[property] = to[property]
	end

	for _, property in from_properties do
		if property == "Parent" then continue end
		pcall(set_property, new, from, property.Name)
	end

	debug.profilebegin("change object properties")
	for _, service in locations_for_object_properties do
		for _, descendant in service:GetDescendants() do
			local properties = get_list_of_object_properties(descendant.ClassName)
			if properties == false then continue end
			for _, property in properties do
				pcall(function()
					if descendant[property] == from then
						descendant[property] = new
					end
				end)
			end
		end
	end
	debug.profileend()

	for _, child in from:GetChildren() do
		local child_class = radium.findAllInheritedMembers(child.ClassName)
		if not child_class then continue end

		child.Parent = new
	end

	new.Parent = from.Parent
	from.Parent = nil
	debug.profileend()

	return new

end