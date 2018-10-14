main:
	li %r0, 0
	lis %r0, 16320
	li %r1, 0
	lis %r1, 16384
p1:
	li %r3, 0
	lis %r3, 16480
	end
	cmpd %r2, %r3
	beq p2
	li %r0, 2626
failed:
	outll %r0
	outlh %r0
	end
p2:
	lis %r3, 48896
	end
	cmpd %r2, %r3
	beq p3
	li %r0, 2627
	jump failed
p3:
	lis %r3, 16448
	end
	cmpd %r2, %r3
	beq p4
	li %r0, 2628
	jump failed
p4:
	lis %r3, 16192
	end
	cmpd %r2, %r3
	beq ok
	li %r0, 2629
	jump failed
ok:
	li %r0, 2625
	outll %r0
	outlh %r0
	end
