const chai = require("chai");
const path = require("path");
const assert = require("assert");
const bigintModArith = require('bigint-mod-arith');
const utils = require('./utils');
const { performance } = require('perf_hooks');

const wasm_tester = require("circom_tester").wasm;
// const snarkjs = require("snarkjs");

describe("Modulus Test", () => {

	describe("when performing modular additon on two numbers using prime field of prime 25519", () => {
		const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");

		it("should add them correctly when sum is over global prime in circom", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "modulus0.circom"));
			const a = BigInt("107896044618658097711785492504343953926634992332820282019728792003956564819949");
			const buf = utils.bigIntToLEBuffer(a);
			const asBits = utils.buffer2bits(buf);
			const witness = await cir.calculateWitness({ "in": asBits}, true);

			const expected = utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(bigintModArith.modPow(a, 1, p))), 255);
			assert.ok(witness.slice(1, 256).every((u, i) => {
				return u === expected[i];
			}));
		});
	});

	describe("when performing modular additon on two numbers using prime field of prime 25519", () => {
		const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");

		it("should add them correctly when sum is over global prime in circom", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "modulus0.circom"));
			const a = BigInt("3953926634992332820282019728792003956564819949");
			const buf = utils.bigIntToLEBuffer(a);
			const asBits = utils.pad(utils.buffer2bits(buf), 256);
			const witness = await cir.calculateWitness({ "in": asBits}, true);

			const expected = utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(bigintModArith.modPow(a, 1, p))), 255);
			assert.ok(witness.slice(1, 256).every((u, i) => {
				return u === expected[i];
			}));
		});
	});

	describe("when performing modular additon on two numbers using prime field of prime 25519", () => {
		const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");

		it("should add them correctly when sum is over global prime in circom", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "modulus1.circom"));
			const a = BigInt("44618658097711785492504343953926634992332820282019728792003956564819949");
			const buf = utils.bigIntToLEBuffer(a);
			const asBits = utils.buffer2bits(buf);
			const witness = await cir.calculateWitness({ "a": asBits}, true);

			const expected = utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(bigintModArith.modPow(a, 1, p))), 255);
			assert.ok(witness.slice(1, 256).every((u, i) => {
				return u === expected[i];
			}));
		});
	});

	describe("when performing modular additon on two numbers using prime field of prime 25519", () => {
		const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");

		it("should add them correctly when sum is over global prime in circom", async () => {
			const cir = await wasm_tester(path.join(__dirname, "circuits", "modulus2.circom"));
			const a = BigInt("1257896044618658097711785492504343953926634992332820282019728792003956564819949");
			const buf = utils.bigIntToLEBuffer(a);
			const asBits = utils.buffer2bits(buf);
			// var startTime = performance.now();
			const witness = await cir.calculateWitness({ "a": asBits}, true);
			// var endTime = performance.now();
			// console.log(`Call to calculate witness took ${endTime - startTime} milliseconds`);

			const expected = utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(bigintModArith.modPow(a, 1, p))), 264);
			assert.ok(witness.slice(1, 255).every((u, i) => {
				return u === expected[i];
			}));
		});
	});

	describe("when performing modular additon on two numbers using prime field of prime 25519", () => {
		const p = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949");

		it("should add them correctly when sum is over global prime in circom",async () =>{
			const cir = await wasm_tester(path.join(__dirname,"circuits", "chunkedmodulus.circom"));
			// const a = BigInt("1257896044618658097711785492504343953926634992332820282019728792003956564819949")
			// const chunk = utils.chunkBigInt(a);
			const chunk = [2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247,
				2251799813685247];
			const witness = await cir.calculateWitness({"a":chunk},true);

			// const expected = utils.chunkBigInt(bigintModArith.modPow(a,1,p));
			const wt = witness.slice(1, 6);
			for(let i=0;i<5;i++){
				console.log(wt[i]);
			}
			const expected = [2251799813685247, 2251799813685247, 47045880,0,0];	
			assert.ok(witness.slice(1, 6).every((u, i)=>{
				return u === expected[i];
			}));
		});
	});
});
      