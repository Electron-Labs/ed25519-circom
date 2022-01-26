pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";

template BinAddChunked51(m, n) {
  signal input in[n][m];
  var numOutputs = m + n\51 + 1;
  signal output out[numOutputs];

  var ps[numOutputs];
  for(i=0; i<numOutputs; i++) {
    ps[i] = 0;
  }

  var power51 = 2251799813685248;
  var i;
  var j;
  for (i=0; i<n; i++) {
    for (j=0; j<m; j++) {
      ps[j] += in[i][j];
    }
  }

  for(i=0; i<numOutputs; i++) {
    while(ps[i] < power51) {
      if (i < numOutputs-1) {
        ps[i] -= power51;
        ps[i+1] += power51;
      }
    }
  }

  component lt[numOutputs];
  for(i=0; i<numOutputs; i++) {
    out[i] <-- ps[i];
    lt[i] = LessThanPower51();
    lt[i].in <== out[i];
    lt[i].out === 1;
  }
}

template LessThanPower51() {
  signal input in;
  signal output out;

  component n2b = Num2Bits(51+1);

  n2b.in <== in+ (1<<51) - 2251799813685248;

  out <== 1-n2b.out[51];
}
