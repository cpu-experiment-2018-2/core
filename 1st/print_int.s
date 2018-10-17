main:
	li %r3, 53
print_int:
	li %r4, 0
	cmpd %r4, %r3
	ble print_uint
	li %r4, 45
	outll %r4
	sub %r3, %r4, %r3
print_uint:
	jump div10
	addi %r4, 48
	outll %r4
	li %r4, 0
	cmpd %r3, %r4
	beq finished
	jump print_uint
div10:
	li %r4, 0
	li %r5, 52428
	lis %r5, 3276
	add %r6, %r4, %r5
	srawi %r6, %r6, 1
div10_mul10:
	slawi %r7, %r6, 3
	slawi %r8, %r6, 1
	add %r7, %r7, %r8
div10_cmp:
	cmpd %r7, %r3
	ble div10_l1
	addi %r5, %r6, 0
	jump div10
div10_l1:
	addi %r7, %r7, 10
	cmpd %r7, %r3
	ble div10_l2
div10_return:
	subi %r7, %r7, 10
	sub %r4, %r3, %r7
	addi %r3, %r6, 0
	jump print_uint
div10_l2:
	addi %r4, %r6, 0
	jump div10
finished:
	li %r4, 10
	outll %r4
	end
