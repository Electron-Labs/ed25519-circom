pragma circom 2.0.0;

include "./chunkify.circom";
include "./binadd.circom";
include "../circomlib/circuits/compconstant.circom";

template BinMulFast(m, n) {
  signal input in1[m];
  signal input in2[n];

  var totalBits = m+n;
  signal output out[totalBits];

  var i;
  var j;

  component chunkify1 = Chunkify(m);
  var numChunks1 = calcChunks(m);
  for (i=0; i<m; i++) {
    chunkify1.in[i] <== in1[i];
  }

  component chunkify2 = Chunkify(n);
  var numChunks2 = calcChunks(n);
  for (i=0; i<n; i++) {
    chunkify2.in[i] <== in2[i];
  }

  component bitifiers[numChunks1*numChunks2];
  var bitifiedProduct[numChunks1*numChunks2][m+n];
  var bitifierIndex;
  var k;
  var offset;
  var endOfBits;
  for (i=0; i<numChunks1; i++) {
    for (j=0; j<numChunks2; j++) {
      bitifierIndex = i*numChunks2 + j;
      bitifiers[bitifierIndex] = Num2Bits(64);
      bitifiers[bitifierIndex].in <== chunkify1.out[i] * chunkify2.out[j];

      for (k=0; k<m+n; k++) {
        bitifiedProduct[bitifierIndex][k] = 0;
      }

      offset = (i+j)*32;
      if (offset+64 < m+n) {
        endOfBits = offset+64;
      } else {
        endOfBits = m+n;
      }
      for (k=offset; k<endOfBits; k++) {
        bitifiedProduct[bitifierIndex][k] = bitifiers[bitifierIndex].out[k-offset];
      }
    }
  }

  var result[m+n];
  for (i=0; i<m+n; i++) {
    result[i] = 0;
  }

  component adders[numChunks1*numChunks2];
  for (i=0; i<numChunks1*numChunks2; i++) {
    adders[i] = BinAdd(m+n);

    for (j=0; j<m+n; j++) {
      adders[i].in[0][j] <== result[j];
      adders[i].in[1][j] <== bitifiedProduct[i][j];
    }
    for (j=0; j<m+n; j++) {
      result[j] = adders[i].out[j];
    }
  }

  for (i=0; i<m+n; i++) {
    out[i] <== result[i];
  }
}
