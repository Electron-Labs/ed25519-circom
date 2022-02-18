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

  component lt1 = LessThanPower51();
  lt1.in <== out[0];
  lt1.out === 1;

  component lt2 = LessThanPower51();
  lt2.in <== out[numOutputs-1];
  lt2.out === 1;
}

template AddIrregularChunk51(m,n){ //assume m>=n
    signal input a[m];
    signal input b[n];
    signal psum[m];
    signal carry[m+1];
    signal output sum[m+1];

    for (var i=0; i<n ; i++){
        psum[i] <== a[i] + b[i];
    }
    for (var i=n; i<m ; i++){
        psum[i] <== a[i];
    }
    carry[0] <== 0;
    for (var i=0; i<m; i++){
        sum[i] <-- (psum[i]+carry[i])%2251799813685248;
        carry[i+1] <-- (psum[i]+carry[i])\2251799813685248;
        psum[i]+carry[i] === carry[i+1]*2251799813685248 + sum[i];
    }
    sum[m] <== carry[m];

    component lt1 = LessThanPower51();
    lt1.in <== sum[0];
    lt1.out === 1;

    component lt2 = LessThanPower51();
    lt2.in <== sum[m];
    lt2.out === 1;
}

function calculateNumOutputs(m, n) {
  return m + n\51 + 1;
}
