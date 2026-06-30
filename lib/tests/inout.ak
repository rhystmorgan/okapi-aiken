use aiken/fuzz
use aiken/primitive/bytearray
use cardano/transaction.{NoDatum}
use okapi/inout as i
use tools/tools as v
use units/tx as t

test listInputOutputs() {
  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let ins = [in1, in2]

  i.listInputOutputs(ins) == [in1.output, in2.output]
}

test listScriptIns() {
  let script = #"0000"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in4 =
    t.input(
      t.oref(#"0000", 4),
      t.output(t.scriptAddress(#"3333"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in5 =
    t.input(
      t.oref(#"0000", 5),
      t.output(t.scriptAddress(#"2222"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in6 =
    t.input(
      t.oref(#"0000", 10),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let ins = [in1, in2, in3, in4, in5, in6]

  i.listScriptIns(script, ins) == [in1, in3]
}

test listScriptOuts() {
  let script = #"0000"

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let outs = [out1, out2, out3]

  i.listScriptOuts(script, outs) == [out1, out3]
}

test listScriptIO() {
  let script = #"0000"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.listScriptIO(script, ins, outs) == ([in1, in3], [out1, out3])
}

test checkTokenPairIO() {
  let script = #"0000"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(script), v.tokenValue(#"22", "aa", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "aa", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(script), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(script), v.tokenValue(#"22", "aa", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "aa", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(script), v.tokenValue(#"99", "", 1), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.checkTokenPairIO(
    [0],
    #"0000",
    #"1111",
    ins,
    outs,
    fn(ina, inb, outa, outb) {
      (ina, inb, outa, outb) == (in1, in2, out1, out2)
    },
  )
}

test checkTokenPairIOPairs() {
  let indices = [0, 2]

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"11", "", 1), NoDatum),
    )

  let in4 =
    t.input(
      t.oref(#"0000", 4),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"11", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"11", "", 1), NoDatum)
  let out4 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"11", "", 1), NoDatum)

  let ins = [in1, in2, in3, in4]
  let outs = [out1, out2, out3, out4]

  i.checkTokenPairIO(
    indices,
    #"0000",
    #"1111",
    ins,
    outs,
    fn(_aIn, _bIn, _aOut, _bOut) { True },
  ) == True
}

test getPolicyIO() {
  let policy = #"00"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(policy, "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(policy, "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.getPolicyIO(ins, outs, policy) == [(in2, out2)]
}

test listInputOutputsProp(
  pair via fuzz.both(
    fuzz.int_between(1, 10), 
    fuzz.int_between(1, 10)
  )
) fail {
  let (a1, a2) = pair
  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(a1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"0000"), v.makeAdaValue(a2), NoDatum),
    )

  i.listInputOutputs([in1, in2]) == [in2.output, in1.output]
}

test listScriptInsProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let script = bytearray.from_int_big_endian(n1, 1)

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(
        t.scriptAddress(bytearray.from_int_big_endian(n2, 1)),
        v.tokenValue(#"00", "", 1),
        NoDatum,
      ),
    )

  i.listScriptIns(script, [in1]) == [in1]
}

test listScriptOutsProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let script = bytearray.from_int_big_endian(n1, 1)

  let out1 =
    t.output(
      t.scriptAddress(bytearray.from_int_big_endian(n2, 1)),
      v.tokenValue(#"00", "", 1),
      NoDatum,
    )

  i.listScriptOuts(script, [out1]) == [out1]
}

test listScriptIOProp(
  pair via fuzz.both(fuzz.int_between(0, 10), fuzz.int_between(0, 10)),
) fail {
  let (n1, n2) = pair
  let script = bytearray.from_int_big_endian(n1, 1)
  let cred = bytearray.from_int_big_endian(n2, 1)

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(cred), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(cred), v.tokenValue(#"00", "", 1), NoDatum)

  i.listScriptIO(script, [in1], [out1]) == ([in1], [out1])
}

test checkTokenPairIOProp(
  pair via fuzz.both(fuzz.int_between(1, 10), fuzz.int_between(1, 10)),
) fail {
  let (q1, q2) = pair
  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "aa", q1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "aa", q2), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "aa", q1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "aa", q2), NoDatum)

  i.checkTokenPairIO(
    [0],
    #"0000",
    #"1111",
    [in1, in2],
    [out1, out2],
    fn(_aIn, _bIn, _aOut, _bOut) { True },
  )
}

test getPolicyIOProp(
  pair via fuzz.both(fuzz.int_between(1, 10), fuzz.int_between(1, 10)),
) fail {
  let (q1, q2) = pair
  let policy = #"00"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(policy, "", q1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(policy, "", q2), NoDatum)

  i.getPolicyIO([in1], [out1], policy) == [(in1, out1)]
}

test getPolicyIOPairs() {
  let policy = #"00"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(policy, "aa", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(policy, "bb", 2), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(policy, "aa", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(policy, "bb", 2), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.getPolicyIO(ins, outs, policy) == [(in1, out1), (in3, out3)]
}

test listInputOutputsFail() fail {
  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let ins = [in1, in2]

  i.listInputOutputs(ins) == [in2.output, in1.output]
}

test listScriptInsFail() fail {
  let script = #"9999"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let ins = [in1, in2, in3]

  i.listScriptIns(script, ins) == [in1, in3]
}

test listScriptOutsFail() fail {
  let script = #"9999"

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let outs = [out1, out2, out3]

  i.listScriptOuts(script, outs) == [out1, out3]
}

test listScriptIOFail() fail {
  let script = #"9999"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"00", "", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.listScriptIO(script, ins, outs) == ([in1, in3], [out1, out3])
}

test checkTokenPairIOFail() fail {
  let script = #"0000"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(script), v.tokenValue(#"22", "aa", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "aa", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(script), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(script), v.tokenValue(#"22", "aa", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(#"22", "aa", 1), NoDatum)
  let out3 =
    t.output(t.scriptAddress(script), v.tokenValue(#"99", "", 1), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.checkTokenPairIO(
    [1],
    #"0000",
    #"1111",
    ins,
    outs,
    fn(ina, inb, outa, outb) {
      (ina, inb, outa, outb) == (in1, in2, out1, out2)
    },
  )
}

test getPolicyIOFail() fail {
  let policy = #"00"

  let in1 =
    t.input(
      t.oref(#"0000", 1),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum),
    )

  let in2 =
    t.input(
      t.oref(#"0000", 2),
      t.output(t.scriptAddress(#"1111"), v.tokenValue(policy, "", 1), NoDatum),
    )

  let in3 =
    t.input(
      t.oref(#"0000", 3),
      t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum),
    )

  let out1 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"22", "", 1), NoDatum)
  let out2 =
    t.output(t.scriptAddress(#"1111"), v.tokenValue(policy, "", 2), NoDatum)
  let out3 =
    t.output(t.scriptAddress(#"0000"), v.tokenValue(#"99", "", 1), NoDatum)

  let ins = [in1, in2, in3]
  let outs = [out1, out2, out3]

  i.getPolicyIO(ins, outs, policy) == [(in2, out2)]
}
