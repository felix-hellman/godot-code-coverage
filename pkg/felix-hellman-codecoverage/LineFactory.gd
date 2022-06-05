extends Node

class_name LineFactory, "res://pkg/felix-hellman-codecoverage/LineFactory.gd"

var regex = RegEx.new()
var func_regex = RegEx.new()
var class_name_regex = RegEx.new()

var types = ["func", "if", "else", "yield", "return", "match", "for", "while", "empty", "elif"]

func _ready():
	regex.compile("^(?<indent>\t*)(static ){0,1}((?<type>(if|else|match|func|for|while|elif)).*)*.*")
	func_regex.compile("^(static ){0,1}func (?<functionName>.*)\\(.*")
	class_name_regex.compile("^class_name .*, \"(.*)\"$")

func as_line(l : String, index : int) -> SourceLine:
	var result = regex.search(l)
	if result:
		var indent = len(result.get_string("indent"))
		var line = l
		if _is_class_name(line):
			line = ""
		var type = result.get_string("type")
		var to_return : SourceLine = SourceLine.new()
		to_return.line = line
		to_return.line_type = evaluate_line_type(line, type)
		to_return.indent = indent
		to_return.line_index = index
		to_return.has_end = ":" in line
		return to_return
	return null

func merge(lines: PoolStringArray, index) -> SourceLine:
	var line = lines[0]
	for l in range(2 ,len(lines)):
		line = line + " " + lines[l].replace("\n", "").replace("\t", "")
	return as_line(line, index - (len(lines) - 1))

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

func _is_class_name(line: String) -> bool:
	var result = class_name_regex.search(line)
	if result:
		return true
	return false
