use aiken/collection/list
use aiken/crypto.{ScriptHash}
use cardano/address.{Address, Script}
use cardano/assets.{PolicyId, Value}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction, find_input,
  find_script_outputs,
}

//         //
// Helpers //
//         //

// get token pair Inputs && Datums
pub fn get_loan_col_in(
  ins: List<Input>,
  loanValue: Value,
  loanHash: ScriptHash,
  colHash: ScriptHash,
) {
  expect Some(loanIn) =
    list.find(
      ins,
      fn(in) {
        in.output.address.payment_credential == Script(loanHash) && assets.without_lovelace(
          in.output.value,
        ) == loanValue
      },
    )

  expect InlineDatum(datum) = loanIn.output.datum
  expect lin: LoanDatum = datum

  expect Some(colIn) =
    list.find(
      ins,
      fn(in) {
        in.output.address.payment_credential == Script(colHash) && assets.without_lovelace(
          in.output.value,
        ) == loanValue
      },
    )

  expect InlineDatum(datum) = colIn.output.datum
  expect cin: CollateralDatum = datum

  (loanIn.output.value, lin, colIn.output.value, cin)
}

// Token Pair input datums (aIn Datum, bIn Datum)
pub fn get_loan_col_in_datum(
  ins: List<Input>,
  tokenValue: Value,
  aHash: ScriptHash,
  bHash: ScriptHash,
) -> (LoanDatum, CollateralDatum) {
  expect Some(aIn) =
    list.find(
      ins,
      fn(in) {
        in.output.address.payment_credential == Script(aHash) && assets.without_lovelace(
          in.output.value,
        ) == tokenValue
      },
    )

  expect InlineDatum(aDatum) = loanIn.output.datum

  expect Some(bIn) =
    list.find(
      ins,
      fn(in) {
        in.output.address.payment_credential == Script(bHash) && assets.without_lovelace(
          in.output.value,
        ) == tokenValue
      },
    )

  expect InlineDatum(bDatum) = bIn.output.datum

  (aDatumn, bDatum)
}

// returns configDatum or errors
pub fn get_config_datum(ref: List<Input>, policy: PolicyId) -> MerkelConfigDatum {
  expect Some(configIn) =
    list.find(
      ref,
      fn(input) { list.has(assets.policies(input.output.value), policy) },
    )

  expect InlineDatum(datum) = configIn.output.datum
  expect cDatum: MerkelConfigDatum = datum

  cDatum
}

// returns interestDatum or errors
pub fn get_interest_datum(
  ref: List<Input>,
  policy: PolicyId,
  script: ScriptHash,
) -> InterestDatum {
  expect Some(interestRef) =
    list.find(
      ref,
      fn(input) {
        list.has(assets.policies(input.output.value), policy) && input.output.address.payment_credential == Script(
          script,
        )
      },
    )

  expect InlineDatum(datum) = interestRef.output.datum
  expect iDatum: InterestDatum = datum

  iDatum
}

// returns oracleOut Datum or errors
pub fn get_oracle_datum(
  outs: List<Output>,
  policy: PolicyId,
  script: ScriptHash,
) -> OracleDatum {
  expect Some(oracleOut) =
    list.find(
      outs,
      fn(output) {
        list.has(assets.policies(output.value), policy) && output.address.payment_credential == Script(
          script,
        )
      },
    )

  expect InlineDatum(datum) = oracleOut.datum
  expect rDatum: OracleDatum = datum

  rDatum
}

// CALLED general.authTokenOutput()

// CALLED spend.ownSpendIO()
// // returns non-staking single validator (input, output)
// ---

// Don't use this function, it was an optimisation test for the above
// used to benchmark mem & cpu efficiencies for the optim of other functions
pub fn oneIO_Tx(oref: OutputReference, tx: Transaction) -> (Input, Output) {
  expect Some(in) = tx.inputs |> find_input(oref)

  let cred = in.output.address.payment_credential

  let ownInputs =
    list.filter(
      tx.inputs,
      fn(input) {
        input.output.address.payment_credential == cred && input.output.address.stake_credential == None
      },
    )
  let ownOutputs =
    list.filter(
      tx.outputs,
      fn(output) {
        output.address.payment_credential == cred && output.address.stake_credential == None
      },
    )

  expect list.length(ownInputs) == 1
  expect list.length(ownOutputs) == 1

  expect Some(i) = list.head(ownInputs)
  expect Some(o) = list.head(ownOutputs)

  (i, o)
}

// pub fn mapInputIndex(
//   indices: List<Int>,
//   inputs: List<Input>,
//   validate: fn(Output, Output) -> Bool,
// ) -> Bool {
//   let txList =
//     list.map(
//       indices,
//       fn(index) {
//         expect Some(loan) = list.at(inputs, index)
//         expect Some(col) =
//           list.find(
//             inputs,
//             fn(input) {
//               assets.without_lovelace(input.output.value) == assets.without_lovelace(
//                 loan.output.value,
//               ) && input.output.address.payment_credential != loan.output.address.payment_credential
//             },
//           )
//         (loan.output, col.output)
//       },
//     )

//   list.all(
//     txList,
//     fn(pair) {
//       let (loan, col) = pair
//       validate(loan, col)
//     },
//   )
// }

pub fn mapOutputIndex(
  outputs: List<Output>,
  indices: List<Int>,
  validate: fn(Output) -> Bool,
) -> Bool {
  let filtered =
    list.map(
      indeces,
      fn(index) {
        expect Some(out) = list.at(outputs, index)
        out
      },
    )

  list.all(filtered, fn(output) { validate(output) })
}
