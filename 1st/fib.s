main:
	li %r0, 1
	li %r1, 1
	li %r3, 9
	li %r4, 0
loop:
	addi %r2, %r1, 0
	add %r1, %r0, %r1
	addi %r0, %r2, 0
	subi %r3, %r3, 1
	cmpd %r4, %r3
	ble loop
	li %r4, 89
	cmpd %r2, %r4
	beq ok
failed:
	li %r0, 2626
	out %r0
	end
ok:
	li %r0, 2625
	out %r0
	end
