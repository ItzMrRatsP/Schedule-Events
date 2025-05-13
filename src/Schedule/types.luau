export type task = () -> any
export type taskData = {
	_completed: boolean,
	_id: string,
	_dependency: { string },
	_signal: any,

	run: task,
}

export type Schedule = {
	_queue: { taskData },
	_tasks: { [string]: taskData },

	addTask: (self: Schedule, task: task, runAfterTasks: { string } | string) -> string?,
	cancelTask: (self: Schedule, taskId: string) -> boolean,
	boot: (self: Schedule) -> boolean, -- Completed or not
}

return {}
