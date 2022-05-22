extends Node

class_name TestReportFactory, "res://pkg/felix-hellman-codecoverage/src/TestReportFactory.gd"

var coverage : SourceTree = SourceTree.new()

var reports = []

func _ready():
	coverage._ready()

func inject_object(object : Node):
	var source = object.get_script().source_code
	var tree = coverage.parse(source, "name")
	var report = load("res://pkg/felix-hellman-codecoverage/src/Report.gd").new()
	report.register(tree, object.get_script().get_path())
	add_child(report)
	reports.append(report)
	var target = modify_impl(object, report.get_source())
	target.connect("register_visited", report, "register_visited")
	return target

func modify_impl(obj, source):
	var script : Script = GDScript.new()
	script.set_source_code(source)
	script.reload()
	obj.set_script(script)
	return obj

func on_complete():
	var output = get_report()
	var file = File.new()
	file.open("user://coverage_report.json", File.WRITE)
	file.store_string(to_json(output))
	file.close()

func get_report():
	var output = {"coverage": {}}
	for report in reports:
		output["coverage"][report.file_name] = report.report_to_dict()
	return output
