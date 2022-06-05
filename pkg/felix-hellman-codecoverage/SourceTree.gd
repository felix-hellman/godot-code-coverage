extends Node2D

class_name SourceTree, "res://pkg/felix-hellman-codecoverage/SourceTree.gd"

var factory : LineFactory = LineFactory.new()

func _ready():
	factory._ready()

func parse(source):
	var lines = parse_line_types(source)
	var r = find_root_blocks(lines)
	var methods = split_on_methods(r)
	var used_lines = []
	for block in methods:
		used_lines.append_array(list_used_lines(block))
	var method_blocks = []
	for block in methods:
		var first = new_block()
		first["function_name"] = block["function_name"]
		split_on_conditionals(first, block, 0)
		var second = new_block()
		second["function_name"] = first["function_name"]
		first.erase("function_name")
		append_child_to_block(second, first)
		split_on_non_conguitos(second)
		split_on_branches(second)
		second["function_line"] = block["function_line"]
		method_blocks.append(second)
		
	
	var unused_lines = []
	for line in lines:
		if not line in used_lines and not "func " in line.line:
			unused_lines.append(line)
	return {"methods":method_blocks, "file":"path", "unused_lines": unused_lines}
	
func list_used_lines(node):
	var lines = []
	for child in node["children"]:
		lines.append_array(list_used_lines(node["children"][child]))
	lines.append_array(node["lines"])
	return lines
		

func split_on_non_conguitos(parent):
	var to_delete = []
	var to_add = []
	for child in parent["children"]:
		var child_node = parent["children"][child]
		to_add = split_non_conguitos(child_node)
		if len(to_add) > 1:
			to_delete.append(child)	
	for block in to_add:
		append_child_to_block(parent, block)
	for delete in to_delete:
		parent["children"].erase(delete)
	
func split_non_conguitos(node):
	var segments = [0]
	for x in range(1, len(node["lines"])):
		var line = node["lines"][x]
		var previous = node["lines"][x-1]
		
		if line.line_index - 1 != previous.line_index:
			segments.append(x - 1)
			segments.append(x)
	segments.append(len(node["lines"]))
	var slices = []
	if len(segments) > 2:
		for x in range(1, len(segments), 2):
			var split = node["lines"].slice(segments[x-1], segments[x], 1, false)
			var block = new_block()
			block["lines"] = split
			var last_line = block["lines"].back().line_index
			for k in node["children"]:
				var child = node["children"][k]
				var child_line_index = child["lines"].front().line_index
				if child_line_index - 1 == last_line:
					append_child_to_block(block, child)
			slices.append(block)
	return slices
			
		

func split_on_methods(node):
	var methods = []
	for child in node:
		var line = node[child]["lines"].pop_front()
		var method_name = factory.extract_function_name(line)
		var b = new_block()
		b["lines"] = node[child]["lines"]
		b["function_name"] = method_name
		b["function_line"] = line.line.replace("static ", "")
		methods.append(b)
	return methods

func find_root_blocks(lines):
	var blocks = {}
	var current_block = new_block()
	for k in lines:
		var line : SourceLine = k
		if "func" in line.line_type:
			current_block = new_block()
			var index = len(blocks)
			blocks[index] = current_block
			current_block["lines"].append(line)
		if line.indent != 0 and not line.line_type in "empty":
			current_block["lines"].append(line)
			
	return blocks

func split_on_conditionals(parent, block, start):
	var indent = block["lines"][start].indent
	var index = start
	var conditional_types = ["if", "match", "for", "while"]
	while index < len(block["lines"]):
		var l = block["lines"][index]
		var line : SourceLine = l
		if line.line_type in conditional_types:
			var conditional_block = new_block()
			conditional_block["lines"].append(line)
			append_child_to_block(parent, conditional_block)
			var next_block = new_block()
			append_child_to_block(conditional_block, next_block)
			index = split_on_conditionals(next_block, block, index+1)
			index = index  - 1
		elif line.line_type in ["else", "elif", "match-pattern", "yield"]:
			parent["lines"].append(line)
		elif line.indent < indent:
			return index
		else:
			parent["lines"].append(line)
		index = index + 1
	return index

func split_on_branches(parent):
	
	for k in parent["children"]:
		var child = parent["children"][k]
		split_on_branches(child)

	for k in parent["children"]:
		var child = parent["children"][k]
		var split = split_block(child)
		if len(split) > 1:
			for s in split:
				append_child_to_block(parent, s)
			parent["children"].erase(k)
			
			
func split_block(block):
	var index = 0
	var blocks = []
	var current_block = new_block()
	blocks.append(current_block)
	if len(block["lines"]) > 0:
		for line in block["lines"]:
			if line.line_type in ["else", "yield", "elif", "match-pattern"]:
				current_block = new_block()
				blocks.append(current_block)
			current_block["lines"].append(line)
		return blocks.duplicate(true)
	return blocks
	
	
func append_child_to_block(parent, child):
	for x in range(0, 1000):
		if not parent["children"].has(x):
			var index = x
			parent["children"][index] = child
			break


func new_block():
	return {"lines":[],"children":{}}

func parse_line_types(source):
	var result = []
	var multi_line_types = ["func", "if", "elif"]
	var multi_lines : PoolStringArray = []
	var index = 1
	for line in source.split("\n"):
		var r = factory.as_line(line, index)
		if r != null:
			if r.line_type in multi_line_types and not r.has_end:
				multi_lines.append(line)
			if len(line) > 0 and line[0] != "#":
				if len(multi_lines) > 0:
					multi_lines.append(line)
					if r.has_end:
						result.append(factory.merge(multi_lines, index))
						multi_lines = []
				else:
					result.append(r)
		index = index + 1
	return result

func __print_file_tree(method_blocks, path):
	var text = path
	print(str(0) + "(\"" + text + "\")")
	var index = 1
	var arrows = []
	for method in method_blocks:
		arrows.append(str(0) +" --> " + str(index + 1))
		index = index + 1
		index = __print_blocks(method, index)
	for arrow in arrows:
		print(arrow)

func __print_blocks(block, index):
	var self_index = index
	var text = ""
	var arrows = []
	if "function_name" in block:
			text = text + block["function_name"]
	for line in block["lines"]:
		text = text +" "+ str(line.line_index)
	if text != "":
		print(str(index) + "(\"" + text + "\")")
	for child in block["children"]:
		arrows.append(str(self_index) +" --> " + str(index + 1))
		index = index + 1
		index = __print_blocks(block["children"][child], index)
	for arrow in arrows:
		print(arrow)
	return index
