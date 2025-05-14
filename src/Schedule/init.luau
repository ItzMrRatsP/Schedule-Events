local HttpService = game:GetService("HttpService")

--- @info These are all the dependency modules, We need these to even run the task scheduler
local checkDependencyOfTask = require(script.checkDependencyOfTask)
local types = require(script.types)
local dictToArray = require(script.dictToArray)

local Schedule = {}

Schedule._queue = {}
Schedule._tasks = {}

--[[
		Adds a task to the scheduling queue.

		@param scheduledTask function The task to be scheduled.
		@param ... string The tasks that this task depends on.
		@return string The id of the scheduled task, or nil if the task is invalid.

		Checks to make sure that the task is a function, and if so, adds it to the scheduling queue.
		Also sets the dependency of the task to the given tasks.
]]
function Schedule:addTask(scheduledTask, waitFor, ...)
	if typeof(scheduledTask) ~= "function" then
		warn("The task must be a function, Please try to provide a correct task to run.")
		return
	end

	local taskId = HttpService:GenerateGUID(false)

	self._tasks[taskId] = {
		_completed = false,
		_id = taskId,
		_dependency = { ... },
		_start = os.clock() + (waitFor or 0),

		run = scheduledTask,
	} :: types.taskData

	return taskId
end

--[[
	Runs all of the scheduled tasks. This should be called after you have finished scheduling all of the tasks.

	This function will go through each task in the scheduling queue, and for each task, it will check if all of it's dependencies have been completed. If they have, it will run the task in the thread. If they haven't, it will put the task back in the queue to be checked again later.

	Once all of the tasks have been completed, this function will return. This function will continue to run until all of the tasks have been completed.
]]
function Schedule:boot()
	self._queue = dictToArray(self._tasks)

	while #self._queue > 0 do
		local queuedTask = table.remove(self._queue, 1) :: types.taskData

		if not checkDependencyOfTask(self, queuedTask) then
			table.insert(self._queue, queuedTask)
			task.wait()

			continue
		end

		--- @Objective; Delay the task to run after the time
		task.wait(queuedTask._time - os.clock())
		queuedTask.run()
		queuedTask._completed = true
	end
end

return Schedule :: types.Schedule
