extends Node2D

var factory : TestReportFactory = TestReportFactory.new()

var dissallowed_sources = [
	"res://pkg/felix-hellman-codecoverage/LineFactory.gd",
	"res://pkg/felix-hellman-codecoverage/SourceLine.gd",
	"res://pkg/felix-hellman-codecoverage/SourceTree.gd",
	"res://pkg/felix-hellman-codecoverage/TestReportFactory.gd",
	"res://pkg/felix-hellman-codecoverage/AutoInject.gd",
	"res://pkg/felix-hellman-codecoverage/Report.gd"
]

func _ready():
	add_child(factory)
	get_tree().connect("node_added", self, "inject")

	

func inject(object):
	if object != self and object.get_script() != null and not object.get_script().get_path() in dissallowed_sources:
		factory.inject_object(object)

func get_all_children(child: Node):
	var collect = []
	for c in child.get_children():
		collect.append_array(child.get_children())
		collect.append_array(get_all_children(c))
	return collect

func _exit_tree():
	factory.on_complete()
	#._exit_tree()
