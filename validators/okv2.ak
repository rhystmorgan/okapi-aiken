use cardano/transaction.{OutputReference, Transaction, NoDatum, placeholder}
// okapi modules
use okapi/spend as ok
use tools/tools as v
use units/tx as t

// Spend Validator that maintains total value state in utxos
validator okV2() {
  spend(_d: Option<Data>, _r: Data, oref: OutputReference, tx: Transaction) {
    let (in, out) = 
      ok.ownSpendIO(
        oref, 
        tx.inputs, 
        tx.outputs
      )

    in.output.value == out.value
  }
}

//      //
// TEST //
//      //

test okv2_ada() {
  let ownHash = #"0000"
  let oref = t.oref(#"1111", 1)
  let value = v.makeAdaValue(100)
  let script = t.scriptAddress(ownHash)

  let in = t.input(
    oref,
    t.output(
      script,
      value,
      NoDatum,
    )
  )

  let out = t.output(
    script,
    value,
    NoDatum,
  )

  let tx = Transaction {
    ..placeholder,
    inputs: [in],
    outputs: [out],
  }

  okV2.spend(
    None,
    0,
    oref,
    tx
  )
}

test okv2_token() {
  let ownHash = #"0000"
  let oref = t.oref(#"1111", 1)
  let value = v.singletonTxValue(#"aaaa", #"bbbb")
  let script = t.scriptAddress(ownHash)

  let in = t.input(
    oref,
    t.output(
      script,
      value,
      NoDatum,
    )
  )

  let out = t.output(
    script,
    value,
    NoDatum,
  )

  let tx = Transaction {
    ..placeholder,
    inputs: [in],
    outputs: [out],
  }

  okV2.spend(
    None,
    0,
    oref,
    tx
  )
}


