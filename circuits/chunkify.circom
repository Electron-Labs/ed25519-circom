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
    if (left < 51) {
      numBitsToConvert = left;
    } else {
      numBitsToConvert = 51;
    }

    bitifer[chunkIndex] = Bits2Num(numBitsToConvert);
    offset = 51 * chunkIndex;
    for (i=0; i<numBitsToConvert; i++) {
      bitifer[chunkIndex].in[i] <== in[offset+i];
    }
    out[chunkIndex] <== bitifer[chunkIndex].out;
    left -= 51;
  }
}

function calcChunks(n) {
  var numChunks = n\51;
  if (n % 51 != 0) {
    numChunks++;
  }
  return numChunks;
}