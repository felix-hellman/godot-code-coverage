extends Node

var code_blocks = []

var index  = 0
var file_name = ""
var visited = {}
var lines = []

var files = {}

func register(file_information, file_name):
	self.file_name = file_name
	for line in file_information["unused_lines"]:
		lines.append(line.line)

	lines.append("signal register_visited")
	for method in file_information["methods"]:
		register_method(method)
	file_name = file_information["file"]
	code_blocks.sort_custom(self, "sort_blocks")
	for block in code_blocks:
		block_into_lines(block)

func sort_blocks(a, b):
	return a["id"] < b["id"]

func get_source():
	var text = ""
	for line in lines:
		text = text + line + "\n"
	return text

func block_into_lines(block):
	if "function_line" in block:
			lines.append(block["function_line"])
	if len(block["node"]["lines"]) > 0:
		var front = block["node"]["lines"].front()
		match front.line_type:
			"match-pattern":
				lines.append(front.line)
				var visited_line = ""
				for x in front.indent + 1:
					visited_line = visited_line + "\t"
				visited_line = visited_line + "emit_signal(\"register_visited\","+str(block["id"]) + ")"
				lines.append(visited_line)
			"else":
				lines.append(front.line)
				var visited_line = ""
				for x in front.indent + 1:
					visited_line = visited_line + "\t"
				visited_line = visited_line + "emit_signal(\"register_visited\","+str(block["id"]) + ")"
				lines.append(visited_line)
			"yield":
				lines.append(front.line)
				var visited_line = ""
				for x in front.indent:
					visited_line = visited_line + "\t"
				visited_line = visited_line + "emit_signal(\"register_visited\","+str(block["id"]) + ")"
				lines.append(visited_line)
			"elif":
				lines.append(front.line)
				var visited_line = ""
				for x in front.indent + 1:
					visited_line = visited_line + "\t"
				visited_line = visited_line + "emit_signal(\"register_visited\","+str(block["id"]) + ")"
				lines.append(visited_line)
			"match":
				lines.append(front.line)
			"if":
				lines.append(front.line)
			"for":
				lines.append(front.line)
				var visited_line = ""
				for x in front.indent + 1:
					visited_line = visited_line + "\t"
				visited_line = visited_line + "emit_signal(\"register_visited\","+str(block["id"]) + ")"
				lines.append(visited_line)
			"while":
				lines.append(front.line)
			_:
				var visited_line = ""
				for x in front.indent:
					visited_line = visited_line + "\t"
				visited_line = visited_line + "emit_signal(\"register_visited\","+str(block["id"]) + ")"
				lines.append(visited_line)
				lines.append(front.line)
				
		
		for x in range(1, len(block["node"]["lines"])):
			lines.append(block["node"]["lines"][x].line)

func register_method(method):
	var block = {"node": method, "id":_get_and_increment_count(), "range":null, "function_line": method["function_line"], "function_name": method["function_name"]}
	code_blocks.append(block)
	for child in method["children"]:
		register_blocks(method["children"][child])

func register_blocks(node):
	var start = 0
	var end = 0
	if len(node["lines"]) <= 0:
		start = -1
		end = -1
	else:
		start = node["lines"].front().line_index
		end = node["lines"].front().line_index
		for line in node["lines"]:
			if not "empty" == line.line_type:
				end = line.line_index
	var id = _get_and_increment_count()
	var children_ids = []
	for child in node["children"]:
		children_ids.append(register_blocks(node["children"][child]))
	var block = {"range": [start,end+1], "requires": _evaluate_requirement(node, id, children_ids), "node": node, "id":id}
	code_blocks.append(block)
	visited[id] = false
	return id
	

func report_to_dict():
	var output = {}
	var current_function = ""
	
	for block in code_blocks:
		if block["range"] == null:
			current_function = block["function_name"]
			output[current_function] = {}
		else:
			var upper = 0
			var under = len(block["requires"])
			for r in block["requires"]:
				if visited[r]:
					upper = upper + 1
			if block["range"][0] == block["range"][1]:
				var x = block["range"][0]
				output[current_function][x] = str(upper) + "/" + str(under)
			else:
				for x in range(block["range"][0], block["range"][1]):
					output[current_function][x] = str(upper) + "/" + str(under)
	return output
	

func register_visited(index):
	visited[index] = true

func _get_and_increment_count():
	var tmp = index
	index = index + 1
	return tmp

func _evaluate_requirement(node, id ,children_ids):
	if len(node["lines"]) <= 0:
		return []
	match node["lines"].front().line_type:
		"if":
			return children_ids
		"match":
			return children_ids
		_:
			return [id]
