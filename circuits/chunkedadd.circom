pragma circom 2.0.0;

include "./lt.circom";

template BinAddChunked51(m, n){
  signal input in[n][m];
  var numOutputs = calculateNumOutputs(m, n);
  signal psum[m];
  signal carry[numOutputs];
  signal output out[numOutputs];

  var i;
  var j;
  var acc;
  for (j=0; j<m; j++){
    acc = 0;
    for (i=0; i<n; i++) {
      acc += in[i][j];
    }
    psum[j] <== acc;
  }
  
  carry[0] <== 0;
  for (i=0; i<m; i++){
    out[i] <-- (psum[i]+carry[i])%2251799813685248;
    carry[i+1] <-- (psum[i]+carry[i])\2251799813685248;
    psum[i]+carry[i] === carry[i+1]*2251799813685248 + out[i];
  }
  for (i=m; i<numOutputs-1; i++) {
    out[i] <-- (carry[i])%2251799813685248;
    carry[i+1] <-- (carry[i])\2251799813685248;
  }
  out[numOutputs-1] <== carry[numOutputs-1];

  component lt[numOutputs];
  for(var i=0; i<numOutputs; i++) {
    lt[i] = LessThanPower51();
    lt[i].in <== out[i];
    lt[i].out === 1;
  }
}

function calculateNumOutputs(m, n) {
  return m + n\51 + 1;
}