pragma circom 2.0.0;

template binary_multiplier(n){
    var m = n/2;
    signal input A[n];
    signal input B[n];
    signal P[n];
    signal output product_bits[n];

    component binary_adder[m-1];
    for (var j=0; j<m-1; j++){
        binary_adder[j] = binary_adder(n);
    }

    0 ==> binary_adder[0].bits2[0];
    for (var i=0; i<n-1; i++){
        A[i]*B[0] ==> binary_adder[0].bits1[i];
        A[i]*B[1] ==> binary_adder[0].bits2[i+1];
    }
    A[n-1]*B[0] ==> binary_adder[0].bits1[n-1];
    
    for (var j=1; j<m-1; j++){
       
       for (var i=0; i<n; i++){
           binary_adder[j-1].sum_bits[i] ==> binary_adder[j].bits1[i];
       }
       for (var i=0; i<j+1; i++){
          0 ==> binary_adder[j].bits2[i];
       }

       for (var i=j+1; i<n; i++){
           A[i - j-1]*B[j+1] ==> binary_adder[j].bits2[i];
       }
    }

    for (var i=0; i<n; i++){
        binary_adder[m-2].sum_bits[i] ==> product_bits[i];
    }


}