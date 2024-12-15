use aiken/primitive/bytearray
use cardano/assets
use okapi/mint as m
use okapi/prefix as p

//            //
// mint utils //
//            //

test mintTokens() {
  let policy = #"0000"
  let name = #"1111"
  let qty = 2
  let mint = assets.from_asset(policy, name, qty)

  m.mintTokens(policy, mint) == [Pair(name, qty)]
}

test mintToken() {
  let policy = #"0000"
  let name = #"1111"
  let qty = 2
  let mint = assets.from_asset(policy, name, qty)

  m.mintToken(policy, mint) == Pair(name, qty)
}

// check MintQty && TokenNames returns TokenNames
test mint222() {
  let policy = #"0000"
  let name = #"1111"
  let qty = 1

  let userName = bytearray.concat(p.userTokenPrefix, name)
  let refName = bytearray.concat(p.refTokenPrefix, name)

  let mint =
    assets.merge(
      assets.from_asset(policy, refName, qty),
      assets.from_asset(policy, userName, qty),
    )

  m.mint222(policy, name, mint) == (refName, userName)
}

// check MintQty && TokenNames returns TokenNames
test mint444() {
  let policy = #"0000"
  let name = #"1111"
  let qty = 1

  let fracName = bytearray.concat(p.fracTokenPrefix, name)
  let refName = bytearray.concat(p.refTokenPrefix, name)

  let mint =
    assets.merge(
      assets.from_asset(policy, refName, qty),
      assets.from_asset(policy, fracName, qty),
    )

  m.mint444(policy, name, qty, mint) == (refName, fracName)
}
