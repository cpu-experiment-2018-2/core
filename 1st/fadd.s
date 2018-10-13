main:
	li %r0, 0
	lis %r0, 16320
	li %r1, 0
	lis %r1, 16320
	li %r3, 0
	lis %r3, 16448
	cmpd %r2, %r3
	beq ok
failed:
	li %r0, 2626
	outll %r0
	outlh %r0
	end
ok:
	li %r0, 2625
	outll %r0
	outlh %r0
	end
