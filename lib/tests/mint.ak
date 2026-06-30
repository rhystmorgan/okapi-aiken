use aiken/fuzz
use aiken/primitive/bytearray
use cardano/assets
use okapi/mint as m
use okapi/prefix as p

//            //
// mint tests //
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

test mintTokensMulti() {
  let policy = #"0000"
  let mint =
    assets.merge(
      assets.merge(
        assets.from_asset(policy, #"1111", 2),
        assets.from_asset(policy, #"2222", 5),
      ),
      assets.from_asset(#"9999", #"3333", 1),
    )

  m.mintTokens(policy, mint) == [Pair(#"1111", 2), Pair(#"2222", 5)]
}

test mint444Qty() {
  let policy = #"0000"
  let name = #"1111"
  let qty = 100

  let fracName = bytearray.concat(p.fracTokenPrefix, name)
  let refName = bytearray.concat(p.refTokenPrefix, name)

  let mint =
    assets.merge(
      assets.from_asset(policy, refName, 1),
      assets.from_asset(policy, fracName, qty),
    )

  m.mint444(policy, name, qty, mint) == (refName, fracName)
}

test mintTokensProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (q1, q2) = pair
  let policy = #"0000"
  let name = #"1111"
  let mint = assets.from_asset(policy, name, q1)

  m.mintTokens(policy, mint) == [Pair(name, q2)]
}

test mintTokenProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (q1, q2) = pair
  let policy = #"0000"
  let name = #"1111"
  let mint = assets.from_asset(policy, name, q1)

  m.mintToken(policy, mint) == Pair(name, q2)
}

test mint222Prop(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  ),
) fail {
  let (q1, q2) = pair
  let policy = #"0000"
  let name = #"1111"

  let userName = bytearray.concat(p.userTokenPrefix, name)
  let refName = bytearray.concat(p.refTokenPrefix, name)

  let mint =
    assets.merge(
      assets.from_asset(policy, refName, q1),
      assets.from_asset(policy, userName, q2),
    )

  expect m.mint222(policy, name, mint) == (refName, userName)
}

test mint444Prop(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (minted, expected) = pair
  let policy = #"0000"
  let name = #"1111"

  let fracName = bytearray.concat(p.fracTokenPrefix, name)
  let refName = bytearray.concat(p.refTokenPrefix, name)

  let mint =
    assets.merge(
      assets.from_asset(policy, refName, 1),
      assets.from_asset(policy, fracName, minted),
    )

  m.mint444(policy, name, expected, mint) == (refName, fracName)
}

test mintTokensFail() fail {
  let policy = #"0000"
  let name = #"1111"
  let qty = 2
  let mint = assets.from_asset(policy, name, qty)

  m.mintTokens(#"9999", mint) == [Pair(name, qty)]
}

test mintTokenFail() fail {
  let policy = #"0000"
  let name = #"1111"
  let qty = 2
  let mint =
    assets.merge(
      assets.from_asset(policy, name, qty),
      assets.from_asset(policy, #"2222", 1),
    )

  m.mintToken(policy, mint) == Pair(name, qty)
}

test mint222Fail() fail {
  let policy = #"0000"
  let name = #"1111"
  let qty = 2

  let userName = bytearray.concat(p.userTokenPrefix, name)
  let refName = bytearray.concat(p.refTokenPrefix, name)

  let mint =
    assets.merge(
      assets.from_asset(policy, refName, qty),
      assets.from_asset(policy, userName, qty),
    )

  m.mint222(policy, name, mint) == (refName, userName)
}

test mint444Fail() fail {
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

  m.mint444(policy, name, 5, mint) == (refName, fracName)
}
