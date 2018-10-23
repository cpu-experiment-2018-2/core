main:
	li %r0, 2625
	li %r1, 5
	store %r0, %r1, 1
	load %r2, %r1, 1
	cmpd %r0, %r2
	beq ok
failed:
	li %r3, 2626
	outll %r3
	outlh %r3
	end
ok:
	outll %r0
	outlh %r0
	end
