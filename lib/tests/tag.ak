use aiken/collection/list
use cardano/assets
use cardano/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
}
use okapi/tag
use tools/tools as v
use units/tx as t

test taggedOuts() {
  let oref1 = t.oref(#"cafe", 1)
  let oref2 = t.oref(#"cafe", 2)

  let out1 =
    t.output(
      t.walletAddress(#"face"),
      assets.from_lovelace(1000),
      InlineDatum(oref1),
    )

  let out2 =
    t.output(
      t.walletAddress(#"face"),
      assets.from_lovelace(1000),
      InlineDatum(oref2),
    )

  let out3 =
    t.output(t.walletAddress(#"face"), assets.from_lovelace(1000), NoDatum)

  let outputs = [out1, out2, out3]

  tag.taggedOutput(outputs, oref1) == out1
}

test checkTaggedList() {
  let oref1 = t.oref(#"0000", 1)
  let oref2 = t.oref(#"0000", 2)
  let oref3 = t.oref(#"0000", 3)

  let in1 =
    t.input(
      oref1,
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      oref2,
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      oref3,
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      v.tokenValue(#"22", "", 1),
      InlineDatum(oref1),
    )
  let out2 =
    t.output(
      t.scriptAddress(#"1111"),
      v.tokenValue(#"00", "", 1),
      InlineDatum(oref2),
    )
  let out3 =
    t.output(
      t.scriptAddress(#"0000"),
      v.tokenValue(#"99", "", 1),
      InlineDatum(oref3),
    )

  tag.checkTaggedList(
    [in1, in2, in3],
    [out1, out2, out3],
    [1, 2, 0],
    fn(input, output) { input.output.value == output.value },
  )
}
