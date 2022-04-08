pragma circom 2.0.0;

include "./verify.circom";

template BatchVerify(n, m) {
  signal input msg[n];
  
  signal input A[m][256];
  signal input R8[m][256];
  signal input S[m][255];

  signal input PointA[m][4][5];
  signal input PointR[m][4][5];

  var i;
  var j;
  var k;

  component verifiers[k];
  for (i=0; i<m; i++) {
    verifiers[i] = Ed25519Verifier(n);
  }

  for (i=0; i<m; i++) {
    for (j=0; j<n; j++) {
      verifiers[i].msg[j] <== msg[j];
    }
    for (j=0; j<255; j++) {
      verifiers[i].A[j] <== A[i][j];
      verifiers[i].R8[j] <== R8[i][j];
      verifiers[i].S[j] <== S[i][j];
    }
    verifiers[i].A[255] <== A[i][255];
    verifiers[i].R8[255] <== R8[i][255];

    for (j=0; j<4; j++) {
      for (k=0; k<5; k++) {
        verifiers[i].PointA[j][k] <== PointA[i][j][k];
        verifiers[i].PointR[j][k] <== PointR[i][j][k];
      }
    }
  }
}