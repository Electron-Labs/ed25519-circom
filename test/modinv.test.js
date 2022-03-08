const path = require('path');
const assert = require('assert');
const wasmTester = require('circom_tester').wasm;
const bigintModArith = require('bigint-mod-arith');
const fc = require('fast-check');
const utils = require('./utils');

describe('Inverse Modulo test for base51', () => {
  describe('when Performing inverse modulo on a 255 bit number', () => {
    const p = BigInt(2 ** 255) - BigInt(19);
    it('Should calculate the inverse correctly', async () => {
      const cir = await wasmTester(path.join(__dirname, 'circuits', 'modinv.circom'));
      const a = BigInt(2 ** 255) - BigInt(20);
      const chunk = utils.chunkBigInt(a);
      const witness = await cir.calculateWitness({ in: chunk }, true);
      const inv = bigintModArith.modInv(a, p);
      const expected = utils.chunkBigInt(inv);
      assert.ok(witness.slice(1, 6).every((u, i) => u === expected[i]));
    });
  });
  describe('when calculating inverse modulo on field elements', () => {
    const p = BigInt(2 ** 255) - BigInt(19);

    it('Should calculate the inverse correctly', async () => {
      const cir = await wasmTester(path.join(__dirname, 'circuits', 'modinv.circom'));
      await fc.assert(
        fc.asyncProperty(fc.bigInt(1n, p - 1n), async (data) => {
          const witness = await cir.calculateWitness({ in: utils.chunkBigInt(data) }, true);
          const expected = utils.chunkBigInt(bigintModArith.modInv(data, p));
          witness.slice(1, 6).every((u, i) => u === expected[i]);
        }),
      );
    });
  });
});
