const chai = require("chai");
const path = require("path");
const assert = require("assert");

const wasm_tester = require("circom_tester").wasm;
// const snarkjs = require("snarkjs");

describe("Modulus Test", () => {
	describe("when performing modular additon on two numbers using prime field of prime 25519", () => {
		const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");

		it("should add them correctly when sum is over global prime in circom", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "modulus1.circom"));
			const a = BigInt("157896044618658097711785492504343953926634992332820282019728792003956564819949");
			const buf = Buffer.from(a.toString(16), 'hex').reverse();
			const asBits = buffer2bits(buf);
			const witness = await cir.calculateWitness({ "a": asBits}, true);

			const expected = buffer2bits(Buffer.from((a%p).toString(16), 'hex').reverse());
			assert.ok(witness.slice(1, 255).every((u, i) => {
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