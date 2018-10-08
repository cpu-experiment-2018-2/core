# core
## 1st:Elmo
- 32bit PowerPC風アーキテクチャ
- 汎用レジスタGPR0 ~ 31(浮動小数点もこのレジスタを使う)
- リンクレジスタはGPR31で代用
- 条件レジスタeq/le

|     |[31:29]|[28:26]|[25:21]|[21:16]|[15:11]|[10:0]|              |
|:----|:-----:|:-----:|:-----:|:-----:|:-----:|:----:|:-------------|
|Addi |000    |000    |RT     |RA     |SI     |SI    |RT <- (RA)+SI
|Subi |000    |001    |RT     |RA     |SI     |SI    |RT <- (RA)-SI
|Muli |000    |010    |RT     |RA     |SI     |SI    |RT <- (RA)*SI
|Divi |000    |011    |RT     |RA     |SI     |SI    |RT <- (RA)/SI
|| 
|Add  |001    |000    |RT     |RA     |RB     |      |RT <- (RA)+(RB)
|Sub  |001    |001    |RT     |RA     |RB     |      |RT <- (RA)-(RB)
|Mul  |001    |010    |RT     |RA     |RB     |      |RT <- (RA)*(RB)
|Div  |001    |011    |RT     |RA     |RB     |      |RT <- (RA)/(RB)
||
|And  |010    |000    |RT     |RA     |RB     |      |RT <- (RA)&(RB)
|Or   |010    |001    |RT     |RA     |RB     |      |RT <- (RA)&#124;(RB)
||
|Load |011    |000    |RT     |RA     |D      |D     |RT <- MEM((RA)+D)
|Store|011    |001    |RS     |RA     |D      |D     |MEM((RA)+D) <- (RS)
|Li   |011    |010    |RT     |SI     |SI     |SI    |RT <- SI
||
|Jump |100    |000    |LI     |LI     |LI     |LI    |GPR31<-PC+1, PC <- LI
|Blr  |100    |001    |       |       |       |      |PC <- GPR31
||
|Beq  |101    |000    |LI     |LI     |LI     |LI    |if eq then PC <- LI
|Ble  |101    |001    |LI     |LI     |LI     |LI    |if le then PC <- LI
|Cmpd |101    |010    |RA     |RB     |       |      |if (RA) == (RB) then eq <- 1, if (RA) <= (RB) then le <- 1
||
|In   |110    |000    |RA     |       |       |      |
|Out  |110    |001    |RA     |       |       |      |
|End  |110    |010    |       |       |       |      |     
