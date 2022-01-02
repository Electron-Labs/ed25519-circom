circom main.circom --r1cs --wasm --sym --c

node app.js

cd main_js

node generate_witness.js main.wasm input.json witness.wtns

snarkjs wej witness.wtns witness.json

cd ..