main:
	li %r1, 0
	li %r2, 10
	li %r3, 0
loop:
	add %r1, %r1, %r2
	subi %r2, %r2, 1
	cmpd %r3, %r2
	ble loop
result:
	li %r4, 55
	cmpd %r1, %r4
	beq ok
failed:
	li %r0, 2626
	out %r0
	cmpd %r1, %r1
	beq end
ok:
	li %r0, 2625
	out %r0
	cmpd %r1, %r1
	beq end
end:
	cmpd %r1, %r1
	beq end
