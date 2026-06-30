use aiken/collection/dict
use aiken/collection/list
use aiken/primitive/bytearray
use cardano/assets.{AssetName, PolicyId, Value}
use okapi/prefix.{fracTokenPrefix, refTokenPrefix, userTokenPrefix}

//                 //
// minting helpers //
//                 //

pub fn mintTokens(p: PolicyId, mint: Value) -> Pairs<AssetName, Int> {
  let tokens = mint |> assets.tokens(p) |> dict.to_pairs()
  tokens
}

pub fn mintToken(p: PolicyId, mint: Value) -> Pair<AssetName, Int> {
  expect [pair] = mint |> assets.tokens(p) |> dict.to_pairs()
  pair
}

pub fn mint222(p: PolicyId, n: ByteArray, mint: Value) -> (AssetName, AssetName) {
  expect [Pair(refName, refAmt),
    Pair(userName, userAmt)] = mint |> assets.tokens(p) |> dict.to_pairs()
  expect refName == bytearray.concat(refTokenPrefix, n)
  expect userName == bytearray.concat(userTokenPrefix, n)

  expect refAmt == 1
  expect userAmt == 1

  (refName, userName)
}

pub fn mint444(
  p: PolicyId,
  n: ByteArray,
  qty: Int,
  mint: Value,
) -> (AssetName, AssetName) {
  expect [Pair(refName, refAmt),
    Pair(fracName, fracAmt)] = mint |> assets.tokens(p) |> dict.to_pairs()
  expect refName == bytearray.concat(refTokenPrefix, n)
  expect fracName == bytearray.concat(fracTokenPrefix, n)

  expect refAmt == 1
  expect fracAmt == qty

  (refName, fracName)
}
