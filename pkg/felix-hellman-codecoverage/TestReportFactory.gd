extends Node

class_name TestReportFactory, "res://pkg/felix-hellman-codecoverage/TestReportFactory.gd"

var coverage : SourceTree = SourceTree.new()

var enable_debug_log : bool = false

var reports = {}

func _ready():
	coverage._ready()

func _get_report(object):
	var path = object.get_script().get_path()
	var source = object.get_script().source_code
	var tree = coverage.parse(source)
	if enable_debug_log:
		coverage.__print_file_tree(tree["methods"], path)
	if path in reports:
		return reports[path]
	var report = load("res://pkg/felix-hellman-codecoverage/Report.gd").new()
	report.register(tree, path)
	add_child(report)
	reports[path] = report
	return report

func inject_object(object : Node):
	if object.get_script() == null:
		return object
	var report = _get_report(object)
	var target = modify_impl(object, report.get_source())
	target.connect("register_visited", report, "register_visited")
	return target

func modify_impl(obj, source):
	var script : Script = GDScript.new()
	if enable_debug_log:
		print(source)
	script.set_source_code(source)
	script.reload()
	obj.set_script(script)
	return obj

func on_complete():
	var output = get_report()
	for k in output["coverage"]:
		print("Found report for " + k)
	var file = File.new()
	file.open("user://coverage_report.json", File.WRITE)
	file.store_string(to_json(output))
	print("Report saved at : " + file.get_path_absolute())
	file.close()
	

func get_report():
	var output = {"coverage": {}}
	for report in reports:
		output["coverage"][reports[report].file_name] = reports[report].report_to_dict()
	return output
