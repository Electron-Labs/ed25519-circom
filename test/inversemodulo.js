const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");
const bigintModArith = require('bigint-mod-arith');

const wasm_tester = require("circom_tester").wasm;

describe("Inverse Modulo Test", () => {
	describe("when performing inverse modulo on a 104 bit number", () => {
    const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");
		it("should find the inverse", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "inversemodulo1.circom"));
			const a = BigInt("2820282019728792003956564819949");
			const buf1 = utils.bigIntToLEBuffer(a);
			const asBits1 = utils.buffer2bits(buf1);
			const witness = await cir.calculateWitness({ "in": asBits1}, true);

      inv = bigintModArith.modInv(a, p);
      const expected = utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(inv)), 255);
			
      for (var i=0; i< 255; i++) {
        console.log(witness[i+1], expected[i]);
      }
			assert.ok(witness.slice(1, 256).every((u, i) => {
				return u === expected[i];
			}));
		});
	});
});