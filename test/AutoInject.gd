extends Node2D

var factory : TestReportFactory = TestReportFactory.new()

func _ready():
	#factory.debug_logging_enabled = true
	add_child(factory)
	get_tree().connect("node_added", self, "inject")
	var root = get_parent()
	while root.get_parent() != null:
		root = get_parent()
	var all = get_all_children(root)
	for node in all:
		if node != self:
			inject(node)
	var c = CTC.new()

	
	add_child(c)
	

func inject(object):
	factory.inject_object(object)

func get_all_children(child: Node):
	var collect = []
	for c in child.get_children():
		collect.append_array(child.get_children())
		collect.append_array(get_all_children(c))
	return collect
