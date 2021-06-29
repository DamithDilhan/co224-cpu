// program to data memory
loadi 0 5       // r0 = 5
loadi 1 3       // r1 = 3
add 2 0 1       // r2 = 8
sub 3 0 2       // r3 = -3
loadi 4 2       // r4 = 2
loadi 6 0x0E    // r6 = 16
loadi 5 0       // r5 = 0
add 5 5 4       // r5 = r5 +2
beq 0x01 6 5    // r6 == r5 ? c + 2 
j 0xFD          // jump c - 2
loadi 7 1