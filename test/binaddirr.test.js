const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");


const wasm_tester = require("circom_tester").wasm;




describe("Binary addition test for irregular  bits", ()=>{
	describe("when calculating addition of two binary array of non equal length for test 56 and 40 bits ", ()=>{
		it("should add them correctly", async()=>{
			const cir = await wasm_tester(path.join(__dirname,"circuits","binaddirr.circom"));
			const a = BigInt("1125899906842613");
			const b = BigInt("1099511627764");
			const buf1 = utils.bigIntToLEBuffer(a);
			const buf2 = utils.bigIntToLEBuffer(b);
			const bits1 = utils.buffer2bits(buf1);
			const bits2 = utils.buffer2bits(buf2);
			console.log(bits1.length, bits2.length);
			const witness = await cir.calculateWitness({"in1":bits1,"in2":bits2},true);

			const expected = utils.pad(utils.normalize(utils.buffer2bits(utils.bigIntToLEBuffer(a+b))), 57);
			assert.ok(witness.slice(1, 58).every((u, i)=>{
				return u === expected[i];
			}));
		});
	});
});