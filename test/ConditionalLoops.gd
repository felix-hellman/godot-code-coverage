extends Node


func complex():
	for x in range(0, 100):
		if x % 15 == 0:
			print("FizzBuzz")
		elif x % 3 == 0:
			print("Fizz")
		elif x % 5 == 0:
			print("Buzz")
		
func simplex():
	for x in range(0, 100):
		if x % 15 == 0:
			print("Hux bux")
