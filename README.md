# Circom Ed25519

<img src="https://github.com/Electron-Labs/circom-ed25519/actions/workflows/actions.yml/badge.svg?branch=master">

Curve operations and signature verification for Ed25519 digital signature scheme in circom 

**WARNING:** This is a research project. It has not been audited and may contain bugs and security flaws. This implementation is NOT ready for production use.

https://docs.electronlabs.org/circom-ed25519/overview

The circuits follow the reference implementation from [IETF RFC8032](https://datatracker.ietf.org/doc/html/rfc8032#section-6)


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

### Point Addition -> PointAdd
```python
  # Add two points on Curve25519
  def point_add(P, Q):
    p = 2**255-19
    A, B = (P[1]-P[0]) * (Q[1]-Q[0]) % p, (P[1]+P[0]) * (Q[1]+Q[0]) % p
    C, D = 2 * P[3] * Q[3] * d % p, 2 * P[2] * Q[2] % p
    E, F, G, H = B-A, D-C, D+C, B+A
    return (E*F, G*H, F*G, E*H)
```

### Scalar Multiplication -> ScalarMul
```python
  # Multiply a point by scalar on Curve25519
  def point_mul(s, P):
    p = 2**255-19
    Q = (0, 1, 1, 0)  # Neutral element
    while s > 0:
      if s & 1:
        Q = point_add(Q, P)
      P = point_add(P, P)
      s >>= 1
    return Q
```

### Ed25519 Signature verification -> Verify
```python
  def verify(msg, public, Rs, s, A, R):
    # Check that the compressed representation of a point 
    # equates to the paramaters extracted from signature
    assert(Rs == point_compress(R))
    assert(public == point_compress(A))
    h = sha512_modq(Rs + public + msg)
    sB = point_mul(s, G)
    hA = point_mul(h, A)
    return point_equal(sB, point_add(R, hA))
```