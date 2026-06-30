use aiken/fuzz
use aiken/primitive/bytearray
use cardano/assets
use cardano/transaction.{InlineDatum, NoDatum, Transaction, placeholder}
use okapi/general as g
use tests/utils.{TestDatum}
use tools/tools as v
use units/tx as t

test authTokenOut() {
  let p = #"0000"
  let n = #"1111"
  let i = 1

  let datum = TestDatum { a: #"1234", b: 1234 }

  let output =
    t.output(
      t.scriptAddress(p),
      assets.merge(v.minValue(), v.tokenValue(p, n, i)),
      InlineDatum(datum),
    )

  g.authTokenOutput([output], p) == (v.tokenValue(p, n, i), InlineDatum(datum))
}

test hasSingleInput() {
  let input =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum),
    )
  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum),
    )

  let tx = Transaction { ..placeholder, inputs: [input, in2] }

  g.hasSingleInput(tx, t.oref(#"0000", 1)) == True
}

test ownSingleOutput() {
  let oref = t.oref(#"0000", 1)

  let input =
    t.input(
      oref,
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum),
    )

  let out1 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out2 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)

  let tx = Transaction { ..placeholder, inputs: [input], outputs: [out1, out2] }

  g.ownSingleOutput(tx, oref) == out1
}

test validateScriptOutIx() {
  let script = #"0000"
  let indices = [0, 2]

  let out1 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out2 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)
  let out3 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out4 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)

  let outs = [out1, out2, out3, out4]

  g.validateScriptOutIx(script, indices, outs, fn(_out) { True }) == True
}

test mapTokenPairOut() {
  let indices = [0]

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum)
  let out2 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"2222"), v.tokenValue(#"00", "", 1), NoDatum)
  let out4 = t.output(t.scriptAddress(#"3333"), v.makeAdaValue(10), NoDatum)

  let outs = [out1, out2, out3, out4]

  g.mapTokenPairOut(indices, outs, fn(_a, _b) { True }) == True
}

test authTokenOutputProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let script = bytearray.from_int_big_endian(n1, 1)
  let policy = bytearray.from_int_big_endian(n2, 1)

  let datum = TestDatum { a: #"1234", b: 1234 }

  let output =
    t.output(
      t.scriptAddress(script),
      assets.merge(v.minValue(), v.tokenValue(policy, #"1111", 1)),
      InlineDatum(datum),
    )

  g.authTokenOutput([output], script) == (
    v.tokenValue(policy, #"1111", 1),
    InlineDatum(datum),
  )
}

test hasSingleInputProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (i1, i2) = pair
  let input =
    t.input(
      t.oref(#"0000", i1),
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum),
    )
  let in2 =
    t.input(
      t.oref(#"1111", 9),
      t.output(t.walletAddress(#"1111"), v.makeAdaValue(10), NoDatum),
    )

  let tx = Transaction { ..placeholder, inputs: [input, in2] }

  g.hasSingleInput(tx, t.oref(#"0000", i2)) == True
}

test ownSingleOutputProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let oref = t.oref(#"0000", 1)

  let input =
    t.input(
      oref,
      t.output(
        t.scriptAddress(bytearray.from_int_big_endian(n1, 1)),
        v.makeAdaValue(10),
        NoDatum,
      ),
    )

  let out1 =
    t.output(
      t.scriptAddress(bytearray.from_int_big_endian(n2, 1)),
      v.makeAdaValue(10),
      NoDatum,
    )
  let out2 = t.output(t.walletAddress(#"1111"), v.makeAdaValue(10), NoDatum)

  let tx = Transaction { ..placeholder, inputs: [input], outputs: [out1, out2] }

  g.ownSingleOutput(tx, oref) == out1
}

test validateScriptOutIxProp(index via fuzz.int_between(0, 2)) fail {
  let script = #"0000"

  let out1 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out2 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)
  let out3 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)

  let outs = [out1, out2, out3]

  g.validateScriptOutIx(script, [index], outs, fn(_out) { True }) == True
}

test mapTokenPairOutProp(
  pair via fuzz.both(fuzz.int_between(1, 10), fuzz.int_between(1, 10)),
) fail {
  let (q1, q2) = pair
  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", q1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", q2), NoDatum)

  let outs = [out1, out2]

  g.mapTokenPairOut([0], outs, fn(_a, _b) { True }) == True
}

test mapTokenPairOutPairs() {
  let indices = [0, 2]

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"11", "", 1), NoDatum)
  let out4 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"11", "", 1), NoDatum)

  let outs = [out1, out2, out3, out4]

  g.mapTokenPairOut(
    indices,
    outs,
    fn(a, b) { a.address.payment_credential != b.address.payment_credential },
  ) == True
}

test authTokenOutFail() fail {
  let p = #"0000"

  let datum = TestDatum { a: #"1234", b: 1234 }

  let output = t.output(t.scriptAddress(p), v.minValue(), InlineDatum(datum))

  g.authTokenOutput([output], p) == (v.minValue(), InlineDatum(datum))
}

test hasSingleInputFail() fail {
  let input =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum),
    )
  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum),
    )

  let tx = Transaction { ..placeholder, inputs: [input, in2] }

  g.hasSingleInput(tx, t.oref(#"0000", 1)) == True
}

test ownSingleOutputFail() fail {
  let oref = t.oref(#"0000", 1)

  let input =
    t.input(
      oref,
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum),
    )

  let out1 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out2 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)

  let tx = Transaction { ..placeholder, inputs: [input], outputs: [out1, out2] }

  g.ownSingleOutput(tx, oref) == out1
}

test validateScriptOutIxFail() fail {
  let script = #"0000"
  let indices = [0, 1]

  let out1 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out2 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)
  let out3 = t.output(t.scriptAddress(#"0000"), v.makeAdaValue(10), NoDatum)
  let out4 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)

  let outs = [out1, out2, out3, out4]

  g.validateScriptOutIx(script, indices, outs, fn(_out) { True }) == True
}

test mapTokenPairOutFail() fail {
  let indices = [0]

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum)
  let out2 = t.output(t.scriptAddress(#"1111"), v.makeAdaValue(10), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"2222"), v.tokenValue(#"11", "", 1), NoDatum)
  let out4 = t.output(t.scriptAddress(#"3333"), v.makeAdaValue(10), NoDatum)

  let outs = [out1, out2, out3, out4]

  g.mapTokenPairOut(indices, outs, fn(_a, _b) { True }) == True
}

