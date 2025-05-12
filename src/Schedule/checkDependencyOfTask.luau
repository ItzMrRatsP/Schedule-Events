local types = require(script.Parent.types)

return function(self, taskId): boolean
	local mainTask = self._tasks[taskId] :: types.taskData?
	if not mainTask then
		return false
	end

	if typeof(mainTask._dependency) == "string" then
		return self._tasks[mainTask._dependency]._completed
	elseif typeof(mainTask._dependency) == "table" then
		local dependencyNumber = #mainTask._dependency
		local passedTest = 0

		for id, task: types.taskData in self._tasks do
			if id == mainTask._id then
				continue
			end

			if task._completed then
				passedTest += 1
			end
		end

		return passedTest >= dependencyNumber
	end

	return false
end
