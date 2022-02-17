const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");

const wasm_tester = require("circom_tester").wasm; 

describe("base 51 addition test",()=>{
    describe("when performing chuncked addition on three 200 bits numbers",()=>{
        it("should add them correctly", async()=>{
            const cir = wasm_tester(path.join(__dirname,"circuits","chunkedadd.circom"));
            const a = BigInt(2**200)-BigInt(19);
            const b = BigInt(2**200)-BigInt(27);
            const c = BigInt(2**200)-BigInt(35);
            const chunk1 = utils.chunkBigInt(a);
            const chunk2 = utils.chunkBigInt(b);
            const chunk3 = utils.chunkBigInt(c);

            const witness = await (await cir).calculateWitness({"in":[chunk1,chunk2,chunk3]},true);
            const expected = utils.chunkBigInt(a+b+c);
            assert.ok(witness.slice(1,5).every((u, i)=>{
                return u === expected[i];
            }));
        });
    });
});