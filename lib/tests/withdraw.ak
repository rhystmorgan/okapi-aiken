use aiken/fuzz
use cardano/transaction.{NoDatum}
use okapi/withdraw as w
use units/tx as x
use units/value as v

test mapOutputIndex() {
  let script = x.scriptAddress(#"0000")

  let out1 = x.output(script, v.adaValue(100), NoDatum)
  let out2 = x.output(x.walletAddress(#"1111"), v.adaValue(200), NoDatum)
  let out3 = x.output(script, v.adaValue(300), NoDatum)

  let outs = [out1, out2, out3]

  w.mapOutputIndex(outs, [0, 2], fn(out) { out.address == script })
}

test mapOutputIndexFail() fail {
  let script = x.scriptAddress(#"0000")

  let out1 = x.output(script, v.adaValue(100), NoDatum)
  let out2 = x.output(x.walletAddress(#"1111"), v.adaValue(200), NoDatum)
  let out3 = x.output(script, v.adaValue(300), NoDatum)

  let outs = [out1, out2, out3]

  w.mapOutputIndex(outs, [0, 1], fn(out) { out.address == script })
}

test mapOutputIndexProp(index via fuzz.int_between(0, 2)) fail {
  let script = x.scriptAddress(#"0000")

  let out1 = x.output(script, v.adaValue(100), NoDatum)
  let out2 = x.output(x.walletAddress(#"1111"), v.adaValue(200), NoDatum)
  let out3 = x.output(script, v.adaValue(300), NoDatum)

  let outs = [out1, out2, out3]

  w.mapOutputIndex(outs, [index], fn(out) { out.address == script })
}
