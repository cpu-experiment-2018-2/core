# core
## 1st:Elmo
- 32bit PowerPC風アーキテクチャ
- 汎用レジスタGPR0 ~ 31(浮動小数点もこのレジスタを使う)
- リンクレジスタはGPR31で代用
- 条件レジスタeq/le

|     |[31:29]|[28:26]|[25:21]|[21:16]|[15:11]|[10:0]|              |
|:----|:-----:|:-----:|:-----:|:-----:|:-----:|:----:|:-------------|
|Addi |000    |000    |RT     |RA     |SI     |SI    |RT <- (RA) + SI (符号拡張)
|Subi |000    |001    |RT     |RA     |SI     |SI    |RT <- (RA) - SI (符号拡張)
|Muli |000    |010    |RT     |RA     |SI     |SI    |RT <- (RA) * SI (符号拡張)
|Divi |000    |011    |RT     |RA     |SI     |SI    |RT <- (RA) / SI (符号拡張)
|| 
|Add  |001    |000    |RT     |RA     |RB     |      |RT <- (RA) + (RB)
|Sub  |001    |001    |RT     |RA     |RB     |      |RT <- (RA) - (RB)
|Mul  |001    |010    |RT     |RA     |RB     |      |RT <- (RA) * (RB)
|Div  |001    |011    |RT     |RA     |RB     |      |RT <- (RA) / (RB)
|Fadd |001    |100    |RT     |RA     |RB     |      |RT <- (RA) + (RB)
|Fsub |001    |101    |RT     |RA     |RB     |      |RT <- (RA) - (RB)
|Fmul |001    |110    |RT     |RA     |RB     |      |RT <- (RA) * (RB)
|Fdiv |001    |111    |RT     |RA     |RB     |      |RT <- (RA) / (RB)
||
|And  |010    |000    |RT     |RA     |RB     |      |RT <- (RA) & (RB)
|Or   |010    |001    |RT     |RA     |RB     |      |RT <- (RA) &#124; (RB)
|Srawi|010    |010    |RT     |RA     |SI     |SI    |RT <- (RA) >>> SI
|Slawi|010    |011    |RT     |RA     |SI     |SI    |RT <- (RA) <<< SI
||
|Load |011    |000    |RT     |RA     |D      |D     |RT <- MEM((RA) + D)
|Store|011    |001    |RS     |RA     |D      |D     |MEM((RA) + D) <- (RS)
|Li   |011    |010    |RT     |SI     |SI     |SI    |RT <- SI
|Lis  |011    |011    |RT     |SI     |SI     |SI    |RT <- SI << 16
||
|Jump |100    |000    |LI     |LI     |LI     |LI    |PC <- LI
|Blr  |100    |001    |       |       |       |      |PC <- GPR31
|Bl   |100    |010    |LI     |LI     |LI     |LI    |GPR31 <- PC + 1, PC <- LI
|Blrr |100    |011    |RS     |       |       |      |GPR31 <- PC + 1, PC <- (RS)
||
|Beq  |101    |000    |LI     |LI     |LI     |LI    |if eq then PC <- LI
|Ble  |101    |001    |LI     |LI     |LI     |LI    |if eq &#124&#124 less then PC <- LI
|Cmpd |101    |010    |RA     |RB     |       |      |if (RA) == (RB) then eq <- 1, if (RA) < (RB) then less <- 1
|Cmpf |101    |011    |RA     |RB     |       |      |if (RA) == (RB) then eq <- 1, if (RA) < (RB) then less <- 1
|Blt  |101    |100    |LI     |LI     |LI     |LI    |if less then PC <- LI
||
|Inll |110    |000    |RT     |       |       |      | RT[7:0] <- input
|Inlh |110    |001    |RT     |       |       |      | RT[15:8] <- input
|Inul |110    |010    |RT     |       |       |      | RT[23:16] <- input
|Inuh |110    |011    |RT     |       |       |      | RT[31:24] <- input
|Outll|110    |100    |RA     |       |       |      | output RA[7:0]
|Outlh|110    |101    |RA     |       |       |      | output RA[15:8]
|Outul|110    |110    |RA     |       |       |      | output RA[23:16]
|Outuh|110    |111    |RA     |       |       |      | output RA[31:24]
||
|End  |111    |       |       |       |       |      |     
