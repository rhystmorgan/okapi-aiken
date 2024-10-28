use aiken/fuzz as f

pub fn twoTens() -> Fuzzer<(Int, Int)> {
  let a = f.int_between(1, 10)
  let b = f.int_between(1, 10)
  f.both(a, b)
}

pub fn threeTens() -> Fuzzer<(Int, Int, Int)> {
  f.map3(
    f.int_between(1, 10),
    f.int_between(1, 10),
    f.int_between(1, 10),
    fn(a, b, c) { (a, b, c) },
  )
}

pub fn fourTens() -> Fuzzer<(Int, Int, Int, Int)> {
  f.map4(
    f.int_between(1, 10),
    f.int_between(1, 10),
    f.int_between(1, 10),
    f.int_between(1, 10),
    fn(a, b, c, d) { (a, b, c, d) },
  )
}

// creates list of 5 x Ints 1-10
pub fn tensList(length: Int) -> Fuzzer<List<Int>> {
  f.list_between(f.int_between(1, 10), length, length)
}
