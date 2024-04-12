local vide = require(script.Parent.Parent.vide)
local fzy = require(script.Parent.libraries.fzy)
local radium = require(script.Parent.libraries.radium)

local derive = vide.derive

radium.download()

local creatable_classes = {}

do
	for _, class_name in radium.listClassNames(true) do
		local class = radium.findClass(class_name)

		if class.Tags and (table.find(class.Tags, "NotCreatable") or table.find(class.Tags, "Service")) then continue end

		table.insert(creatable_classes, class_name)
	end
end

return function(search: () -> string, classname: () -> string)

	local initial_filter = derive(function()
		if classname() == "" or #search() > 0 then 
			return creatable_classes
		else
			debug.profilebegin("initial filter")
			local class = radium.findClass(classname())

			local list = {}
			local set = {}

			local function populate(class: string)
				for _, subclass in radium.findSubclasses(class) do
					if set[subclass.Name] then continue end
					set[subclass.Name] = true
					table.insert(list, subclass.Name)
				end
			end

			local ancestor = class
			while ancestor.Superclass ~= "Instance" do
				ancestor = radium.findClass(ancestor.Superclass)
				populate(ancestor.Name)
			end
	
			table.remove(list, table.find(list, classname()))

			debug.profileend()
			return list
		end
	end)

	local available_classes = derive(function()
		debug.profilebegin("post filter")
		local needle = string.lower(search())
		local haystack = {}

		for _, class_name in initial_filter() do
			local class = radium.findClass(class_name)

			if class.Tags and table.find(class.Tags, "NotCreatable") then continue end

			if string.match(string.lower(class_name), needle) then
				table.insert(haystack, class_name)
			end
		end

		local filter_result = fzy.filter(needle, haystack)

		table.sort(filter_result, function(a, b)
			return a.score > b.score
		end)

		local final = {}

		for i, result in filter_result do
			final[i] = haystack[result.idx]
		end

		debug.profileend()
		return final
	end)

	return available_classes

end