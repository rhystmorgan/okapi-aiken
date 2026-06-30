use aiken/collection/dict
use aiken/collection/list
use aiken/crypto.{ScriptHash}
use cardano/address.{Script}
use cardano/assets.{Value}
use cardano/transaction.{Datum, Output, OutputReference, Transaction}
use okapi/fast

//                                              //
// general operations and unallocated functions //
//                                              //

pub fn authTokenOutput(outs: List<Output>, script: ByteArray) -> (Value, Datum) {
  let cred = Script(script)
  let tokenOut =
    fast.mustFind(
      outs,
      fn(output) {
        output.address.payment_credential == cred && dict.has_key(
          assets.to_dict(output.value),
          script,
        )
      },
    )

  (assets.without_lovelace(tokenOut.value), tokenOut.datum)
}

pub fn hasSingleInput(tx: Transaction, oref: OutputReference) -> Bool {
  let input = fast.mustFindInput(tx.inputs, oref)

  let cred = input.output.address.payment_credential
  expect Script(_) = cred

  fast.onlyMatch(
    tx.inputs,
    fn(in) { in.output.address.payment_credential == cred },
  )
}

pub fn ownSingleOutput(tx: Transaction, oref: OutputReference) -> Output {
  let input = fast.mustFindInput(tx.inputs, oref)

  expect Script(script_hash) = input.output.address.payment_credential
  expect [out] =
    tx.outputs
      |> transaction.find_script_outputs(script_hash)

  out
}

pub fn validateScriptOutIx(
  script: ScriptHash,
  indices: List<Int>,
  outs: List<Output>,
  validateEach: fn(Output) -> Bool,
) -> Bool {
  let cred = Script(script)
  list.all(
    indices,
    fn(index) {
      expect Some(output) = list.at(outs, index)
      expect output.address.payment_credential == cred
      validateEach(output)
    },
  )
}

pub fn mapTokenPairOut(
  indices: List<Int>,
  outputs: List<Output>,
  validate: fn(Output, Output) -> Bool,
) -> Bool {
  list.all(
    indices,
    fn(index) {
      expect Some(aOut) = list.at(outputs, index)
      let aClean = assets.without_lovelace(aOut.value)
      let bOut =
        fast.mustFind(
          outputs,
          fn(output) {
            output.address.payment_credential != aOut.address.payment_credential && assets.without_lovelace(
              output.value,
            ) == aClean
          },
        )
      validate(aOut, bOut)
    },
  )
}

