init:
main:
	li %r0, 10
	li %r1, 0
	blrr %r0
	li %r2, 1
	cmpd %r1, %r2
	beq ok
failed:
	li %r0, 48
	outll %r0
	end
add_label:
	addi %r1, %r1, 1
	blr
ok:
	li %r0, 49
	outll %r0
	end
