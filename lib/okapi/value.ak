use aiken/collection/dict
use aiken/collection/list
use cardano/assets.{PolicyId, Value}
use cardano/transaction.{Input, Output}

//                  //
// Value Operations //
//                  //

pub fn foldValuesIn(ins: List<Input>) -> Value {
  let value =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  value
}

pub fn foldAssetsIn(ins: List<Input>) -> Value {
  let value =
    list.foldl(
      ins,
      assets.zero,
      fn(in, acc) { assets.merge(in.output.value, acc) },
    )
  assets.without_lovelace(value)
}

pub fn foldPolicyIn(ins: List<Input>, policy: PolicyId) -> Value {
  let merged =
    list.foldl(
      ins,
      dict.empty,
      fn(in, acc) {
        dict.union_with(
          assets.tokens(in.output.value, policy),
          acc,
          fn(_k, a, b) { Some(a + b) },
        )
      },
    )
  if dict.is_empty(merged) {
    assets.zero
  } else {
    assets.from_asset_list([Pair(policy, dict.to_pairs(merged))])
  }
}

pub fn foldValuesOut(outs: List<Output>) -> Value {
  let value =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })
  value
}

pub fn foldAssetsOut(outs: List<Output>) -> Value {
  let value =
    list.foldl(outs, assets.zero, fn(out, acc) { assets.merge(out.value, acc) })
  assets.without_lovelace(value)
}

pub fn foldPolicyOut(outs: List<Output>, policy: PolicyId) -> Value {
  let merged =
    list.foldl(
      outs,
      dict.empty,
      fn(out, acc) {
        dict.union_with(
          assets.tokens(out.value, policy),
          acc,
          fn(_k, a, b) { Some(a + b) },
        )
      },
    )
  if dict.is_empty(merged) {
    assets.zero
  } else {
    assets.from_asset_list([Pair(policy, dict.to_pairs(merged))])
  }
}

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
