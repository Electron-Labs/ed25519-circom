pragma circom 2.0.0;

include "./chunkedmul.circom";
include "./modulus.circom";
include "./utils.circom";
include "./lt.circom";

template BigModInv51() {
  signal input in[5];
  signal output out[5];

  var p[5] = [2251799813685229, 2251799813685247, 2251799813685247, 2251799813685247, 2251799813685247];

  // length k
  var inv[100] = mod_inv(51, 5, in, p);
  for (var i = 0; i < 5; i++) {
    out[i] <-- inv[i];
  }
  component lt[5];
  for (var i = 0; i < 5; i++) {
    lt[i] = LessThanPower51();
    lt[i].in <== out[i];
    lt[i].out * out[i] === out[i];
  }

  component mult = ChunkedMul(5, 5, 51);
  for (var i = 0; i < 5; i++) {
    mult.in1[i] <== in[i];
    mult.in2[i] <== out[i];
  }
  component mod = ModulusWith25519Chunked51(10);
  for (var i = 0; i < 10; i++) {
    mod.in[i] <== mult.out[i];
  }
  mod.out[0] === 1;
  for (var i = 1; i < 5; i++) {
    mod.out[i] === 0;
  }
}
