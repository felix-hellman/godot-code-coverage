extends Node2D

func _ready():
	can_generate_report_test()
	
func can_generate_report_test():
	var expected_partially_covered_lines = [11]
	var expected_fully_covered_lines = [8,9,10,12,13,17]
	var expected_to_be_covered_after_resume = [19,20,21]
	var to_cover = load("res://pkg/felix-hellman-codecoverage/test/CodeToCover.gd").new()
	add_child(to_cover)
	var factory : TestReportFactory = TestReportFactory.new()
	add_child(factory)
	factory.inject_object(to_cover)
	var f = to_cover.t(true)
	var report = factory.get_report()
	var method_t = report["coverage"]["res://pkg/felix-hellman-codecoverage/test/CodeToCover.gd"]["t"]
	assert(method_t[11] == "1/2")
	for index in expected_partially_covered_lines:
		assert(method_t[index] == "1/2")
	for index in expected_fully_covered_lines:
		assert(method_t[index] == "1/1")
	for index in expected_to_be_covered_after_resume:
		assert(method_t[index] == "0/1")
	f.resume()
	report = factory.get_report()
	method_t = report["coverage"]["res://pkg/felix-hellman-codecoverage/test/CodeToCover.gd"]["t"]
	for index in expected_to_be_covered_after_resume:
		assert(method_t[index] == "1/1")



