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
  tokens
  [0]
}
