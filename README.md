# Circom Ed25519

<img src="https://github.com/Electron-Labs/circom-ed25519/actions/workflows/actions.yml/badge.svg?branch=master">

Curve operations and signature verification for Ed25519 digital signature scheme in circom 

**WARNING:** This is a research project. It has not been audited and may contain bugs and security flaws. This implementation is NOT ready for production use.

https://docs.electronlabs.org/circom-ed25519/overview


## Installing dependencies
- `npm install -g snarkjs`
- `npm install`
- Clone and install circom - [circom docs](https://docs.circom.io/getting-started/installation/)
- If you want to build the `verify` circuit, you'll need to download a Powers of Tau file with `2^22` constraints and copy it into the `circuits` subdirectory of the project, with the name `pot22_final.ptau`. You can download Powers of Tau files from the Hermez trusted setup from [this repository](https://github.com/iden3/snarkjs#7-prepare-phase-2)

## Testing the build
- You can run the entire testing suite (sans scalar multiplication and signature verification) using `npm run test`
- You can test specific long running tests using `npm run test-scalarmul` or `npm run test-verify`

## Important Circuits

### Modulus upto 2*(2^255-19) -> Mod2p
```python
  # for input in
  def mod2p(in):
    diff = (2**255-19) - in
    return in if diff < 0 else diff
```

```                                                                                
                              ╔══════════~s255══════════╗                 
                              ║                         ║                 
                              ║                         ║                 
                              ║                         ║                 
                              ║                         ▼                 
  ┌────────┐              ┌───╩────┐               ┌──────────┐           
  │        │              │        │               │          │           
  │        ╠═════p0══════▶│        ╠═════s0═══════▶│          │           
  │        │      ◦       │        │      ◦        │          ╠══out0════▶
  │        │      ◦       │   b    │      ◦        │          ╠══out1════▶
  │        ╠════p254═════▶│        ╠════s254══════▶│          │    ◦      
  │2^255-19│    ══0══════▶│        │               │   Mux2   │    ◦      
  │        │              │sub(a-b)│               │          │    ◦      
  │        │    ┌────────▶│        │      ┌───────▶│          ╠═out254═══▶
  │        │    │      ◦  │        │      │    ◦   │          │           
  │        │    │      ◦  │   a    │      │    ◦   │          │           
  │        │    │ ┌──────▶│        │      │  ┌────▶│          │           
  │        │    │ │  ┌───▶│        │      │  │     │          │           
  └────────┘    │ │  │    └────────┘      │  │     └──────────┘           
                │ │  │                    │  │                            
                │ │  │                    │  │                            
in0─────────────┴─┼──┼────────────────────┘  │                            
                  │  │                       │                            
in254─────────────┴──┼───────────────────────┘                            
in255────────────────┘ 
```                                                                                        

### Modulus with 2^255-19 -> Modulus25519
```python
  # for input `in` of unknown size, we explot that prime p
  # is close to a power of 2
  # input in broken down into an expression in = b + (p + 19)*c
  # where b is the least significant 255 bits of input and,
  # c is the rest of the bits. Then,
  # in mod p = (b + (p + 19)*c) mod p
  #          = (b mod p + 19*c mod p) mod p
  def mod25519(in):
    p = 2**255-19
    if in < p:
      return in
    b = in & ((1 << 255) - 1)
    c = in >> 255
    bmodp = mod2p(b)
    c19modp = mod25519(19*c)
    return mod2p(bmodp + c19modp)
```
```
                    ┌────────────┐
                    │            │
                    │            │
  ┌─────────┐       │   modulus  │        ┌─────────────────┐
  │ n wires ├──────▶│    25519   │───────▶│max(n, 255) wires│
  │(n < 255)│       │            │        │replicated input │
  └─────────┘       │            │        └─────────────────┘
                    └────────────┘
```

```
                            ┌───────────┐                                       
               ┌───────────▶│           ╠mod0═══╗                               
               │  ┌────────▶│           │.      ║                               
┌──────────┐   │  │         │   Mod2p   │.      ║                               
│          │   │  │         │           │.      ║                               
│          ├in0┘  │  ┌─────▶│           ╠mod254 ║                               
│          ├in1───┘  │      └───────────┘   ║   ║                               
│          │ .       │                      ║   ║                               
│          │ .       │                      ║   ║  ┌───────────┐    ┌─────────┐
│ n wires  ├in254────┘                      ║   ╚═▶│ a (n wire)│    │         │
│(n >= 255)│                                ╚═════▶│ b (n wire)│    │         │
│          │                                       │           ╠═══▶│  Mod2p  │
│          ├in255────┐                             │    Add    │    │         │
│          │ .       │                      ╔═════▶│           │    │         │
│          │ .       │                      ║   ╔═▶│ out (n+1) │    │         │
│          ├inN──┐   │      ┌───────────┐   ║   ║  └───────────┘    └─────────┘
│          │     │   └─────▶│ a (n wire)│   ║   ║                               
│          │     │          │ b (m wire)│   ║   ║                               
└──────────┘     └─────────▶│           │   ║   ║                               
┌──────────┐                │  Multiply │   ║   ║                               
│          ├const0─────────▶│           │   ║   ║                               
│   const  │ .      ┌──────▶│ out (m+n) │   ║   ║                               
│    19    │ .      │       └─╦──────╦──┘   ║   ║                               
│  5 wires ├const4──┘         ║......║      ║   ║                               
│          │                  ║      ║      ║   ║                               
└──────────┘                mult0 mult(m+n) ║   ║                               
                              ║      ║      ║   ║                               
                              ▼      ▼      ║   ║                               
                           ┌──────────────┐ ║   ║                               
                           │              ╠mod0 ║                               
                           │ Modulus25519 │.    ║                               
                           │  recursive   │.    ║                               
                           │   circuit    ╠mod254                               
                           └──────────────┘       
                           
```