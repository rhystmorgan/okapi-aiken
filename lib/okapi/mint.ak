// mintingVal helpers

// Cip68 Minting

// Cip Validator Distributions ( outputs )

// 68 TokenPrefix functions

// 68 TokenPrefix Compare

// 68 TokenPrefix Datums

// Token Prefix IOs

pub fn mintTokens(p: PolicyId, mint: Value) -> Pairs {
  expect Some(tokens) = mint |> asset.tokens(p) |> dict.to_pairs()
  tokens
}

pub fn mintToken(p: PolicyId, mint: Value) -> Pair {
  let tokens = mint |> asset.tokens(p) |> dict.to_pairs()
  expect list.length(tokens) == 1
  index_of(tokens, 0)
}

// check MintQty && TokenNames returns TokenNames
pub fn mint222(p: PolicyId, n: ByteArray, mint: Value) -> (AssetName, AssetName) {
  expect [Pair(refName, refAmt),
    Pair(userName, userAmt)] = mint |> assets.tokens(p) |> dict.to_pairs()
  expect refName == bytearray.concat(refPrefix, n)
  expect userName == bytearray.concat(userPrefix, n)

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
  expect refName == bytearray.concat(refPrefix, n)
  expect fracName == bytearray.concat(userPrefix, n)

  expect refAmt == 1
  expect fracAmt == qty

  (refName, fracName)
}
// make referenceTokenName from

// make userTokenName from

// make fractionalTokenName from
