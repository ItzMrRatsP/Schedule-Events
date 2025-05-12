return function<T>(dict: { [any]: any }): { [number]: T }
	local cache = {}
	for _, v in dict do
		table.insert(cache, v)
	end
	return cache
end
