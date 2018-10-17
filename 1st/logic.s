main:
	li %r0, 22
	slawi %r2, %r0, 1
	li %r3, 44
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
