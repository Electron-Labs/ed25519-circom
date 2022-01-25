pragma circom 2.0.0;

include "binmulfast.circom";
include "modulus.circom";

template PointAddition(){
    var n = 255;
    signal input x1[n];
    signal input y1[n];
    signal input x2[n];
    signal input y2[n];
    signal _x1square[2*n];
    signal x1square[255];
    signal _x1cube[2*n];
    signal x1cube[255];
    signal _twoA_x1[2*n];
    signal twoA_x1[255]; //2Ax1
    signal _twoA_x1plus1[2*n+1];
    signal twoA_x1plus1[255]; // 2Ax1 + 1
    signal _three_x1square[2*n];
    signal three_x1square[255]; //3x1^2
    signal _derivative[n+1];
    signal derivative[255];
    signal _derivative_square[2*n];
    signal derivative_square[255]; //tested uptill thi point
    signal _two_x1[n+1];
    signal _two_x1plusA[n+2];
    signal _x2plusAplus2x1[n+3];
    signal x2plusAplus2x1[255];
    signal twice_x2plusAplus2x1[n+4];
    signal _quad_x2plusAplus2x1[n+5];
    signal quad_x2plusAplus2x1[255];
    signal _y1square[2*n];
    signal y1square[255];
    signal _LHS1[2*n];
    signal LHS1[255];
    signal _x1_der[2*n];
    signal x1_der[255];
    signal _x2_der[2*n];
    signal x2_der[255];
    signal _y1y2[2*n];
    signal y1y2[255];
    signal _twice_y1y2[n+1];
    signal _LHS2[n+2];
    signal LHS2[255];
    signal _twice_y1square[n+1];
    signal _RHS2[n+2];
    signal RHS2[255];
    
    
    var one[255] = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    var two[255] = [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    
    var three[255] = [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

    var A[255] = [0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    var twoA[255] = [0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    //x1 square mod p
    component multiply = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply.in1[i] <== x1[i];
        multiply.in2[i] <== x1[i];
    }
    for (var i=0; i<2*n; i++){
        multiply.out[i] ==> _x1square[i];
    }
    component mod = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod.a[i] <== _x1square[i];
    }
    for (var i=0; i<255; i++){
        mod.out[i] ==> x1square[i];
    }
    
    //x1 cube mod p
    component multiply2 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply2.in1[i] <== x1square[i];
        multiply2.in2[i] <== x1[i];
    }
    for (var i=0; i<2*n; i++){
        multiply2.out[i] ==> _x1cube[i];
    }
    component mod2 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod2.a[i] <== _x1cube[i];
    }
    for (var i=0; i<255; i++){
        mod2.out[i] ==> x1cube[i];
    }
    
    //2AX1+1
    component multiply3 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply3.in1[i] <== twoA[i];
        multiply3.in2[i] <== x1[i];
    }
    for (var i=0; i<2*n; i++){
        multiply3.out[i] ==> _twoA_x1[i];
    }
    component mod3 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod3.a[i] <== _twoA_x1[i];
    }
    for (var i=0; i<255; i++){
        mod3.out[i] ==> twoA_x1[i];
    }
    component adder = BinAdd(n);
    for (var i=0; i<n; i++){
        adder.in[0][i] <== twoA_x1[i];
    }
    for (var i=0; i<n; i++){
        adder.in[1][i] <== one[i];
    }
    for (var i=0; i<n+1; i++){
        adder.out[i] ==> _twoA_x1plus1[i];
    }
    component mod4 = ModulusWith25519(n+1);
    for (var i=0; i<n+1; i++){
        mod4.a[i] <== _twoA_x1plus1[i];
    }
    for (var i=0; i<255; i++){
        mod4.out[i] ==> twoA_x1plus1[i];
    }

    //3x1^2
    component multiply4 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply4.in1[i] <== three[i];
        multiply4.in2[i] <== x1square[i];
    }
    for (var i=0; i<2*n; i++){
        multiply4.out[i] ==> _three_x1square[i];
    }
    component mod5 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod5.a[i] <== _three_x1square[i];
    }
    for (var i=0; i<255; i++){
        mod5.out[i] ==> three_x1square[i];
    }
    
    //derivative mod p    (3x1^2 + 2AX1 + 1)%p
    component adder2 = BinAdd(n);
    for (var i=0; i<n; i++){
        adder2.in[0][i] <== twoA_x1plus1[i];
    }
    for (var i=0; i<n; i++){
        adder2.in[1][i] <== three_x1square[i];
    }
    for (var i=0; i<n+1; i++){
        adder2.out[i] ==> _derivative[i];
    }
    component mod6 = ModulusWith25519(n+1);
    for (var i=0; i<n+1; i++){
        mod6.a[i] <== _derivative[i];
    }
    for (var i=0; i<255; i++){
        mod6.out[i] ==> derivative[i];
    }

    //derivative_square mod p
    component multiply5 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply5.in1[i] <== derivative[i];
        multiply5.in2[i] <== derivative[i];
    }
    for (var i=0; i<2*n; i++){
        multiply5.out[i] ==> _derivative_square[i];
    }
    component mod7 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod7.a[i] <== _derivative_square[i];
    }
    for (var i=0; i<255; i++){
        mod7.out[i] ==> derivative_square[i];
    }
    //verfied till here

    //4(two_x1 + A + x2) mod p
    component adder3 = BinAdd(n);
    for (var i=0; i<n; i++){
        adder3.in[0][i] <== x1[i];
        adder3.in[1][i] <== x1[i];
    }
    for (var i=0; i<n+1; i++){
        adder3.out[i] ==> _two_x1[i];
    }
    component adder4 = BinAddIrregular(n+1,n);
    for (var i=0; i<n+1; i++){
        adder4.in1[i] <== _two_x1[i];
    }
    for (var i=0; i<n; i++){
        adder4.in2[i] <== A[i];
    }
    for (var i=0; i<n+2; i++){
        adder4.out[i] ==> _two_x1plusA[i];
    }
    component adder5 = BinAddIrregular(n+2,n);
    for (var i=0; i<n+2; i++){
        adder5.in1[i] <== _two_x1plusA[i];
    }
    for (var i=0; i<n; i++){
        adder5.in2[i] <== x2[i];
    }
    for (var i=0; i<n+3; i++){
        adder5.out[i] ==> _x2plusAplus2x1[i];
    }
    
    component adder6 = BinAdd(n+3);
    for (var i=0; i<n+3; i++){
        adder6.in[0][i] <== _x2plusAplus2x1[i];
        adder6.in[1][i] <== _x2plusAplus2x1[i];
    }
    for (var i=0; i<n+4; i++){
        adder6.out[i] ==> twice_x2plusAplus2x1[i];
    }
    component adder7 = BinAdd(n+4);
    for (var i=0; i<n+4; i++){
        adder7.in[0][i] <== twice_x2plusAplus2x1[i];
        adder7.in[1][i] <== twice_x2plusAplus2x1[i];
    }
    for (var i=0; i<n+5; i++){
        adder7.out[i] ==> _quad_x2plusAplus2x1[i];
    }
    component mod8 = ModulusWith25519(n+5);
    for (var i=0; i<n+5; i++){
        mod8.a[i] <== _quad_x2plusAplus2x1[i];
    }
    for (var i=0; i<255; i++){
        mod8.out[i] ==> quad_x2plusAplus2x1[i];
    }

    //y1square mod p
    component multiply6 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply6.in1[i] <== y1[i];
        multiply6.in2[i] <== y1[i];
    }
    for (var i=0; i<2*n; i++){
        multiply6.out[i] ==> _y1square[i];
    }
    component mod9 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod9.a[i] <== _y1square[i];
    }
    for (var i=0; i<255; i++){
        mod9.out[i] ==> y1square[i];
    }
    //LHS1 mod p
    component multiply7 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply7.in1[i] <== y1square[i];
        multiply7.in2[i] <== quad_x2plusAplus2x1[i];
    }
    for (var i=0; i<2*n; i++){
        multiply7.out[i] ==> _LHS1[i];
    }
    component mod10 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod10.a[i] <== _LHS1[i];
    }
    for (var i=0; i<255; i++){
        mod10.out[i] ==> LHS1[i];
    }
    
    for (var i=0; i<255; i++){
        LHS1[i] === derivative_square[i];
    }
    //----Equation 1 verified!-----

    //x1*derivative
    component multiply8 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply8.in1[i] <== x1[i];
        multiply8.in2[i] <== derivative[i];
    }
    for (var i=0; i<2*n; i++){
        multiply8.out[i] ==> _x1_der[i];
    }
    component mod11 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod11.a[i] <== _x1_der[i];
    }
    for (var i=0; i<255; i++){
        mod11.out[i] ==> x1_der[i];
    }

    //x2*derivative
    component multiply9 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply9.in1[i] <== x2[i];
        multiply9.in2[i] <== derivative[i];
    }
    for (var i=0; i<2*n; i++){
        multiply9.out[i] ==> _x2_der[i];
    }
    component mod12 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod12.a[i] <== _x2_der[i];
    }
    for (var i=0; i<255; i++){
        mod12.out[i] ==> x2_der[i];
    }

    //y1y2
    component multiply10 = BinMulFast(n,n);
    for (var i=0; i<n; i++){
        multiply10.in1[i] <== y1[i];
        multiply10.in2[i] <== y2[i];
    }
    for (var i=0; i<2*n; i++){
        multiply10.out[i] ==> _y1y2[i];
    }
    component mod13 = ModulusWith25519(2*n);
    for (var i=0; i<2*n; i++){
        mod13.a[i] <== _y1y2[i];
    }
    for (var i=0; i<255; i++){
        mod13.out[i] ==> y1y2[i];
    }

    //2y1y2
    component adder8 = BinAdd(n);
    for (var i=0; i<n; i++){
        adder8.in[0][i] <== y1y2[i];
        adder8.in[1][i] <== y1y2[i];
    }
    for (var i=0; i<n+1; i++){
        adder8.out[i] ==> _twice_y1y2[i];
    }

    //LHS2 mod p
    component adder9 = BinAddIrregular(n+1,n);
    for (var i=0; i<n+1; i++){
        adder9.in1[i] <== _twice_y1y2[i];
    }
    for (var i=0; i<n; i++){
        adder9.in2[i] <== x1_der[i];
    }
    for (var i=0; i<n+2; i++){
        adder9.out[i] ==> _LHS2[i];
    }
    component mod14 = ModulusWith25519(n+2);
    for (var i=0; i<n+2; i++){
        mod14.a[i] <== _LHS2[i];
    }
    for (var i=0; i<255; i++){
        mod14.out[i] ==> LHS2[i];
    }

    //twice_y1square
    component adder10 = BinAdd(n);
    for (var i=0; i<n; i++){
        adder10.in[0][i] <== y1square[i];
        adder10.in[1][i] <== y1square[i];
    }
    for (var i=0; i<n+1; i++){
        adder10.out[i] ==> _twice_y1square[i];
    }

    //RHS2 mod p
    component adder11 = BinAddIrregular(n+1,n);
    for (var i=0; i<n+1; i++){
        adder11.in1[i] <== _twice_y1square[i];
    }
    for (var i=0; i<n; i++){
        adder11.in2[i] <== x2_der[i];
    }
    for (var i=0; i<n+2; i++){
        adder11.out[i] ==> _RHS2[i];
    }
    component mod15 = ModulusWith25519(n+2);
    for (var i=0; i<n+2; i++){
        mod15.a[i] <== _RHS2[i];
    }
    for (var i=0; i<255; i++){
        mod15.out[i] ==> RHS2[i];
    }

    for (var i=0; i<255; i++){
        LHS2[i] === RHS2[i];
    }
    //----Equation 2 verified!-----




}

component main = PointAddition();