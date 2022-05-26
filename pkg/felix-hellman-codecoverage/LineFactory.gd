extends Node

class_name LineFactory, "res://pkg/felix-hellman-codecoverage/LineFactory.gd"

var regex = RegEx.new()
var func_regex = RegEx.new()

var types = ["func", "if", "else", "yield", "return", "match", "for", "while", "empty"]

func _ready():
	regex.compile("^(?<indent>\t*)((?<type>(if|else|match|func|for|while)).*:)*.*$")
	func_regex.compile("^func (?<functionName>.*)\\(.*$")

func as_line(l : String, index : int) -> SourceLine:
	var result = regex.search(l)
	if result:
		var indent = len(result.get_string("indent"))
		var line = l
		if "class_name" in line:
			line = ""
		var type = result.get_string("type")
		var to_return : SourceLine = SourceLine.new()
		to_return.line = line
		to_return.line_type = evaluate_line_type(line, type)
		to_return.indent = indent
		to_return.line_index = index
		return to_return
	return null

func evaluate_line_type(line, type) -> String:
	var index = types.find(type)
	if index > -1:
		return types[index]
	
	if len(line) > 0 and ":" in line[len(line) - 1]:
		return "match-pattern"
	if "\tyield" in line:
		return "yield"
	if line.replace("\t", "") == "":
		return "empty"
	return "other"
	
func extract_function_name(line : SourceLine) -> String:
	var result = func_regex.search(line.line)
	if result:
		return result.get_string("functionName")
	return ""
