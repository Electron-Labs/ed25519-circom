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

module.exports = { buffer2bits, convertToEvenLength, normalize, bigIntToLEBuffer };