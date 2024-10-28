use aiken/fuzz as f

pub fn fuzzAssets() -> Fuzzer<(ByteArray, ByteArray, Int)> {
  f.map3(
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    f.int_between(1, 10),
    fn(a, b, c) { (a, b, c) },
  )
}

pub fn fuzzAsset() -> Fuzzer<(ByteArray, ByteArray, Int)> {
  f.map3(
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    f.int_between(1, 1),
    fn(a, b, c) { (a, b, c) },
  )
}
// // random asset
// test singleAsset(tuple via fuzzAsset()) {
//   let (a, b, c) = tuple

//   assets.from_asset(a, b, c)
//   True
// }

// // multi asset
// test multiAsset(tuple via fuzzAssets()) {
//   let (a, b, c) = tuple

//   assets.from_asset(a, b, c)
//   True
// }

// pub fn randomAsset() -> Value {
//   let policy = f.bytearray_fixed(28)
//   let tokenName = f.bytearray_fixed(28)
//   let quantity = f.int_between(1, 200)

//   assets.from_asset(policy, tokenName, quantity)
// }

// // junk token value
// pub fn randomTokens(n: Int) -> Value {
//   let list = f.list_between(fuzzAssets(), n, n)

//   mergeValueList(list)
// }
