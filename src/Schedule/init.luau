local HttpService = game:GetService("HttpService")

-- The main module for schedule
local Promise = require(script.Packages.Promise)
local checkDependencyOfTask = require(script.checkDependencyOfTask)
local types = require(script.types)
local dictToArray = require(script.dictToArray)

local Schedule = {}

function Schedule.new()
	local self = {}

	-- methods
	self.addTask = Schedule.addTask
	self.boot = Schedule.boot

	-- private var
	self._tasks = {}
	self._queue = {}

	-- return
	return self
end

--- @TODO: Add tasks in the list, Check if tasks has any other task to run before it, If that is not finished then it won't run.
function Schedule:addTask(scheduledTask, runAfterTasks)
	if typeof(scheduledTask) ~= "function" then
		warn("The task must be a function, Please try to provide a correct task to run.")
		return
	end

	local taskId = HttpService:GenerateGUID(false)

	self._tasks[taskId] = {
		_completed = false,
		_id = taskId,
		_dependency = runAfterTasks,

		run = scheduledTask,
	} :: types.taskData

	return taskId
end

function Schedule:boot()
	local promises = {}
	self._queue = dictToArray(self._tasks)

	while #self._queue > 0 do
		local queuedTask = table.remove(self._queue, 1) :: types.taskData

		if not checkDependencyOfTask(self, queuedTask) then
			--- @TODO: Check if all tasks are completed
			table.insert(self._queue, queuedTask)
			task.wait()
			continue
		end

		--- @Objective; Run the task in the thread
		table.insert(
			promises,
			Promise.try(function()
				return queuedTask.run
			end)
				:andThen(function(f)
					-- Task is completed, We can set it true
					if not f then
						return
					end

					queuedTask._completed = true
					f()
				end)
				:catch(warn)
		)
	end

	Promise.allSettled(promises):andThen(function()
		print("All scheduled events are running now!")
	end)
end

return Schedule.new() :: types.Schedule
