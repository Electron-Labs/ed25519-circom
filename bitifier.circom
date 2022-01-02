pragma circom 2.0.0;
function Bits2Num(bits, n){
    var num = 0;
    for (var i=0; i<n; i++){
        num = num + bits[i] * 2**i;
    }
    return num;
}

template Num2Bits(n){
    signal input num;
    signal output bits[n];
    var temp = num;
    var q;
    var r;
    for (var i=0; i<n; i++){
        q = temp \ 2;
        r = temp - 2*q;
        bits[i] <== r;
        temp = q;
    }
}