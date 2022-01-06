pragma circom 2.0.0;

include "binadd.circom";

template BinSub(nBits) {
  signal input a[nBits];
  signal input b[nBits];
  signal output out[nBits];

  var i;
  component add1ToFlipped = BinAdd(nBits);

  add1ToFlipped.a[0] <== 1 + b[0] - 2*b[0];
  add1ToFlipped.b[0] <== 1;
  for (i=1; i<nBits; i++) {
    add1ToFlipped.a[i] <== 1 + b[i] - 2*b[i];
    add1ToFlipped.b[i] <== 0;
  }

  component addWithComplement = BinAdd(nBits);
  for (i=0; i<nBits; i++) {
    addWithComplement.a[i] <== a[i];
    addWithComplement.b[i] <== add1ToFlipped.sum[i];
  }

  for (i=0; i<nBits; i++) {
    out[i] <== addWithComplement.sum[i];
  }
}

component main = BinSub(100);