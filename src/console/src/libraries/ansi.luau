--!native

local colors = {
	black = "#919191",
	red = "#cd3131",
	green = "#0dbc79",
	yellow = "#e5e510",
	blue = "#2472c8",
	magenta = "#bc3fbc",
	cyan = "#11a8cd",
	white = "#e5e5e5",
	
	bright_black = "#666666",
	bright_red = "#f14c4c",
	bright_green = "#23d18b",
	bright_yellow = "#f5f543",
	bright_blue = "#3b8eea",
	bright_magenta = "#d670d6",
	bright_cyan = "#29b8db",
	bright_white = "#e5e5e5"
}

local tags

local function update_tags()
	tags = {

		[1] = {
			close = "</b>",
			tag = "<b>"
		},
	
		[3] = {
			close = "</i>",
			tag = "<i>"
		},
	
		[4] = {
			close = "</u>",
			tag = "<u>"
		},
	
		[9] = {
			close = "</s>",
			tag = "<s>",
		},
	
		[30] = {
			close = "</font>",
			tag = `<font color="{colors.black}">`
		},
	
		[31] = {
			close = "</font>",
			tag = `<font color="{colors.red}">`
		},
	
		[32] = {
			close = "</font>",
			tag = `<font color="{colors.green}">`
		},
	
		[33] = {
			close = "</font>",
			tag = `<font color="{colors.yellow}">`
		},
	
		[34] = {
			close = "</font>",
			tag = `<font color="{colors.blue}">`
		},
	
		[35] = {
			close = "</font>",
			tag = `<font color="{colors.magenta}">`
		},
	
		[36] = {
			close = "</font>",
			tag = `<font color="{colors.cyan}">`
		},
	
		[37] = {
			close = "</font>",
			tag = `<font color="{colors.white}">`
		},
	
		[90] = {
			close = "</font>",
			tag = `<font color="{colors.bright_black}">`
		},
	
		[91] = {
			close = "</font>",
			tag = `<font color="{colors.bright_red}">`
		},
	
		[92] = {
			close = "</font>",
			tag = `<font color="{colors.bright_green}">`
		},
	
		[93] = {
			close = "</font>",
			tag = `<font color="{colors.bright_yellow}">`
		},
	
		[94] = {
			close = "</font>",
			tag = `<font color="{colors.bright_blue}">`
		},
	
		[95] = {
			close = "</font>",
			tag = `<font color="{colors.bright_magenta}">`
		},
	
		[96] = {
			close = "</font>",
			tag = `<font color="{colors.bright_cyan}">`
		},
	
		[97] = {
			close = "</font>",
			tag = `<font color="{colors.bright_white}">`
		},	
	
	}
end

update_tags()

local function convert(input: string)

	local not_closed = {}
	input = string.gsub(input, "\27%[(.-)m", function(input)
		local splitted = string.split(input, ";")
		local concat = {}
		
		for i, value in splitted do
			local n = tonumber(value)
			if n == 0 then
				table.move(not_closed, 1, #not_closed, #concat + 1, concat)
				table.clear(not_closed)
			else
				local tag = tags[n]

				table.insert(not_closed, 1, tag.close)
				table.insert(concat, tag.tag)
			end
		end

		return table.concat(concat)
	end)

	table.insert(not_closed, 1, input)

	return table.concat(not_closed, "")

end

return {

	convert = convert,
	update_tags = update_tags,

	tags = tags,
	colors = colors

}