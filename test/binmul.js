const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");

const wasm_tester = require("circom_tester").wasm;

describe("Binary Multiplier Test", () => {
	describe("when performing binary multiplication on 104 bit and an 40 bit numbers", () => {
		it("should multiply them correctly", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "binmul1.circom"));
			const a = BigInt("2820282019728792003956564819949");
			const b = BigInt("956564819949");
			const buf1 = utils.bigIntToLEBuffer(a);
			const asBits1 = utils.buffer2bits(buf1);
			const buf2 = utils.bigIntToLEBuffer(b);
			const asBits2 = utils.buffer2bits(buf2);
			const witness = await cir.calculateWitness({ "in1": asBits1, "in2": asBits2}, true);

			const expected = utils.normalize(utils.buffer2bits(utils.bigIntToLEBuffer(a*b)));
			assert.ok(witness.slice(1, 145).every((u, i) => {
				return u === expected[i];
			}));
		});
	});
});

describe("Fast Binary Multiplier Test", () => {
	describe("when performing binary multiplication on 104 bit and an 40 bit numbers", () => {
		it("should multiply them correctly", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "binmulfast1.circom"));
			const a = BigInt("2820282019728792003956564819949");
			const b = BigInt("956564819949");
			const buf1 = utils.bigIntToLEBuffer(a);
			const asBits1 = utils.buffer2bits(buf1);
			const buf2 = utils.bigIntToLEBuffer(b);
			const asBits2 = utils.buffer2bits(buf2);
			const witness = await cir.calculateWitness({ "in1": asBits1, "in2": asBits2}, true);

			const expected = utils.normalize(utils.buffer2bits(utils.bigIntToLEBuffer(a*b)));
			assert.ok(witness.slice(1, 145).every((u, i) => {
				return u === expected[i];
			}));
		});
	});
});