use aiken/fuzz
use cardano/transaction.{NoDatum}
use okapi/fast as f
use units/tx as x
use units/value as v

test mustFindInput() {
  let oref = x.oref(#"0000", 1)
  let in1 =
    x.input(oref, x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum))

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(x.walletAddress(#"1111"), v.adaValue(200), NoDatum),
    )

  f.mustFindInput([in2, in1], oref) == in1
}

test mustFind() {
  f.mustFind([1, 2, 3], fn(n) { n > 2 }) == 3
}

test onlyMatchSingle() {
  f.onlyMatch([1, 2, 3], fn(n) { n > 2 }) == True
}

test onlyMatchMany() {
  f.onlyMatch([1, 2, 3], fn(n) { n > 1 }) == False
}

test onlyMatchNone() {
  f.onlyMatch([1, 2, 3], fn(n) { n > 9 }) == False
}

test mustFindFirst() {
  f.mustFind([1, 2, 3], fn(n) { n > 1 }) == 2
}

test mustFindInputFail() fail {
  let in1 =
    x.input(
      x.oref(#"0000", 1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  let in2 =
    x.input(
      x.oref(#"1111", 2),
      x.output(x.walletAddress(#"1111"), v.adaValue(200), NoDatum),
    )

  f.mustFindInput([in2, in1], x.oref(#"2222", 3)) == in1
}

test mustFindFail() fail {
  f.mustFind([1, 2, 3], fn(n) { n > 9 }) == 3
}

test onlyMatchFail() fail {
  f.onlyMatch([1, 2, 3], fn(n) { n > 1 })
}

test mustFindInputProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (i1, i2) = pair
  let in1 =
    x.input(
      x.oref(#"0000", i1),
      x.output(x.scriptAddress(#"0000"), v.adaValue(100), NoDatum),
    )

  f.mustFindInput([in1], x.oref(#"0000", i2)) == in1
}

test mustFindProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (n1, n2) = pair
  f.mustFind([n1], fn(n) { n == n2 }) == n1
}

test onlyMatchProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (n1, n2) = pair
  f.onlyMatch([n1], fn(n) { n == n2 })
}
