// general operations and unallocated functions

// returns (authValue, authDatum) or errors
pub fn authTokenOutput(outs: List<Output>, script: ByteArray) -> (Value, Datum) {
  expect Some(tokenOut) =
    list.find(
      outs,
      fn(output) {
        output.address.payment_credential == Script(script) && list.has(
          assets.policies(output.value),
          script,
        )
      },
    )

  (assets.without_lovelace(tokenOut.value), tokenOut.datum)
}

// checks for only one validator input
pub fn hasSingleInput(tx: Transaction, oref: OutputReference) -> Bool {
  expect Some(input) =
    tx.inputs
      |> find_input(oref)

  expect Script(script_hash) = input.output.address.payment_credential

  list.length(
    list.filter(
      tx.inputs,
      fn(input) {
        input.output.address.payment_credential == Script(script_hash)
      },
    ),
  ) == 1
}

// checks for single validator Output and returns it
pub fn ownSingleOutput(tx: Transaction, oref: OutputReference) -> Output {
  expect Some(input) =
    tx.inputs
      |> find_input(oref)

  expect Script(script_hash) = input.output.address.payment_credential
  let script_outputs =
    tx.outputs
      |> find_script_outputs(script_hash)

  expect list.length(script_outputs) == 1
  list.head(script_outputs)
}

pub fn validateScriptOutIx(
  script: ScriptHash,
  indices: List<Int>,
  outs: List<Output>,
  validateEach: fn(Output) -> Bool,
) -> Bool {
  let txList =
    list.map(
      indices,
      fn(index) {
        expect Some(output) = list.at(outputs, index)
        expect output.address.payment_credential == script
        output
      },
    )

  list.all(txList, fn(output) { validateEach(output) })
}

pub fn mapTokenPairOut(
  indices: List<Int>,
  outputs: List<Output>,
  validate: fn(Output, Output) -> Bool,
) -> Bool {
  let txList =
    list.map(
      indices,
      fn(index) {
        let l = index
        expect Some(aOut) = list.at(outputs, l)
        expect Some(bOut) =
          list.find(
            outputs,
            fn(output) {
              assets.without_lovelace(output.value) == assets.without_lovelace(
                aOut.value,
              ) && output.address.payment_credential != aOut.address.payment_credential
            },
          )
        (aOut, bOut)
      },
    )

  list.all(
    txList,
    fn(pair) {
      let (aOut, bOut) = pair
      validate(aOut, bOut)
    },
  )
}

// sorts Ins and Outs into pairs by tokenValue and validates them together
pub fn mapTokenPairIO(
  indices: List<Int>,
  aHash: ScriptHash,
  bHash: ScriptHash,
  inputs: List<Input>,
  outputs: List<Output>,
  validate: fn(Input, Input, Output, Output) -> Bool,
) -> Bool {
  let outList =
    list.map(
      indices,
      fn(index) {
        let l = index
        expect Some(aOut) = list.at(outputs, l)
        expect aOut.address.payment_credential == Script(aHash)

        expect Some(bOut) =
          list.find(
            outputs,
            fn(output) {
              assets.without_lovelace(output.value) == assets.without_lovelace(
                aOut.value,
              ) && output.address.payment_credential == Script(bHash)
            },
          )
        (aOut, bOut)
      },
    )

  let inList =
    list.map(
      outList,
      fn(index) {
        expect (aOut, bOut) = index
        expect Some(aIn) =
          list.find(
            inputs,
            fn(input) {
              input.output.address.payment_credential == Script(aHash) && assets.without_lovelace(
                input.output.value,
              ) == assets.without_lovelace(aOut.value)
            },
          )

        expect Some(bIn) =
          list.find(
            inputs,
            fn(input) {
              input.output.address.payment_credential == Script(bHash) && assets.without_lovelace(
                input.output.value,
              ) == assets.without_lovelace(bOut.value)
            },
          )
        (aIn, bIn, aOut, bOut)
      },
    )

  list.all(
    inList,
    fn(pair) {
      let (aIn, bIn, aOut, bOut) = pair
      validate(aIn, bIn, aOut, bOut)
    },
  )
}
