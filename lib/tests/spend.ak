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
// // returns non-staking single validator (input, output)
// test ownSpendIO() {
//   s.ownSpendIO(oref, ins, outs) == (in, out)
// }

// // Checks for one `own Validator` output and returns it
// test ownSingletonOutput() {
//   s.ownSingletonOutput(ins, outs, oref) == out
// }

// test foldInValuesOut() {
//   s.foldInValuesOut(ins, outs) == (inValue, outValue)
// }
