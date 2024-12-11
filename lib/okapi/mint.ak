use aiken/collection/dict
use aiken/collection/list
use aiken/collection/pairs
use aiken/primitive/bytearray
use cardano/assets.{AssetName, PolicyId, Value}
use okapi/prefix.{fracTokenPrefix, refTokenPrefix, userTokenPrefix}

// mintingVal helpers

// Cip68 Minting

// Cip Validator Distributions ( outputs )

// 68 TokenPrefix functions

// 68 TokenPrefix Compare

// 68 TokenPrefix Datums

// Token Prefix IOs

pub fn mintTokens(p: PolicyId, mint: Value) -> Pairs<AssetName, Int> {
  let tokens = mint |> assets.tokens(p) |> dict.to_pairs()
  tokens
}

pub fn mintToken(p: PolicyId, mint: Value) -> Pair<AssetName, Int> {
  let tokens = mint |> assets.tokens(p) |> dict.to_pairs()
  expect list.length(tokens) == 1
  expect Some(pair) = list.at(tokens, 0)
  pair
}

// check MintQty && TokenNames returns TokenNames
pub fn mint222(p: PolicyId, n: ByteArray, mint: Value) -> (AssetName, AssetName) {
  expect [Pair(refName, refAmt),
    Pair(userName, userAmt)] = mint |> assets.tokens(p) |> dict.to_pairs()
  expect refName == bytearray.concat(refTokenPrefix, n)
  expect userName == bytearray.concat(userTokenPrefix, n)

  expect refAmt == 1
  expect userAmt == 1

  (refName, userName)
}

// check MintQty && TokenNames returns TokenNames
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
// make referenceTokenName from

// make userTokenName from

// make fractionalTokenName from
