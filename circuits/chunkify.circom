pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";

template Chunkify(n) {
  signal input in[n];
  var numChunks = calcChunks(n);
  signal output out[numChunks];

  component bitifer[numChunks];
  var left = n;
  var i;
  var offset;
  var numBitsToConvert;
  for (var chunkIndex=0; chunkIndex<numChunks; chunkIndex++) {
    if (left < 64) {
      numBitsToConvert = left;
    } else {
      numBitsToConvert = 64;
    }

    bitifer[chunkIndex] = Bits2Num(numBitsToConvert);
    offset = 64 * chunkIndex;
    for (i=0; i<numBitsToConvert; i++) {
      bitifer[chunkIndex].in[i] <== in[offset+i];
    }
    out[chunkIndex] <== bitifer[chunkIndex].out;
    left -= 64;
  }
}

function calcChunks(n) {
  var numChunks = n\64;
  if (n % 64 != 0) {
    numChunks++;
  }
  return numChunks;
}