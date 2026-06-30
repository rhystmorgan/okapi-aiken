use aiken/fuzz
use aiken/primitive/bytearray
use cardano/assets
use cardano/transaction.{InlineDatum, NoDatum}
use okapi/spend as s
use units/tx as x
use units/value as v

test getOrefInput() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  s.getOrefInput(oref, ins) == in1
}

test getOrefInputOut() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]
  s.getOrefInputOut(oref, ins) == in1.output
}

test getOrefScriptHash() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]
  s.getOrefScriptHash(oref, ins) == #"0000"
}

test getOrefValue() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  s.getOrefValue(oref, ins) == in1.output.value
}

test getOrefDatumValue() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(
      oref,
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), InlineDatum(#"0000")),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  s.getOrefDatumValue(oref, ins) == (in1.output.datum, in1.output.value)
}

test ownSpendIO() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let out1 = x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum)
  let out2 =
    x.output(
      x.walletAddress(#"1111"),
      v.makeAsset((#"9999", #"11", 3)),
      NoDatum,
    )

  s.ownSpendIO(oref, [in1, in2], [out1, out2]) == (in1, out1)
}

test ownSingletonOutput() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let out1 = x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum)
  let out2 =
    x.output(
      x.walletAddress(#"1111"),
      v.makeAsset((#"9999", #"11", 3)),
      NoDatum,
    )

  s.ownSingletonOutput([in1, in2], [out1, out2], oref) == out1
}

test foldInValuesOut() {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(
        x.scriptAddress(#"0000"),
        assets.merge(v.adaValue(100), v.makeAsset((#"9999", #"11", 1))),
        NoDatum,
      ),
    )

  let in2 =
    x.input(
      x.oref(#"0000", 2),
      x.output(
        x.scriptAddress(#"0000"),
        assets.merge(v.adaValue(50), v.makeAsset((#"9999", #"22", 2))),
        NoDatum,
      ),
    )

  let out =
    x.output(
      x.scriptAddress(#"0000"),
      assets.merge(
        v.adaValue(150),
        v.mergeValueList([(#"9999", #"11", 1), (#"9999", #"22", 2)]),
      ),
      NoDatum,
    )

  let tokens = v.mergeValueList([(#"9999", #"11", 1), (#"9999", #"22", 2)])

  s.foldInValuesOut([in1, in2], out) == (tokens, tokens)
}

test getOrefInputProp(
  pair via fuzz.both(
    fuzz.int(), 
    fuzz.int()
  )
) fail {
  let (i1, i2) = pair
  let in1 =
    x.input(
      x.oref(#"0000", i1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  s.getOrefInput(x.oref(#"0000", i2), [in1]) == in1
}

test getOrefInputOutProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (i1, i2) = pair
  let in1 =
    x.input(
      x.oref(#"0000", i1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  s.getOrefInputOut(x.oref(#"0000", i2), [in1]) == in1.output
}

test getOrefScriptHashProp(
  pair via fuzz.both(
    fuzz.int_between(0, 10), 
    fuzz.int_between(0, 10)
  ),
) fail {
  let (n1, n2) = pair
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(
      oref,
      x.output(
        x.scriptAddress(bytearray.from_int_big_endian(n1, 1)),
        v.adaValue(100),
        NoDatum,
      ),
    )

  s.getOrefScriptHash(oref, [in1]) == bytearray.from_int_big_endian(n2, 1)
}

test getOrefValueProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (a1, a2) = pair
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(
      oref,
      x.output(x.scriptAddress(#"0000"), v.adaValue(a1), NoDatum),
    )

  s.getOrefValue(oref, [in1]) == v.adaValue(a2)
}

test getOrefDatumValueProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (a1, a2) = pair
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(
      oref,
      x.output(x.scriptAddress(#"0000"), v.adaValue(a1), InlineDatum(#"0000")),
    )

  s.getOrefDatumValue(oref, [in1]) == (InlineDatum(#"0000"), v.adaValue(a2))
}

test ownSpendIOProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(
      oref,
      x.output(
        x.scriptAddress(bytearray.from_int_big_endian(n1, 1)),
        v.adaValue(100),
        NoDatum,
      ),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(x.walletAddress(#"1111"), v.adaValue(50), NoDatum),
    )

  let out1 =
    x.output(
      x.scriptAddress(bytearray.from_int_big_endian(n2, 1)),
      v.adaValue(100),
      NoDatum,
    )
  let out2 = x.output(x.walletAddress(#"1111"), v.adaValue(50), NoDatum)

  s.ownSpendIO(oref, [in1, in2], [out1, out2]) == (in1, out1)
}

test ownSingletonOutputProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(
      oref,
      x.output(
        x.scriptAddress(bytearray.from_int_big_endian(n1, 1)),
        v.adaValue(100),
        NoDatum,
      ),
    )

  let out1 =
    x.output(
      x.scriptAddress(bytearray.from_int_big_endian(n2, 1)),
      v.adaValue(100),
      NoDatum,
    )
  let out2 = x.output(x.walletAddress(#"1111"), v.adaValue(50), NoDatum)

  s.ownSingletonOutput([in1], [out1, out2], oref) == out1
}

test foldInValuesOutProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(
        x.scriptAddress(#"0000"),
        assets.merge(v.adaValue(100), v.makeAsset((#"9999", #"11", q1))),
        NoDatum,
      ),
    )

  let in2 =
    x.input(
      x.oref(#"0000", 2),
      x.output(
        x.scriptAddress(#"0000"),
        assets.merge(v.adaValue(50), v.makeAsset((#"9999", #"11", q2))),
        NoDatum,
      ),
    )

  let out =
    x.output(
      x.scriptAddress(#"0000"),
      assets.merge(v.adaValue(150), v.makeAsset((#"9999", #"11", q3))),
      NoDatum,
    )

  let (inTokens, outTokens) = s.foldInValuesOut([in1, in2], out)

  inTokens == outTokens
}

test getOrefInputFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  s.getOrefInput(x.oref(#"2222", 3), ins) == in1
}

test getOrefInputOutFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]
  s.getOrefInputOut(x.oref(#"2222", 3), ins) == in1.output
}

test getOrefScriptHashFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]
  s.getOrefScriptHash(x.oref(#"1111", 2), ins) == #"1111"
}

test getOrefValueFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  s.getOrefValue(x.oref(#"2222", 3), ins) == in1.output.value
}

test getOrefDatumValueFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), InlineDatum(#"0000")),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  s.getOrefDatumValue(x.oref(#"2222", 3), ins) == (
    in1.output.datum,
    in1.output.value,
  )
}

test ownSpendIOFail() fail {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"0000", 2),
      x.output(x.scriptAddress(#"0000"), v.adaValue(50), NoDatum),
    )

  let out1 = x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum)
  let out2 =
    x.output(
      x.walletAddress(#"1111"),
      v.makeAsset((#"9999", #"11", 3)),
      NoDatum,
    )

  s.ownSpendIO(oref, [in1, in2], [out1, out2]) == (in1, out1)
}

test ownSingletonOutputFail() fail {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(
        x.walletAddress(#"1111"),
        v.makeAsset((#"9999", #"11", 3)),
        NoDatum,
      ),
    )

  let out1 = x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum)
  let out2 = x.output(x.scriptAddress(#"0000"), v.adaValue(50), NoDatum)

  s.ownSingletonOutput([in1, in2], [out1, out2], oref) == out1
}

test foldInValuesOutFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(
        x.scriptAddress(#"0000"),
        assets.merge(v.adaValue(100), v.makeAsset((#"9999", #"11", 1))),
        NoDatum,
      ),
    )

  let in2 =
    x.input(
      x.oref(#"0000", 2),
      x.output(
        x.scriptAddress(#"0000"),
        assets.merge(v.adaValue(50), v.makeAsset((#"9999", #"22", 2))),
        NoDatum,
      ),
    )

  let out =
    x.output(
      x.scriptAddress(#"0000"),
      assets.merge(v.adaValue(150), v.makeAsset((#"9999", #"11", 1))),
      NoDatum,
    )

  let tokens = v.mergeValueList([(#"9999", #"11", 1), (#"9999", #"22", 2)])

  s.foldInValuesOut([in1, in2], out) == (tokens, tokens)
}
