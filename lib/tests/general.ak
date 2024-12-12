use cardano/assets
use cardano/transaction.{Datum, InlineDatum, NoDatum, Transaction, placeholder}
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

test hasSingleDatum() {
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

  g.validateScriptOutIx(script, indices, outs, fn(out) { True }) == True
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

  g.mapTokenPairOut(indices, outs, fn(a, b) { True }) == True
}

test mapTokenPairIO() {
  let indices = [0, 2]

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"11", "", 1), NoDatum),
    )

  let in4 =
    t.input(
      t.oref(#"0000", 4),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"11", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"11", "", 1), NoDatum)
  let out4 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"11", "", 1), NoDatum)

  let ins = [in1, in2, in3, in4]
  let outs = [out1, out2, out3, out4]

  g.mapTokenPairIO(
    indices,
    #"0000",
    #"1111",
    ins,
    outs,
    fn(aIn, bIn, aOut, bOut) { True },
  ) == True
}
