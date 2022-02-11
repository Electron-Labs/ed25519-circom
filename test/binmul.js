const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");

const wasm_tester = require("circom_tester").wasm;
const { wasm } = require("circom_tester");

describe("Binary Multiplier Test", () => {
	describe("when performing binary multiplication on 104 bit and an 40 bit numbers", () => {
		it("should multiply them correctly", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "binmul1.circom"));
			const a = BigInt("282028201972879200395656481949");
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

describe(" Fast Binary multiplication chuncked 51 test", () =>{
	describe("When Performing binary multiplication on 4 by 4 numbers chunked by 51 bits", () => {
		it("should multiply them correctly", async ()=> {
			const cir = await wasm_tester(path.join(__dirname,"circuits","binmulfast51.circom"));
			const a = BigInt(2**200-10);
			const b = BigInt(2**203-10);
			const chunk1 = utils.chunkBigInt(a);
			const chunk2 = utils.chunkBigInt(b);
			const witness = await cir.calculateWitness({"in1": chunk1, "in2":chunk2});
			console.log(witness);
			const expected = utils.chunkBigInt(a*b);
			assert.ok(witness.slice(1, 9).every((u,i) => {
				return u === expected[i];
			}));

		});
	});
});

describe("Check bits less then 51",()=>{
	describe("when a number is passed into it of 52 bits",() =>{
		it("should give 0 if it is not less then 51 bits else give 1", async ()=>{
			const cir = await wasm_tester(path.join(__dirname,"circuits","binmullessthen51.circom"));
			const witness = await cir.calculateWitness({"in": 4503599627370490});
				
			assert.ok(witness.slice(1, 1).every((u)=>{
				return u = 0;
			}));
		});
	});
});