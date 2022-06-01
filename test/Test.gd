extends Node2D

var auto_inject

func _ready():
	auto_inject = load("res://pkg/felix-hellman-codecoverage/AutoInject.gd").new()
	add_child(auto_inject)
	#can_generate_report_test()
	#can_parse_loops()
	can_parse_fizzbuzz()
	
	
func can_generate_report_test():
	var expected_partially_covered_lines = [11]
	var expected_fully_covered_lines = [8,9,10,12,13,17]
	var expected_to_be_covered_after_resume = [19,20,21]
	var to_cover = load("res://test/CodeToCover.gd").new()
	add_child(to_cover)
	var f = to_cover.t(true)
	var report = auto_inject.factory.get_report()
	var method_t = report["coverage"]["res://test/CodeToCover.gd"]["t"]
	assert(method_t[11] == "1/2")
	for index in expected_partially_covered_lines:
		assert(method_t[index] == "1/2")
	for index in expected_fully_covered_lines:
		assert(method_t[index] == "1/1")
	for index in expected_to_be_covered_after_resume:
		assert(method_t[index] == "0/1")
	f.resume()
	report = auto_inject.factory.get_report()
	method_t = report["coverage"]["res://test/CodeToCover.gd"]["t"]
	for index in expected_to_be_covered_after_resume:
		assert(method_t[index] == "1/1")

func can_parse_loops():
	var to_cover = load("res://test/LoopsToCover.gd").new()
	add_child(to_cover)
	to_cover.t4()
	to_cover.t5()

func can_parse_fizzbuzz():
	var to_cover = load("res://test/ConditionalLoops.gd").new()
	add_child(to_cover)
	to_cover.complex()
	var report = auto_inject.factory.get_report()
	var method_complex = report["coverage"]["res://test/ConditionalLoops.gd"]["complex"]
	assert(method_complex[5] == "1/1")
	assert(method_complex[6] == "3/3")
