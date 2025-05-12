local types = require(script.Parent.types)

return function(self, taskId): boolean
	local mainTask = self._tasks[taskId] :: types.taskData?
	if not mainTask then
		return false
	end

	local dependency = mainTask._dependency
	if not dependency then
		return false
	end

	if typeof(dependency) == "string" then
		return self._tasks[dependency]._completed
	elseif typeof(dependency) == "table" then
		local dependencyNumber = #dependency
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
