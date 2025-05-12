local HttpService = game:GetService("HttpService")

-- The main module for schedule
local checkDependencyOfTask = require(script.checkDependencyOfTask)
local types = require(script.types)
local dictToArray = require(script.dictToArray)

local Schedule = {}
Schedule.tasks = {} :: {
	[string]: types.taskData,
}

function Schedule.new()
	local self = {}

	-- methods
	self.addTask = Schedule.addTask
	self.cancelTask = Schedule.cancelTask
	self.boot = Schedule.boot

	-- private var
	self._tasks = {}
	self._queue = {}

	-- return
	return self
end

--- @TODO: Add tasks in the list, Check if tasks has any other task to run before it, If that is not finished then it won't run.
function Schedule:addTask(task, runAfterTasks)
	if typeof(task) == "function" then
		warn("The task must be a function, Please try to provide a correct task to run.")
		return
	end

	local taskId = HttpService:GenerateGUID(false)

	self._tasks[taskId] = {
		_completed = false,
		_id = taskId,
		_dependency = runAfterTasks,

		run = task,
	} :: types.taskData

	return taskId
end

local function createThread()
	local threadTasks = {}
	local thread = task.spawn(function()
		while true do
			if #threadTasks < 0 then
				task.wait()
				continue
			end

			local run = table.remove(threadTasks, 1)
			run()
		end
	end)

	return {
		thread = thread,
		cancel = function()
			task.cancel(thread)
		end,
		threadTasks = threadTasks,
	}
end

function Schedule:boot()
	local thread = createThread()
	self._queue = dictToArray(self._tasks)

	while #self._queue > 0 do
		local task: types.taskData = table.remove(self._queue, 1) :: types.taskData
		if checkDependencyOfTask(task._id) then
			--- @TODO: Check if all tasks are completed
			table.insert(self._queue, task)
			continue
		end

		--- @TODO: Check if task is completed, If it is then we can just pass by
		if task._completed then
			continue
		end

		--- @Objective; Run the task
		table.insert(thread.threadTasks, task.run)
	end

	thread.cancel()
end

function Schedule:cancelTask() end

return Schedule.new :: () -> types.Schedule
