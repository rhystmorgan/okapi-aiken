// general operations and unallocated functions

// returns (oracleValue, oracleDatum) or errors
pub fn authTokenOutput(outs: List<Output>, script: ByteArray) -> (Value, Datum) {
  expect Some(tokenOut) =
    list.find(
      outs,
      fn(output) {
        output.address.payment_credential == Script(script) && list.has(
          assets.policies(output.value),
          script,
        )
      },
    )

  // expect InlineDatum(data) = tokenOut.datum
  // (assets.without_lovelace(oracleOut.value), rDatum)
  (assets.without_lovelace(tokenOut.value), tokenOut.datum)
}
