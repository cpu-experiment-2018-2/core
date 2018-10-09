main:
	li %r0, 2625
	li %r1, 5
	store %r0, %r1, 9
	load %r2, %r1, 4
	cmpd %r0, %r2
	beq ok
failed:
	li %r3, 2626
	out %r3
	jump end
ok:
	out %r0
	jump end
end:
	jump end
