local types = require(script.Parent.types)

return function(self, runningTask): boolean
	if not runningTask then
		return false
	end

	local dependency = runningTask._dependency
	if not dependency then
		return true
	end

	local dependencyNumber = #dependency
	local passedTest = 0

	for id, task: types.taskData in self._tasks do
		if id == runningTask._id then
			continue
		end

		if task._completed then
			passedTest += 1
		end
	end

	return passedTest >= dependencyNumber
end
