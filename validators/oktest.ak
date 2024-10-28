// // validator template
// use aiken/collection/bytearray as b
// use aiken/crypto as h
// use aiken/list as l
// use aiken/transaction/credential as c
// use aiken/transaction/value as v
// use cardano/transaction as tx
// // okapi lib
// use okapi_aiken/okapi as ok
// use tests/tools as t

// type ODatum {
//   adaUsd: Int,
//   timestamp: Int,
// }

// type OAction {
//   Update { a: Int, t: Int }
//   Close
// }

// //            //
// // Validators //
// //            //

// validator oracle(owner: ok.VerificationKeyHash, p: v.PolicyId) {
//   spend(_d: Opiton<ODatum>, r: OAction, oref: OutputReference, tx: Transaction) {
//     when r is {
//       Update { a, t } -> {
//         expect ownOut = ok.get_own_singleton_output(c)
//         expect oracleTokenOut = ok.get_out_with_policy(c, p)

//         expect InlineDatum(datum) = oracleTokenOut.datum
//         expect oracleD: ODatum = datum

//         ownOut.address == oracleTokenOut.address && oracleD.timestamp > d.timestamp
//       }
//       Close -> ok.tx_signed_by(c.transaction, owner)
//     }
//   }

//   else(_) {
//     fail
//   }
// }

// test oracle_test() {
//   let testOwner = #"face"
//   let oraclePolicy = #"cafe"

//   let oref = t.testOref(#"aced", 1)

//   let oracleDatum1 = ODatum { adaUsd: 1, timestamp: 11111111 }
//   let oracleDatum2 = ODatum { adaUsd: 2, timestamp: 11111112 }
//   let inDatum = InlineDatum(oracleDatum1)
//   let outDatum = InlineDatum(oracleDatum2)

//   let oracleInput =
//     t.testInput(
//       oref,
//       t.testOutput(
//         t.testScriptAddress(t.oracleValHash),
//         t.singletonTxValue(oraclePolicy, ""),
//         inDatum,
//       ),
//     )

//   let oracleOutput =
//     t.testOutput(
//       t.testScriptAddress(t.oracleValHash),
//       t.singletonTxValue(oraclePolicy, ""),
//       outDatum,
//     )

//   let oracleAction = Update { a: 2, t: 11111112 }

//   let tx =
//     Transaction {
//       ..placeholder(),
//       extra_signatories: [testOwner],
//       inputs: [oracleInput],
//       outputs: [oracleOutput],
//     }

//   oracle.spend(
//     testOwner,
//     oraclePolicy,
//     Some(oracleDatum1),
//     oracleAction,
//     oreef,
//     tx,
//   )?
// }
