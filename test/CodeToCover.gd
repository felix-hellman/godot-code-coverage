extends Node

class_name CTC, "res://pkg/felix-hellman-codecoverage/test/CodeToCover.gd"

var x = 123

func t(conditional : bool):
	var a = 1 + 1
	var b = 2 + 5
	a = b + 7
	if conditional:
		b = a - 14
		a = a * 2
	else:
		a = b - 14
		b = b * 2
	var c = a + b
	yield()
	a = a - a
	b = b - b
	return c

func t2(conditional: bool):
	var a = 1 + 1
	var b = 2 + 5
	a = b + 7
	match conditional:
		true:
			var d = 5
		false:
			var e = 7
		_:
			var f = 11
	var c = a + b
	yield()
	a = a - a
	b = b - b
	return c

func t3(conditional: bool):
	var a = 1
	if conditional:
		var b = 1
		if conditional:
			var c = 1
		else:
			var d = 5
	return a
