use okapi/spend as s

test getOrefInput() {
  s.getOrefInput(oref, ins) == in
}

test getOrefInputOut() {
  s.getOrefInputOut(oref, ins) == out
}

test getOrefScriptHash() {
  s.getOrefScriptHash(oref, ins) == #"0000"
}

test getOrefValue() {
  s.getOrefValue(oref, ins) == value
}

test getOrefDatumValue() {
  s.getOrefDatumValue(oref, ins) == (datum, value)
}

// returns non-staking single validator (input, output)
test ownSpendIO() {
  s.ownSpendIO(oref, ins, outs) == (in, out)
}

// Checks for one `own Validator` output and returns it
test ownSingletonOutput() {
  s.ownSingletonOutput(ins, outs, oref) == out
}

test foldInValuesOut() {
  s.foldInValuesOut(ins, outs) == (inValue, outValue)
}
