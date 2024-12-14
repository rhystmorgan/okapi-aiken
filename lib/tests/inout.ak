use cardano/assets
use cardano/transaction.{Datum, InlineDatum, NoDatum, Transaction, placeholder}
use okapi/inout as i
use tools/tools as v
use units/tx as t

test listInputOutputs() {
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

  let ins = [in1, in2]

  i.listInputOutputs(ins) == [in1.output, in2.output]
}

test listScriptIns() {
  let script = #"0000"

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
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in4 =
    t.input(
      t.oref(#"0000", 4),
      t.output(t.scriptAddress(#"3333"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in5 =
    t.input(
      t.oref(#"0000", 5),
      t.output(t.scriptAddress(#"2222"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in6 =
    t.input(
      t.oref(#"0000", 10),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let ins = [in1, in2, in3, in4, in5, in6]

  i.listScriptIns(script, ins) == [in1, in3]
}

test listScriptOuts() {
  let script = #"0000"

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let outs = [out1, out2, out3]

  i.listScriptOuts(script, outs) == [out1, out3]
}
