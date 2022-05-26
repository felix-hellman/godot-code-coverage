extends Node

class_name SourceLine, "res://pkg/felix-hellman-codecoverage/SourceLine.gd"

var line : String
var line_type 
var indent : int
var line_index : int

func to_string() -> String:
	return "Type: " + str(line_type) + " Indent: " + str(indent) + " Index: " + str(line_index) + "\n" + line
