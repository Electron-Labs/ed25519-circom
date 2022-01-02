# circom-binary-ops
circom bitifier, binary adder, binary multiplier

Tested on MacOS. To run,
1. Specify your inputs in `app.js`. It will automatically create `input.json` for you.
2. Type `sh run.sh` in the command line
3. Check results inside `witness.json`

Note:-
1. Adder tested upto `512 bits` (signal size).
2. Multiplier only runs upto `128 bits`. At `256 bits`, we get the following error -
```
(node:3133) UnhandledPromiseRejectionWarning: CompileError: WebAssembly.compile(): initial memory size (47034 pages) is larger than implementation limit (32767) @+299
```
I am working on a fix.
