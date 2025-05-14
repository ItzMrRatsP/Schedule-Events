export type task = () -> any
export type taskData = {
	_completed: boolean,
	_id: string,
	_dependency: { string },
	_start: number,

	run: task,
}

export type Schedule = {
	_queue: { taskData },
	_tasks: { [string]: taskData },

	addTask: (self: Schedule, scheduledTask: task, waitFor: number, ...string) -> string?,
	cancelTask: (self: Schedule, taskId: string) -> boolean,
	boot: (self: Schedule) -> boolean, -- Completed or not
}

return {}
