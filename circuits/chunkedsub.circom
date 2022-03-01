pragma circom 2.0.0;
include "./lt.circom";

template BigSub51(k) {
  signal input a[k];
  signal input b[k];
  signal output out[k];
  signal output underflow;

  component unit0 = ModSub51();
  unit0.a <== a[0];
  unit0.b <== b[0];
  out[0] <== unit0.out;

  component unit[k - 1];
  for (var i = 1; i < k; i++) {
    unit[i - 1] = ModSubThree51();
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

template ModSub51() {
  signal input a;
  signal input b;
  signal output out;
  signal output borrow;
  component lt = LessThanOptimizedUpto51Bits();
  lt.in[0] <== a;
  lt.in[1] <== b;
  borrow <== lt.out;
  out <== borrow * (1 << 51) + a - b;
}

template ModSubThree51() {
  signal input a;
  signal input b;
  signal input c;
  assert(a - b - c + (1 << 51) >= 0);
  signal output out;
  signal output borrow;
  signal b_plus_c;
  b_plus_c <== b + c;
  component lt = LessThanOptimizedUpto52Bits();
  lt.in[0] <== a;
  lt.in[1] <== b_plus_c;
  borrow <== lt.out;
  out <== borrow * (1 << 51) + a - b_plus_c;
}