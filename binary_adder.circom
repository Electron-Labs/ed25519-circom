pragma circom 2.0.0;

template xor(){
    signal input bit_a;
    signal input bit_b;
    signal notb;
    signal nota;
    signal A1;
    signal A2;
    signal output result;

    notb <== 1 - bit_b;
    nota <== 1 - bit_a;
    A1 <== bit_a * notb;
    A2 <== nota * bit_b;
    result <== A1 + A2 - A1*A2;
}

template half_adder(){
    signal input bit_a;
    signal input bit_b;
    signal output sum_bit;
    signal output carry_bit;

    component xor = xor();
    xor.bit_a <== bit_a;
    xor.bit_b <== bit_b;
    xor.result ==> sum_bit;

    carry_bit <== bit_a*bit_b;
}

template full_adder(){
    signal input bit_a;
    signal input bit_b;
    signal input cin;
    signal sum_inter;
    signal carry_inter1;
    signal carry_inter2;
    signal output sum;
    signal output carry;
    
    component half_adder1 = half_adder();
    half_adder1.bit_a <== bit_a;
    half_adder1.bit_b <== bit_b;
    half_adder1.sum_bit ==> sum_inter;
    half_adder1.carry_bit ==> carry_inter1;

    component half_adder2 = half_adder();
    half_adder2.bit_a <== sum_inter;
    half_adder2.bit_b <== cin;
    half_adder2.sum_bit ==> sum;
    half_adder2.carry_bit ==> carry_inter2;

    carry <== carry_inter1 + carry_inter2 - carry_inter1*carry_inter2;

}

template binary_adder(n){
    signal input bits1[n];
    signal input bits2[n];
    signal output sum_bits[n];
    
    component full_adders[n-1];
    for (var i=0; i<n-1; i++){
        full_adders[i] = full_adder();
    }

    var carry = 0;
    full_adders[0].bit_a <== bits1[0];
    full_adders[0].bit_b <== bits2[0];
    full_adders[0].cin <== 0;
    full_adders[0].sum ==> sum_bits[0];
    carry = full_adders[0].carry;

    for (var i=1; i<n-1; i++){
        full_adders[i].bit_a <== bits1[i];
        full_adders[i].bit_b <== bits2[i];
        full_adders[i].cin <== carry;
        full_adders[i].sum ==> sum_bits[i];
        carry = full_adders[i].carry;
    }

    sum_bits[n-1] <== carry;
}