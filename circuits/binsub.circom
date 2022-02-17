pragma circom 2.0.0;

include "binadd.circom";

template BinSub(nBits) {
  signal input in[2][nBits];
  signal output out[nBits];

  var i;
  component add1ToFlipped = BinAdd(nBits);

  add1ToFlipped.in[0][0] <== 1 + in[1][0] - 2*in[1][0];
  add1ToFlipped.in[1][0] <== 1;
  for (i=1; i<nBits; i++) {
    add1ToFlipped.in[0][i] <== 1 + in[1][i] - 2*in[1][i];
    add1ToFlipped.in[1][i] <== 0;
  }

  component addWithComplement = BinAdd(nBits);
  for (i=0; i<nBits; i++) {
    addWithComplement.in[0][i] <== in[0][i];
    addWithComplement.in[1][i] <== add1ToFlipped.out[i];
  }

  for (i=0; i<nBits; i++) {
    out[i] <== addWithComplement.out[i];
  }
}

template BigSubX(n, k) {
  assert(n <= 252);
  signal input a[k];
  signal input b[k];
  signal output out[k];
  signal output underflow;

  component unit0 = ModSubX(n);
  unit0.a <== a[0];
  unit0.b <== b[0];
  out[0] <== unit0.out;

  component unit[k - 1];
  for (var i = 1; i < k; i++) {
    unit[i - 1] = ModSubThreeX(n);
    unit[i - 1].a <== a[i];
    unit[i - 1].b <== b[i];
    if (i == 1) {
        unit[i - 1].c <== unit0.borrow;
    } else {
        unit[i - 1].c <== unit[i - 2].borrow;
    }
    out[i] <== unit[i - 1].out;
  }
  underflow <== unit[k - 2].borrow;
}

template ModSubX(n) {
  assert(n <= 252);
  signal input a;
  signal input b;
  signal output out;
  signal output borrow;
  component lt = LessThan(n);
  lt.in[0] <== a;
  lt.in[1] <== b;
  borrow <== lt.out;
  out <== borrow * (1 << n) + a - b;
}

template ModSubThreeX(n) {
  assert(n + 2 <= 253);
  signal input a;
  signal input b;
  signal input c;
  assert(a - b - c + (1 << n) >= 0);
  signal output out;
  signal output borrow;
  signal b_plus_c;
  b_plus_c <== b + c;
  component lt = LessThan(n + 1);
  lt.in[0] <== a;
  lt.in[1] <== b_plus_c;
  borrow <== lt.out;
  out <== borrow * (1 << n) + a - b_plus_c;
}
