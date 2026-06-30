use aiken/fuzz
use cardano/assets
use cardano/transaction.{NoDatum}
use okapi/value as v
use units/tx as t
use units/value

test foldValuesIn() {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(t.walletAddress(#"1111"), value.adaValue(60), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(40), NoDatum),
    )

  let ins = [in1, in2, in3]

  v.foldValuesIn(ins) == value.adaValue(200)
}

test foldAssetsIn() {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(
        t.scriptAddress(#"0000"),
        assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
        NoDatum,
      ),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.merge(value.adaValue(100), assets.from_asset(#"11", #"11", 6)),
        NoDatum,
      ),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(
        t.walletAddress(#"2222"),
        assets.merge(value.adaValue(100), assets.from_asset(#"22", #"22", 2)),
        NoDatum,
      ),
    )

  let ins = [in1, in2, in3]

  v.foldAssetsIn(ins) == value.mergeValueList(
    [(#"00", #"00", 1), (#"11", #"11", 6), (#"22", #"22", 2)],
  )
}

test foldPolicyIn() {
  let policy = #"00"

  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(
        t.scriptAddress(#"0000"),
        assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
        NoDatum,
      ),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.merge(
          assets.from_asset(#"00", #"11", 6),
          assets.from_asset(#"11", #"11", 6),
        ),
        NoDatum,
      ),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(
        t.walletAddress(#"2222"),
        assets.merge(
          assets.from_asset(#"22", #"22", 2),
          assets.from_asset(#"00", #"22", 2),
        ),
        NoDatum,
      ),
    )

  let ins = [in1, in2, in3]

  v.foldPolicyIn(ins, policy) == value.mergeValueList(
    [(#"00", #"00", 1), (#"00", #"11", 6), (#"00", #"22", 2)],
  )
}

test foldValuesOut() {
  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 = t.output(t.walletAddress(#"1111"), value.adaValue(60), NoDatum)

  let out3 = t.output(t.walletAddress(#"2222"), value.adaValue(40), NoDatum)

  let outs = [out1, out2, out3]

  v.foldValuesOut(outs) == value.adaValue(200)
}

test foldAssetsOut() {
  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
      NoDatum,
    )

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.merge(value.adaValue(100), assets.from_asset(#"11", #"11", 6)),
      NoDatum,
    )

  let out3 =
    t.output(
      t.walletAddress(#"2222"),
      assets.merge(value.adaValue(100), assets.from_asset(#"22", #"22", 2)),
      NoDatum,
    )

  let outs = [out1, out2, out3]

  v.foldAssetsOut(outs) == value.mergeValueList(
    [(#"00", #"00", 1), (#"11", #"11", 6), (#"22", #"22", 2)],
  )
}

test foldPolicyOut() {
  let policy = #"00"

  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
      NoDatum,
    )

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.merge(
        assets.from_asset(#"00", #"11", 6),
        assets.from_asset(#"11", #"11", 6),
      ),
      NoDatum,
    )

  let out3 =
    t.output(
      t.walletAddress(#"2222"),
      assets.merge(
        assets.from_asset(#"22", #"22", 2),
        assets.from_asset(#"00", #"22", 2),
      ),
      NoDatum,
    )

  let outs = [out1, out2, out3]

  v.foldPolicyOut(outs, policy) == value.mergeValueList(
    [(#"00", #"00", 1), (#"00", #"11", 6), (#"00", #"22", 2)],
  )
}

test negateInValueOut() {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(#"00", #"00", 5),
        NoDatum,
      ),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(
        t.walletAddress(#"2222"),
        assets.from_asset(#"22", #"22", 2),
        NoDatum,
      ),
    )

  let ins = [in1, in2, in3]

  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(#"00", #"00", 6),
      NoDatum,
    )

  let out3 =
    t.output(
      t.walletAddress(#"2222"),
      assets.from_asset(#"22", #"22", 2),
      NoDatum,
    )

  let outs = [out1, out2, out3]

  v.negateInValueOut(ins, outs) == assets.from_asset(#"00", #"00", 1)
}

test negateOutValueIn() {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(#"00", #"00", 6),
        NoDatum,
      ),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(
        t.walletAddress(#"2222"),
        assets.from_asset(#"22", #"22", 2),
        NoDatum,
      ),
    )

  let ins = [in1, in2, in3]

  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(#"00", #"00", 5),
      NoDatum,
    )

  let out3 =
    t.output(
      t.walletAddress(#"2222"),
      assets.from_asset(#"22", #"22", 2),
      NoDatum,
    )

  let outs = [out1, out2, out3]

  v.negateOutValueIn(ins, outs) == assets.from_asset(#"00", #"00", 1)
}

test foldValuesInProp(
  trio via fuzz.tuple3(fuzz.int_between(1, 10), fuzz.int_between(1, 10), fuzz.int_between(1, 10)),
) fail {
  let (a1, a2, a3) = trio
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(a1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(t.walletAddress(#"1111"), value.adaValue(a2), NoDatum),
    )

  v.foldValuesIn([in1, in2]) == value.adaValue(a3)
}

test foldAssetsInProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(
        t.scriptAddress(#"0000"),
        assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", q1)),
        NoDatum,
      ),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", q2)),
        NoDatum,
      ),
    )

  v.foldAssetsIn([in1, in2]) == assets.from_asset(#"00", #"00", q3)
}

test foldPolicyInProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let policy = #"00"

  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(
        t.scriptAddress(#"0000"),
        assets.merge(
          assets.from_asset(policy, #"00", q1),
          assets.from_asset(#"11", #"11", 6),
        ),
        NoDatum,
      ),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(policy, #"00", q2),
        NoDatum,
      ),
    )

  v.foldPolicyIn([in1, in2], policy) == assets.from_asset(policy, #"00", q3)
}

test foldValuesOutProp(
  trio via fuzz.tuple3(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  ),
) fail {
  let (a1, a2, a3) = trio
  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(a1), NoDatum)

  let out2 = t.output(t.walletAddress(#"1111"), value.adaValue(a2), NoDatum)

  v.foldValuesOut([out1, out2]) == value.adaValue(a3)
}

test foldAssetsOutProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", q1)),
      NoDatum,
    )

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", q2)),
      NoDatum,
    )

  v.foldAssetsOut([out1, out2]) == assets.from_asset(#"00", #"00", q3)
}

test foldPolicyOutProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let policy = #"00"

  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      assets.merge(
        assets.from_asset(policy, #"00", q1),
        assets.from_asset(#"11", #"11", 6),
      ),
      NoDatum,
    )

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(policy, #"00", q2),
      NoDatum,
    )

  v.foldPolicyOut([out1, out2], policy) == assets.from_asset(policy, #"00", q3)
}

test negateInValueOutProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(#"00", #"00", q1),
        NoDatum,
      ),
    )

  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(#"00", #"00", q2),
      NoDatum,
    )

  v.negateInValueOut([in1, in2], [out1, out2]) == assets.from_asset(
    #"00",
    #"00",
    q3,
  )
}

test negateOutValueInProp(
  trio via
    fuzz.tuple3(
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
      fuzz.int_between(1, 10),
    ),
) fail {
  let (q1, q2, q3) = trio
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(#"00", #"00", q1),
        NoDatum,
      ),
    )

  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(#"00", #"00", q2),
      NoDatum,
    )

  v.negateOutValueIn([in1, in2], [out1, out2]) == assets.from_asset(
    #"00",
    #"00",
    q3,
  )
}

test foldValuesInFail() fail {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(t.walletAddress(#"1111"), value.adaValue(60), NoDatum),
    )

  let ins = [in1, in2]

  v.foldValuesIn(ins) == value.adaValue(200)
}

test foldAssetsInFail() fail {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(
        t.scriptAddress(#"0000"),
        assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
        NoDatum,
      ),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.merge(value.adaValue(100), assets.from_asset(#"11", #"11", 6)),
        NoDatum,
      ),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(
        t.walletAddress(#"2222"),
        assets.merge(value.adaValue(100), assets.from_asset(#"22", #"22", 2)),
        NoDatum,
      ),
    )

  let ins = [in1, in2, in3]

  v.foldAssetsIn(ins) == assets.merge(
    value.adaValue(300),
    value.mergeValueList(
      [(#"00", #"00", 1), (#"11", #"11", 6), (#"22", #"22", 2)],
    ),
  )
}

test foldPolicyInFail() fail {
  let policy = #"99"

  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(
        t.scriptAddress(#"0000"),
        assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
        NoDatum,
      ),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.merge(
          assets.from_asset(#"00", #"11", 6),
          assets.from_asset(#"11", #"11", 6),
        ),
        NoDatum,
      ),
    )

  let in3 =
    t.input(
      t.oref(#"cccc", 1),
      t.output(
        t.walletAddress(#"2222"),
        assets.merge(
          assets.from_asset(#"22", #"22", 2),
          assets.from_asset(#"00", #"22", 2),
        ),
        NoDatum,
      ),
    )

  let ins = [in1, in2, in3]

  v.foldPolicyIn(ins, policy) == value.mergeValueList(
    [(#"00", #"00", 1), (#"00", #"11", 6), (#"00", #"22", 2)],
  )
}

test foldValuesOutFail() fail {
  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 = t.output(t.walletAddress(#"1111"), value.adaValue(60), NoDatum)

  let outs = [out1, out2]

  v.foldValuesOut(outs) == value.adaValue(200)
}

test foldAssetsOutFail() fail {
  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
      NoDatum,
    )

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.merge(value.adaValue(100), assets.from_asset(#"11", #"11", 6)),
      NoDatum,
    )

  let out3 =
    t.output(
      t.walletAddress(#"2222"),
      assets.merge(value.adaValue(100), assets.from_asset(#"22", #"22", 2)),
      NoDatum,
    )

  let outs = [out1, out2, out3]

  v.foldAssetsOut(outs) == assets.merge(
    value.adaValue(300),
    value.mergeValueList(
      [(#"00", #"00", 1), (#"11", #"11", 6), (#"22", #"22", 2)],
    ),
  )
}

test foldPolicyOutFail() fail {
  let policy = #"99"

  let out1 =
    t.output(
      t.scriptAddress(#"0000"),
      assets.merge(value.adaValue(100), assets.from_asset(#"00", #"00", 1)),
      NoDatum,
    )

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.merge(
        assets.from_asset(#"00", #"11", 6),
        assets.from_asset(#"11", #"11", 6),
      ),
      NoDatum,
    )

  let out3 =
    t.output(
      t.walletAddress(#"2222"),
      assets.merge(
        assets.from_asset(#"22", #"22", 2),
        assets.from_asset(#"00", #"22", 2),
      ),
      NoDatum,
    )

  let outs = [out1, out2, out3]

  v.foldPolicyOut(outs, policy) == value.mergeValueList(
    [(#"00", #"00", 1), (#"00", #"11", 6), (#"00", #"22", 2)],
  )
}

test negateInValueOutFail() fail {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(#"00", #"00", 6),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(#"00", #"00", 5),
      NoDatum,
    )

  let outs = [out1, out2]

  v.negateInValueOut(ins, outs) == assets.from_asset(#"00", #"00", 1)
}

test negateOutValueInFail() fail {
  let in1 =
    t.input(
      t.oref(#"aaaa", 1),
      t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"bbbb", 1),
      t.output(
        t.walletAddress(#"1111"),
        assets.from_asset(#"00", #"00", 5),
        NoDatum,
      ),
    )

  let ins = [in1, in2]

  let out1 = t.output(t.scriptAddress(#"0000"), value.adaValue(100), NoDatum)

  let out2 =
    t.output(
      t.walletAddress(#"1111"),
      assets.from_asset(#"00", #"00", 6),
      NoDatum,
    )

  let outs = [out1, out2]

  v.negateOutValueIn(ins, outs) == assets.from_asset(#"00", #"00", 1)
}
