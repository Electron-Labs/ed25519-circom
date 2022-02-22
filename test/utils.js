function buffer2bits(buff) {
	const res = [];
	for (let i=0; i<buff.length; i++) {
    for (let j=0; j<8; j++) {
      if ((buff[i]>>j)&1) {
        res.push(1n);
      } else {
        res.push(0n);
      }
    }
	}
	return res;
}

function convertToEvenLength(hexInput) {
	if (hexInput.length % 2 == 1) {
		return '0' + hexInput;
	}
	return hexInput;
}

function normalize(input) {
	if (IsPowerOfTwo(input.length)) {
		input.push(0n);
	}
	return input;
}

function IsPowerOfTwo(x)
{
	return (x & (x - 1)) == 0;
}

function bigIntToLEBuffer(x) {
	return Buffer.from(convertToEvenLength(x.toString(16)), 'hex').reverse()
}

function pad(x, n) {
  var total = n-x.length;
  for (var i=0; i<total; i++) {
    x.push(0n);
  }
  return x;
}
// This function will give the right modulud as expected 
function modulus(num, p){
  return ((num%p)+p)%p;
}

function bitsToBigInt(arr) {
	res = BigInt(0);
	for (var i=0; i<arr.length; i++) {
		res += (BigInt(2) ** BigInt(i)) * BigInt(arr[i]);
	}
	return res;
}

// This function will convert a bigInt into the chucks of Integers
function chunkBigInt(n, mod=BigInt(2**51)){
	if (!n) return [0];
	let arr = [];
	while (n) {
		arr.push(BigInt(modulus(n,mod)));
		n /= mod;
	}
	return arr;
}
// This function will perform point addition on elliptic curve 25519 to check point addition circom
let p = BigInt(2**255) - BigInt(19);
let d = 37095705934669439343138083508754565189542113879843219016388785533085940283555n;

function point_add(P,Q){
  let A =  modulus((P[1]-P[0])*(Q[1]-Q[0]),p);
  let B =  modulus((P[1]+P[0])*(Q[1]+Q[0]),p); 
  let C =  modulus(BigInt(2)*P[3]*Q[3]*d , p);
  let D =  modulus(BigInt(2)*P[2]*Q[2] ,p);

  let E = B-A;
  let F = D-C;
  let G = D+C;
  let H = B+A;
  
  return [E*F, G*H, F*G, E*H];
}
function point_mul(s,P){
	let Q = [0n,1n,1n,0n];
	while (s > 0){
		if (s & 1n){
			Q = point_add(Q,P);
		}
		P = point_add(P,P);
		s >>= 1n;
	}
	return Q;

module.exports = { buffer2bits, convertToEvenLength, normalize, bigIntToLEBuffer, pad, chunkBigInt, bitsToBigInt };
