// Input Output operations

// turns a list of inputs into their outputs in order
pub fn listInputOutputs(ins: List<Input>) -> List<Output> {
  let inputOutputs = list.map(ins, fn(in) { in.output })
  inputOutputs
}

pub fn listScriptIns(script: ScriptHash, ins: List<Input>) -> List<Input> {
  let scriptIns =
    list.filter(
      ins,
      fn(in) { in.output.address.payment_credential == Script(script) },
    )

  scriptIns
}

pub fn listScriptOuts(script: ScriptHash, outs: List<Output>) -> List<Output> {
  let scriptOuts =
    list.filter(
      outs,
      fn(out) { output.address.payment_credential == Script(script) },
    )

  scriptOuts
}

pub fn listScriptIO(
  script: ScriptHash,
  inputs: List<Input>,
  outputs: List<Output>,
) -> (List<Input>, List<Output>) {
  let inList =
    list.filter(
      inputs,
      fn(input) { input.output.address.payment_credential == script },
    )

  let outList =
    list.filter(
      outputs,
      fn(output) { output.address.payment_credential == script },
    )

  (inList, outList)
}

// sorts Ins and Outs into pairs by tokenValue and validates them together
pub fn checkTokenPairIO(
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
        expect Some(a) = list.at(outputs, index)
        expect a.address.payment_credential == Script(aHash)

        expect Some(b) =
          list.find(
            outputs,
            fn(output) {
              assets.without_lovelace(output.value) == assets.without_lovelace(
                a.value,
              ) && output.address.payment_credential == Script(bHash)
            },
          )
        (a, b)
      },
    )

  let inList =
    list.map(
      outList,
      fn(index) {
        expect (a, b) = index
        expect Some(aIn) =
          list.find(
            inputs,
            fn(input) {
              input.output.address.payment_credential == Script(aHash) && assets.without_lovelace(
                input.output.value,
              ) == assets.without_lovelace(a.value)
            },
          )

        expect Some(bIn) =
          list.find(
            inputs,
            fn(input) {
              input.output.address.payment_credential == Script(bHash) && assets.without_lovelace(
                input.output.value,
              ) == assets.without_lovelace(b.value)
            },
          )
        (aIn, bIn, a, b)
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
