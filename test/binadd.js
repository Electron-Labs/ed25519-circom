const chai = require("chai");
const path = require("path");
const assert = require("assert");

const wasm_tester = require("circom_tester").wasm;

describe("Binary Adder Test", () => {
	describe("when performing binary additon on two 8 bit numbers", () => {
		it("should add them correctly", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "binadd1.circom"));
			const a = BigInt("128");
			const buf = bigIntToLEBuffer(a);
			const asBits = buffer2bits(buf);
			const witness = await cir.calculateWitness({ "in": [asBits, asBits]}, true);

			const expected = normalize(buffer2bits(bigIntToLEBuffer(a+a)));
			assert.ok(witness.slice(1, 10).every((u, i) => {
				return u === expected[i];
			}));
		});
	});
	describe("when performing binary additon on two 256 bit numbers", () => {
		it("should add them correctly", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "binadd2.circom"));
			const a = BigInt("87896044618658097711785492504343953926634992332820282019728792003956564819949");
			const b = BigInt("97896044618658097711785492504343953926634992332820282019728792003956564819948");
			const buf1 = bigIntToLEBuffer(a);
			const asBits1 = buffer2bits(buf1);
			const buf2 = bigIntToLEBuffer(b);
			const asBits2 = buffer2bits(buf2);
			const witness = await cir.calculateWitness({ "in": [asBits1, asBits2]}, true);

			const expected = normalize(buffer2bits(bigIntToLEBuffer(a+b)));
			assert.ok(witness.slice(1, 258).every((u, i) => {
				return u === expected[i];
			}));
		});
	});
});

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