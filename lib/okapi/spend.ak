use aiken/collection/list
use aiken/crypto.{ScriptHash}
use cardano/address.{Script}
use cardano/assets.{Value}
use cardano/transaction.{Datum, Input, Output, OutputReference}
use okapi/fast

//                     //
// spendingVal Helpers //
//                     //

pub fn getOrefInput(oref: OutputReference, inputs: List<Input>) -> Input {
  fast.mustFindInput(inputs, oref)
}

pub fn getOrefInputOut(oref: OutputReference, inputs: List<Input>) -> Output {
  let in = fast.mustFindInput(inputs, oref)

  in.output
}

pub fn getOrefScriptHash(
  oref: OutputReference,
  inputs: List<Input>,
) -> ScriptHash {
  let in = fast.mustFindInput(inputs, oref)

  expect Script(hash) = in.output.address.payment_credential

  hash
}

pub fn getOrefValue(oref: OutputReference, inputs: List<Input>) -> Value {
  let in = fast.mustFindInput(inputs, oref)

  in.output.value
}

pub fn getOrefDatumValue(
  oref: OutputReference,
  inputs: List<Input>,
) -> (Datum, Value) {
  let in = fast.mustFindInput(inputs, oref)

  (in.output.datum, in.output.value)
}

pub fn ownSpendIO(
  oref: OutputReference,
  inputs: List<Input>,
  outputs: List<Output>,
) -> (Input, Output) {
  let in = fast.mustFindInput(inputs, oref)

  let cred = in.output.address.payment_credential

  let ownInputs =
    list.filter(
      inputs,
      fn(input) {
        input.output.address.payment_credential == cred && input.output.address.stake_credential == None
      },
    )

  let ownOutputs =
    list.filter(
      outputs,
      fn(output) {
        output.address.payment_credential == cred && output.address.stake_credential == None
      },
    )

  expect [i] = ownInputs
  expect [o] = ownOutputs

  (i, o)
}

pub fn ownSingletonOutput(
  inputs: List<Input>,
  outputs: List<Output>,
  oref: OutputReference,
) -> Output {
  let input = fast.mustFindInput(inputs, oref)

  expect Script(script_hash) = input.output.address.payment_credential

  expect [output] =
    outputs
      |> transaction.find_script_outputs(script_hash)

  output
}

pub fn foldInValuesOut(ins: List<Input>, out: Output) -> (Value, Value) {
  let inValue =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  (assets.without_lovelace(inValue), assets.without_lovelace(out.value))
}

