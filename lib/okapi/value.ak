use aiken/collection/list
use cardano/assets.{PolicyId, Value}
use cardano/transaction.{Input, Output}

// fold input values into 1 value
pub fn foldValuesIn(ins: List<Input>) -> Value {
  let value =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  value
}

// returns combined input value without lovelace
pub fn foldAssetsIn(ins: List<Input>) -> Value {
  let value =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  assets.without_lovelace(value)
}

// returns a combined input value of a single policyId
pub fn foldPolicyIn(ins: List<Input>, policy: PolicyId) -> Value {
  let value =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  assets.restricted_to(value, [policy])
}

// fold output values into 1 value
pub fn foldValuesOut(outs: List<Output>) -> Value {
  let value =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })
  value
}

// returns combined output value without lovelace
pub fn foldAssetsOut(outs: List<Output>) -> Value {
  let value =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })
  assets.without_lovelace(value)
}

// returns a combined output value of a single policyId
pub fn foldPolicyOut(outs: List<Output>, policy: PolicyId) -> Value {
  let value =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })
  assets.restricted_to(value, [policy])
}

// get the difference in values where inputs < outputs
pub fn negateInValueOut(ins: List<Input>, outs: List<Output>) -> Value {
  let inValue =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  let outValue =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })

  assets.merge(assets.negate(inValue), outValue)
}

// get the difference in values where inputs > outputs
pub fn negateOutValueIn(ins: List<Input>, outs: List<Output>) -> Value {
  let inValue =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  let outValue =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })

  assets.merge(assets.negate(outValue), inValue)
}
