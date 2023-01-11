local data_util = require("shared-util")

data_util.sprite = function(name)
	return '__ch-concentrated-solar__/graphics/' .. name
end

data_util.auto_hr = function(inputs)
	inputs.hr_version = table.deepcopy(inputs)
	inputs.hr_version.scale = 0.5
	inputs.hr_version.width = inputs.hr_version.width * 2
	inputs.hr_version.height = inputs.hr_version.height * 2
	inputs.hr_version.filename = data_util.sprite(inputs.filename .. "-hr.png")
	inputs.filename = data_util.sprite(inputs.filename .. ".png")
	return inputs
end

return data_util
