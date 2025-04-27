// This file is part of the materials accompanying the book 
// "The Elements of Computing Systems" by Nisan and Schocken, 
// MIT Press. Book site: www.idc.ac.il/tecs

// New File name: subp1PointerTestVME.tst 
// it includes a rewritten tst script for running a rewritten vm file 

// File name: projects/07/MemoryAccess/PointerTest/PointerTestVME.tst

load subp1PointerTest.vm, 
output-file subp1PointerTest.out, 
compare-to subp1PointerTest.cmp, 
output-list RAM[256]%D1.6.1 RAM[3]%D1.6.1 RAM[4]%D1.6.1
            RAM[3032]%D1.6.1 RAM[3046]%D1.6.1;

set RAM[0] 256,

repeat 15 {
  vmstep;
}

output;
