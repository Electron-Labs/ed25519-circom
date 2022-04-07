pragma circom 2.0.0;

include "./scalarmul.circom";
include "./modulus.circom";
include "./point-addition.circom";
include "./pointcompress.circom";

include "../node_modules/@electron-labs/sha512/circuits/sha512/sha512.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/gates.circom";

template Ed25519Verifier(n) {
  signal input msg[n];
  
  signal input A[256];
  signal input R8[256];
  signal input S[255];

  signal input PointA[4][5];
  signal input PointR[4][5];

  signal output out;

  var G[4][5] = [[1738742601995546,
                  1146398526822698,
                  2070867633025821,
                  562264141797630,
                  587772402128613
                 ],
                 [
                  1801439850948184,
                  1351079888211148,
                  450359962737049,
                  900719925474099,
                  1801439850948198
                 ],
                 [1,
                  0,
                  0,
                  0,
                  0
                 ],
                 [
                  1841354044333475,
                  16398895984059,
                  755974180946558,
                  900171276175154,
                  1821297809914039
                 ]
                ];

  var i;
  var j;

  component compressA = PointCompress();
  component compressR = PointCompress();
  for (i=0; i<4; i++) {
    for (j=0; j<5; j++) {
      compressA.P[i][j] <== PointA[i][j];
      compressR.P[i][j] <== PointR[i][j];
    }
  }

  for (i=0; i<256; i++) {
    compressA.out[i] === A[i];
    compressR.out[i] === R8[i];
  }

  component hash = Sha512(n+256+256);
  for (i=0; i<256; i+=8) {
    for(j=0; j<8; j++) {
      hash.in[i+j] <== R8[i+(7-j)];
      hash.in[256+i+j] <== A[i+(7-j)];
    }
  }
  for (i=0; i<n; i+=8) {
    for(j=0; j<8; j++) {
      hash.in[512+i+j] <== msg[i+(7-j)];
    }
  }

  component bitModulus = ModulusWith252c(512);
  for (i=0; i<512; i+=8) {
    for(j=0; j<8; j++) {
      bitModulus.in[i+j] <== hash.out[i + (7-j)];
    }
  }

  // point multiplication s, G
  component pMul1 = ScalarMul();
  for(i=0; i<255; i++) {
    pMul1.s[i] <== S[i];
  }
  for (i=0; i<4; i++) {
    for (j=0; j<5; j++) {
      pMul1.P[i][j] <== G[i][j];
    }
  }

  // point multiplication h, A
  component pMul2 = ScalarMul();
  for (i=0; i<253; i++) {
    pMul2.s[i] <== bitModulus.out[i];
  }
  pMul2.s[253] <== 0;
  pMul2.s[254] <== 0;

  for (i=0; i<4; i++) {
    for (j=0; j<5; j++) {
      pMul2.P[i][j] <== PointA[i][j];
    }
  }

  component addRH = PointAdd();
  for (i=0; i<4; i++) {
    for (j=0; j<5; j++) {
      addRH.P[i][j] <== PointR[i][j];
      addRH.Q[i][j] <== pMul2.sP[i][j];
    }
  }

  component equal = PointEqual();
  for(i=0; i<3; i++) {
    for(j=0; j<5; j++) {
      equal.p[i][j] <== pMul1.sP[i][j];
      equal.q[i][j] <== addRH.R[i][j];
    }
  }

  out <== equal.out;
}

template PointEqual() {
  signal input p[3][5];
  signal input q[3][5];
  signal output out;

  var i;
  component mul[4];
  for (i=0; i<4; i++) {
    mul[i] = BinMulFastChunked51(5, 5);
  }
  
  for(i=0; i<5; i++) {
    // P[0] * Q[2]
    mul[0].in1[i] <== p[0][i];
    mul[0].in2[i] <== q[2][i];

    // Q[0] * P[2]
    mul[1].in1[i] <== q[0][i];
    mul[1].in2[i] <== p[2][i];

    // P[1] * Q[2]
    mul[2].in1[i] <== p[1][i];
    mul[2].in2[i] <== q[2][i];

    // Q[1] * P[2]
    mul[3].in1[i] <== q[1][i];
    mul[3].in2[i] <== p[2][i];
  }

  component mod[4];
  for (i=0; i<4; i++) {
    mod[i] = ModulusWith25519Chunked51(10);
  }
  
  for(i=0; i<10; i++) {
    // (P[0] * Q[2]) % p
    mod[0].in[i] <== mul[0].out[i];

    // (Q[0] * P[2]) % p
    mod[1].in[i] <== mul[1].out[i];

    // (P[1] * Q[2]) % p
    mod[2].in[i] <== mul[2].out[i];

    // (Q[1] * P[2]) % p
    mod[3].in[i] <== mul[3].out[i];
  }


  component equal1[5];
  component equal2[5];
  component and1[5];
  component and2[4];

  equal1[0] = IsEqual();
  equal1[0].in[0] <== mod[0].out[0];
  equal1[0].in[1] <== mod[1].out[0];

  equal2[0] = IsEqual();
  equal2[0].in[0] <== mod[2].out[0];
  equal2[0].in[1] <== mod[3].out[0];

  and1[0] = AND();
  and1[0].a <== equal1[0].out;
  and1[0].b <== equal2[0].out;

  for (i=1; i<5; i++) {
    equal1[i] = IsEqual();
    equal1[i].in[0] <== mod[0].out[i];
    equal1[i].in[1] <== mod[1].out[i];

    equal2[i] = IsEqual();
    equal2[i].in[0] <== mod[2].out[i];
    equal2[i].in[1] <== mod[3].out[i];

    and1[i] = AND();
    and1[i].a <== equal1[i].out;
    and1[i].b <== equal2[i].out;

    and2[i-1] = AND();
    and2[i-1].a <== and1[i-1].out;
    and2[i-1].b <== and1[i].out;
  }

  out <== and2[3].out;
}
