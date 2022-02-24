const path = require('path');
const assert = require('assert');
const wasmTester = require('circom_tester').wasm;
const bigintModArith = require('bigint-mod-arith');
const utils = require('./utils');

describe("Inverse Modulo test for base51", () => {
    describe("When Performing inverse modulo on a 255 bit number", () => {
        const p = BigInt(2**255)-BigInt(19);
        it("Should calculate the inverse correctly", async() => {
            const cir = await wasmTester(path.join(__dirname,"circuits","modinv.circom"));
            const   a = BigInt(2**255)-BigInt(2**20);
            const chunk = utils.chunkBigInt(a);
            const witness = await cir.calculateWitness({ in:chunk }, true);
            const inv = bigintModArith.modInv(a, p);
            const expected = utils.chunkBigInt(inv);
            assert.ok(witness.slice(1 ,6).every((u ,i) => {
                return u === expected[i];
            }));
        });
    });
});