pragma circom 2.0.0;

template BinAdd(nBits){
    signal input in[2][nBits];
    signal output out[nBits+1];
    var i;
    component addking[nBits];

    for(i=0;i<nBits;i++){
        addking[i] = fulladder();
    }

    addking[0].carry <== 0;
    addking[0].bit1 <== in[0][0];
    addking[0].bit2 <== in[1][0];
    out[0] <== addking[0].val;

    for(i=1;i<nBits;i++){
        addking[i].bit1 <== in[0][i];
        addking[i].bit2 <== in[1][i];
        addking[i].carry <== addking[i-1].carry_out;
        out[i] <== addking[i].val;
    }
    out[nBits] <== addking[nBits-1].carry_out;
}

template fulladder(){
    signal input bit1;
    signal input bit2;
    signal input carry;
    signal ab;
    signal bc;
    signal ca;
    signal output val;
    signal output carry_out;

    ab <== bit1 * bit2;
    bc <== bit2 * carry;
    ca <== bit1 * carry;

    val <== bit1+bit2+carry-2*(ab + bc + ca) + 4*ab*carry;
    carry_out <== ab + bc + ca -2*ab*carry;
}