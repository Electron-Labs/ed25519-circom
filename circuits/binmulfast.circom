pragma circom 2.0.0;

include "./chunkify.circom";
include "./binadd.circom";

template BinMulFast(m, n) {
  signal input in1[m];
  signal input in2[n];
  signal output out[m+n];

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
  var k;
  var endOfBits;
  component adders[numChunks1*numChunks2-1];
  for (i=0; i<numChunks1; i++) {
    for (j=0; j<numChunks2; j++) {
      bitifiers[i*numChunks2 + j] = Num2Bits(170);
      bitifiers[i*numChunks2 + j].in <== chunkify1.out[i] * chunkify2.out[j];

      if ((i+j)*85+170 < m+n) {
        endOfBits = (i+j)*85+170;
      } else {
        endOfBits = m+n;
      }
      for (k=0; k<(i+j)*85; k++) {
        bitifiedProduct[i*numChunks2 + j][k] = 0;
      }
      for (k=(i+j)*85; k<endOfBits; k++) {
        bitifiedProduct[i*numChunks2 + j][k] = bitifiers[i*numChunks2 + j].out[k-(i+j)*85];
      }
      for (k=endOfBits; k<m+n; k++) {
        bitifiedProduct[i*numChunks2 + j][k] = 0;
      }

      if (i!=0 || j!=0) {
        if ((numChunks2 > 1 && i==0 && j==1) || (numChunks2 ==1 && i==1 && j==0)) {
          adders[0] = BinAdd(m+n);
          for (k=0; k<m+n; k++) {
            adders[0].in[0][k] <== bitifiedProduct[0][k];
            adders[0].in[1][k] <== bitifiedProduct[1][k];
          }
        } else {
          adders[i*numChunks2 + j-1] = BinAdd(m+n);
          for (k=0; k<m+n; k++) {
            adders[i*numChunks2 + j-1].in[0][k] <== adders[i*numChunks2 + j-2].out[k];
            adders[i*numChunks2 + j-1].in[1][k] <== bitifiedProduct[i*numChunks2 + j][k];
          }
        }
      }
    }
  }

  if (numChunks1*numChunks2 == 1) {
    for (i=0; i<m+n; i++) {
      out[i] <== bitifiedProduct[0][i];
    }
  } else {
    if (numChunks1 * numChunks2 == 2) {
      for (i=0; i<m+n; i++) {
        out[i] <== adders[0].out[i];
      }
    } else {
      for (i=0; i<m+n; i++) {
        out[i] <== adders[numChunks1*numChunks2-2].out[i];
      }
    }
  }
}

template BinMulFastChunked51(m, n) {
  signal input in1[m];
  signal input in2[n];
  signal output out[m+n];

  var power51 = 2251799813685248;

  var i;
  var j;

  var pp[m+n];
  for (j=0; j<n; j++) {
    for (i=0; i<m; i++) {
      pp[i+j] += in1[i] * in2[j];
    }
  }
  
  for(i=0; i<m+n; i++) {
    while(pp[i] < power51) {
      if (i < m+n-1) {
        pp[i] -= power51;
        pp[i+1] += power51;
      }
    }
  }

  component lt[m+n];
  for(i=0; i<m+n; i++) {
    out[i] <-- pp[i];
    lt[i] = LessThanPower51();
    lt[i].in <== out[i];
    lt[i].out === 0;
  }
}

template LessThanPower51() {
  signal input in;
  signal output out;

  component n2b = Num2Bits(52+1);

  n2b.in <== in+ (1<<52) - 2251799813685248;

  out <== 1-n2b.out[52];
}

component main = BinMulFastChunked51(5, 5);
