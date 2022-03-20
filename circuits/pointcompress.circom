pragma circom 2.0.0;

include "modinv.circom";
include "binmulfast.circom";
include "modulus.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template PointCompress(){
    signal input P[4][5];
    signal output out[256];
    var i;

    component mul_x = BinMulFastChunked51(5,5);
    component mul_y = BinMulFastChunked51(5,5);
    component modinv_z = BigModInv51();
    component mod_x = ModulusWith25519Chunked51(10);
    component mod_y = ModulusWith25519Chunked51(10);
    
    for(i=0;i<5;i++){
        modinv_z.in[i] <== P[2][i];
    }

    for(i=0;i<5;i++){
        mul_x.in1[i] <== P[0][i];
        mul_x.in2[i] <== modinv_z.out[i];
        mul_y.in1[i] <== P[1][i];
        mul_y.in2[i] <== modinv_z.out[i]; 
    }

    for(i=0;i<10;i++){
        mod_x.in[i] <== mul_x.out[i];
        mod_y.in[i] <== mul_y.out[i];
    }   

    component bits_y[5];
    for(i=0;i<5;i++){
        bits_y[i] = Num2Bits(51);
    }
    for(i=0;i<5;i++){
        bits_y[i].in <== mod_y.out[i];
    }
    
    component bits_x = Num2Bits(51);
    bits_x.in <== mod_x.out[0];
    
    for(i=0;i<51;i++){
        out[i] <== bits_y[0].out[i];
        out[i+51] <== bits_y[1].out[i];
        out[i+102] <== bits_y[2].out[i];
        out[i+153] <== bits_y[3].out[i];
        out[i+204] <== bits_y[4].out[i];
    }

    out[255] <-- mod_x.out[0] & 1;
    out[255] * (out[255] - 1) === 0;
}
