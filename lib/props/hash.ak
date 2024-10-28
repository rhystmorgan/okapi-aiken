use aiken/fuzz as f

// create 2 Hashes
pub fn twoHashes() -> Fuzzer<(ByteArray, ByteArray)> {
  let a = f.bytearray_fixed(28)
  let b = f.bytearray_fixed(28)
  f.both(a, b)
}

// tuple of hash between 1-10
pub fn threeHashes() -> Fuzzer<(ByteArray, ByteArray, ByteArray)> {
  f.map3(
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    fn(a, b, c) { (a, b, c) },
  )
}

// tuple of hash between 1-10
pub fn fourHashes() -> Fuzzer<(ByteArray, ByteArray, ByteArray, ByteArray)> {
  f.map4(
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    f.bytearray_fixed(28),
    fn(a, b, c, d) { (a, b, c, d) },
  )
}

// creates list of n x 28' bytearrays
pub fn hashList(n: Int) -> Fuzzer<List<ByteArray>> {
  f.list_between(f.bytearray_fixed(28), n, n)
}
