pragma circom 2.0.0;

include "./lt.circom";

template BinAddChunked51(m, n){
  signal input in[n][m];
  var numOutputs = calculateNumOutputs(m, n);
  signal psum[m];
  signal carry[numOutputs];
  signal output out[numOutputs];

  component lt1[n][m];
  var i;
  var j;
  for(i=0; i<n; i++) {
    for (j=0; j<m; j++) {
      lt1[i][j] = LessThanPower51();
      lt1[i][j].in <== in[i][j];
      lt1[i][j].out === 1;
    } 
  }

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

  component lt2[numOutputs];
  for(i=0; i<numOutputs; i++) {
    lt2[i] = LessThanPower51();
    lt2[i].in <== out[i];
    lt2[i].out === 1;
  }
}

function calculateNumOutputs(m, n) {
  return m + n\51 + 1;
}
