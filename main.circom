pragma circom 2.0.0;

include "bitifier.circom";
include "binary_adder.circom";
include "binary_multiplier.circom";

template Main(n) {
    signal input num1;
    signal input num2;
    signal bits1[n];
    signal bits2[n];
    signal sum_bits[n];
    signal product_bits[n];
    //signal myarray[n][n];
    signal output sum;
    signal output product;

    component Num2Bits_1 = Num2Bits(n);
    Num2Bits_1.num <== num1;
    for (var i=0; i<n; i++){
        Num2Bits_1.bits[i] ==> bits1[i];
    }

    component Num2Bits_2 = Num2Bits(n);
    Num2Bits_2.num <== num2;
    for (var i=0; i<n; i++){
        Num2Bits_2.bits[i] ==> bits2[i];
    }
    
    component binary_adder = binary_adder(n);
    for (var i=0; i<n ; i++){
        binary_adder.bits1[i] <== bits1[i];
        binary_adder.bits2[i] <== bits2[i];
    }
    for (var i=0; i<n ; i++){
        binary_adder.sum_bits[i] ==> sum_bits[i];
    }

    component binary_multiplier = binary_multiplier(n);
    for (var i=0; i<n ; i++){
        binary_multiplier.A[i] <== bits1[i];
        binary_multiplier.B[i] <== bits2[i];
    }
    for (var i=0; i<n ; i++){
        binary_multiplier.product_bits[i] ==> product_bits[i];
    }

    sum <== Bits2Num(sum_bits,n);
    product <== Bits2Num(product_bits,n);

}
component main = Main(128);