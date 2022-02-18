const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");

const wasm_tester = require("circom_tester").wasm;

describe("Point Addition test on ed25519", ()=>{
    describe("when performing point addition on the EC of 255 bits ",()=>{
        it("should add them correctly ", async() =>{
            const cir = await wasm_tester(path.join(__dirname,"circuits","point-addition51.circom"));
            const P = [15112221349535400772501151409588531511454012693041857206046113283949847762202n, 46316835694926478169428394003475163141307993866256225615783033603165251855960n, 1n, 46827403850823179245072216630277197565144205554125654976674165829533817101731n];
            const Q = [15112221349535400772501151409588531511454012693041857206046113283949847762202n, 46316835694926478169428394003475163141307993866256225615783033603165251855960n, 1n, 46827403850823179245072216630277197565144205554125654976674165829533817101731n];
            const p = BigInt(2**255)-BigInt(19);
            
            const chunk1 = [];
            const chunk2 = [];
            for(let i=0;i<4;i++){
                chunk1.push(utils.chunkBigInt(P[i]%p));
                chunk2.push(utils.chunkBigInt(Q[i]%p));
            }
            for(let i=0;i<4;i++){
                utils.pad(chunk1[i],5);
                utils.pad(chunk2[i],5);
            }            
        
            const witness = await cir.calculateWitness({"P":chunk1,"Q":chunk2},true);

            const res  = utils.point_add(P,Q);
            
            // for different convention of modulus 
            function modulus(num, p){
                return ((num%p)+p)%p;
            }
            const xp = [];
            for(let i=0;i<4;i++){
                let x = modulus(res[i],p);
                xp.push(utils.chunkBigInt(x)); 
            }

            const expected = [];
            for(let i=0;i<4;i++){
                for(let j=0;j<5;j++){
                    expected.push(xp[i][j]);
                }
            }
            
            const wt = witness.slice(1, 21);
            for(i=0;i<21;i++){
                console.log(wt[i]," ",expected[i]);
            }

          

            assert.ok(witness.slice(1, 21).every((u, i)=>{
                return u === expected[i];
            }));






        });
    });
}); 