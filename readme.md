# First Set
To know which place in the memory is aveliable for writing, first set is used.

How it works? (exmple)
|                                                             |                      |                      |
|-------------------------------------------------------------| ---------------------| ---------------------|
| Input = A                                                   |                                             | 1011000              |
| $C[n] = C[n-1] \lor A[n] \quad (n>0, \quad C[0] = A[0]$)    | OR the last index of C and the index of A   | 1111000              |
| $C = C \ll 1$                                               | Left-shift C by 1                           | 1110000              |
| $B = \vec{C} \land A$                                       | And not(C) and A                            | 0001000              |