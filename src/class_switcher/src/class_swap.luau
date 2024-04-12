local radium = require(script.Parent.libraries.radium)
return function(from: Instance, to: string)
	local inherited_members = radium.findAllInheritedMembers(from.ClassName)
	
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

	for _, child in from:GetChildren() do
		local child_class = radium.findAllInheritedMembers(child.ClassName)
		if not child_class then continue end

		child.Parent = new
		for name, member in child_class do
			if member.MemberType ~= "Property" then continue end
			if
				member.Security == "LocalUserSecurity"
				or member.Security == "RobloxScriptSecurity"
				or member.Security == "RobloxSecurity"
				or member.Security == "NotAccessibleSecurity"
			then continue end
			if member.Tags and table.find(member.Tags, "ReadOnly") then continue end
			
			pcall(function()
				if child[name] ~= from then return end
				child[name] = new
			end)
		end
	end

	new.Parent = from.Parent
	from.Parent = nil

	return new

end