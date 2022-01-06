pragma circom 2.0.0;

template BinAdd(nBits){
    signal input a[nBits];
    signal input b[nBits];
    signal output sum[nBits+1];
    var i;
    component addking[nBits];

    for(i=0;i<nBits;i++){
        addking[i] = bitadd();
    }

    addking[0].carry <== 0;
    addking[0].bit1 <== a[0];
    addking[0].bit2 <== b[0];
    sum[0] <== addking[0].val;

    for(i=1;i<nBits;i++){
        addking[i].bit1 <== a[i];
        addking[i].bit2 <== b[i];
        addking[i].carry <== addking[i-1].carry_out;
        sum[i] <== addking[i].val;
    }
    sum[nBits] <== addking[nBits-1].carry_out;
}

template bitadd(){
    signal input bit1;
    signal input bit2;
    signal input carry;
    component mult = Multiplier3();
    component bit12 = Multiplier2();
    component bit23 = Multiplier2();
    component bit31= Multiplier2();
    signal output val;
    signal output carry_out;

    mult.in1 <== bit1;
    mult.in2 <== bit2;
    mult.in3 <== carry;

    bit12.in1 <== bit1;
    bit12.in2 <== bit2;

    bit23.in1 <== carry;
    bit23.in2 <== bit2;

    bit31.in1 <== bit1;
    bit31.in2 <== carry;

    val <== bit1+bit2+carry-2*(bit12.out + bit23.out +bit31.out) + 4*mult.out;
    carry_out <== bit12.out + bit23.out +bit31.out -2*mult.out;
}

template Multiplier2(){
   //Declaration of signals
   signal input in1;
   signal input in2;
   signal output out;
   out <== in1 * in2;
}
template Multiplier3 () {
   //Declaration of signals and components.
   signal input in1;
   signal input in2;
   signal input in3;
   signal output out;
   component mult1 = Multiplier2();
   component mult2 = Multiplier2();

   //Statements.
   mult1.in1 <== in1;
   mult1.in2 <== in2;
   mult2.in1 <== mult1.out;
   mult2.in2 <== in3;
   out <== mult2.out;
}

