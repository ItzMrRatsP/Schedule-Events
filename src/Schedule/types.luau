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

	addTask: (task: task, runAfterTasks: { string } | string) -> string?,
	cancelTask: (taskId: string) -> boolean,
	boot: () -> boolean, -- Completed or not
}

return {}
