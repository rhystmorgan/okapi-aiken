use aiken/collection/list
use aiken/crypto.{ScriptHash}
use cardano/address.{Script}
use cardano/assets.{Value}
use cardano/transaction.{Datum, Input, Output, OutputReference}

// spendingVal Helpers

// get input data from oref

pub fn getOrefInput(oref: OutputReference, inputs: List<Input>) -> Input {
  expect Some(in) =
    list.find(inputs, fn(input) { input.output_reference == oref })

  in
}

pub fn getOrefInputOut(oref: OutputReference, inputs: List<Input>) -> Output {
  expect Some(in) =
    list.find(inputs, fn(input) { input.output_reference == oref })

  in.output
}

pub fn getOrefScriptHash(
  oref: OutputReference,
  inputs: List<Input>,
) -> ScriptHash {
  expect Some(in) =
    list.find(inputs, fn(input) { input.output_reference == oref })

  expect Script(hash) = in.output.address.payment_credential

  hash
}

pub fn getOrefValue(oref: OutputReference, inputs: List<Input>) -> Value {
  expect Some(in) =
    list.find(inputs, fn(input) { input.output_reference == oref })

  in.output.value
}

pub fn getOrefDatumValue(
  oref: OutputReference,
  inputs: List<Input>,
) -> (Datum, Value) {
  expect Some(in) =
    list.find(inputs, fn(input) { input.output_reference == oref })

  (in.output.datum, in.output.value)
}

// returns non-staking single validator (input, output)
pub fn ownSpendIO(
  oref: OutputReference,
  inputs: List<Input>,
  outputs: List<Output>,
) -> (Input, Output) {
  expect Some(in) = inputs |> transaction.find_input(oref)

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

  expect list.length(ownInputs) == 1
  expect list.length(ownOutputs) == 1

  expect Some(i) = list.head(ownInputs)
  expect Some(o) = list.head(ownOutputs)

  (i, o)
}

// Checks for one `own Validator` output and returns it
pub fn ownSingletonOutput(
  inputs: List<Input>,
  outputs: List<Output>,
  oref: OutputReference,
) -> Output {
  expect Some(input) =
    inputs
      |> transaction.find_input(oref)

  expect Script(script_hash) = input.output.address.payment_credential

  let script_outputs =
    outputs
      |> transaction.find_script_outputs(script_hash)

  expect list.length(script_outputs) == 1

  expect Some(output) =
    outputs
      |> transaction.find_script_outputs(script_hash)
      |> list.head()

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

