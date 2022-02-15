pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";
template LessThanPower51() {
  signal input in;
  signal output out;

  component n2b = Num2Bits(51+1);

  n2b.in <== in+ (1<<51) - 2251799813685248;

  out <== 1-n2b.out[51];
}