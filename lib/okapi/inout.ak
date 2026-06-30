use aiken/collection/dict
use aiken/collection/list
use aiken/crypto.{ScriptHash}
use cardano/address.{Script}
use cardano/assets.{PolicyId}
use cardano/transaction.{Input, Output}
use okapi/fast

//                         // 
// Input Output operations //
//                         //

pub fn listInputOutputs(ins: List<Input>) -> List<Output> {
  let inputOutputs = list.map(ins, fn(in) { in.output })
  inputOutputs
}

pub fn listScriptIns(script: ScriptHash, ins: List<Input>) -> List<Input> {
  let cred = Script(script)
  let scriptIns =
    list.filter(ins, fn(in) { in.output.address.payment_credential == cred })

  scriptIns
}

pub fn listScriptOuts(script: ScriptHash, outs: List<Output>) -> List<Output> {
  let cred = Script(script)
  let scriptOuts =
    list.filter(outs, fn(out) { out.address.payment_credential == cred })

  scriptOuts
}

pub fn listScriptIO(
  script: ScriptHash,
  inputs: List<Input>,
  outputs: List<Output>,
) -> (List<Input>, List<Output>) {
  let cred = Script(script)
  let inList =
    list.filter(
      inputs,
      fn(input) { input.output.address.payment_credential == cred },
    )

  let outList =
    list.filter(
      outputs,
      fn(output) { output.address.payment_credential == cred },
    )

  (inList, outList)
}

pub fn checkTokenPairIO(
  indices: List<Int>,
  aHash: ScriptHash,
  bHash: ScriptHash,
  inputs: List<Input>,
  outputs: List<Output>,
  validate: fn(Input, Input, Output, Output) -> Bool,
) -> Bool {
  let aCred = Script(aHash)
  let bCred = Script(bHash)
  list.all(
    indices,
    fn(index) {
      expect Some(a) = list.at(outputs, index)
      expect a.address.payment_credential == aCred

      let aClean = assets.without_lovelace(a.value)
      let b =
        fast.mustFind(
          outputs,
          fn(output) {
            output.address.payment_credential == bCred && assets.without_lovelace(
              output.value,
            ) == aClean
          },
        )
      let bClean = assets.without_lovelace(b.value)

      let aIn =
        fast.mustFind(
          inputs,
          fn(input) {
            input.output.address.payment_credential == aCred && assets.without_lovelace(
              input.output.value,
            ) == aClean
          },
        )

      let bIn =
        fast.mustFind(
          inputs,
          fn(input) {
            input.output.address.payment_credential == bCred && assets.without_lovelace(
              input.output.value,
            ) == bClean
          },
        )
      validate(aIn, bIn, a, b)
    },
  )
}

pub fn getPolicyIO(
  ins: List<Input>,
  outs: List<Output>,
  policy: PolicyId,
) -> List<(Input, Output)> {
  let inList =
    list.filter(
      ins,
      fn(in) { dict.has_key(assets.to_dict(in.output.value), policy) },
    )
  let outList =
    list.filter(
      outs,
      fn(out) { dict.has_key(assets.to_dict(out.value), policy) },
    )
  let ioList =
    list.map(
      inList,
      fn(in) {
        let inAssets = in.output.value |> assets.tokens(policy)

        let out =
          fast.mustFind(
            outList,
            fn(out) { assets.tokens(out.value, policy) == inAssets },
          )
        (in, out)
      },
    )

  ioList
}
