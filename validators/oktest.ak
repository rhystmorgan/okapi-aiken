// validator template
use aiken/bytearray as b
use aiken/hash as h
use aiken/list as l
use aiken/time.{PosixTime}
use aiken/transaction as tx
use aiken/transaction/credential as c
use aiken/transaction/value as v
// okapi lib
use okapi_aiken/okapi as ok
use tests/tools as t

type ODatum {
  adaUsd: Int,
  timestamp: PosixTime,
}

type OAction {
  Update { a: Int, t: PosixTime }
  Close
}

//            //
// Validators //
//            //

validator(owner: ok.VerificationKeyHash, p: v.PolicyId) {
  fn oracle(d: ODatum, r: OAction, c: tx.ScriptContext) -> Bool {
    expect tx.ScriptContext { transaction, purpose: tx.Spend(oref) } = c

    when r is {
      Update { a, t } -> {
        expect ownOut = ok.get_own_singleton_output(c)
        expect oracleTokenOut = ok.get_out_with_policy(c, p)

        expect tx.InlineDatum(datum) = oracleTokenOut.datum
        expect oracleD: ODatum = datum

        ownOut.address == oracleTokenOut.address && oracleD.timestamp > d.timestamp
      }
      Close -> ok.tx_signed_by(c.transaction, owner)
    }
  }
}

test oracle_test() {
  let testOwner = #"face"
  let oraclePolicy = #"cafe"

  let oref = t.testOref(#"aced", 1)

  let oracleDatum1 = ODatum { adaUsd: 1, timestamp: 11111111 }
  let oracleDatum2 = ODatum { adaUsd: 2, timestamp: 11111112 }
  let inDatum = tx.InlineDatum(oracleDatum1)
  let outDatum = tx.InlineDatum(oracleDatum2)

  let oracleInput =
    t.testInput(
      oref,
      t.testOutput(
        t.testScriptAddress(t.oracleValHash),
        t.singletonTxValue(oraclePolicy, ""),
        inDatum,
      ),
    )

  let oracleOutput =
    t.testOutput(
      t.testScriptAddress(t.oracleValHash),
      t.singletonTxValue(oraclePolicy, ""),
      outDatum,
    )

  let oracleAction = Update { a: 2, t: 11111112 }

  let tx =
    tx.Transaction {
      ..tx.placeholder(),
      extra_signatories: [testOwner],
      inputs: [oracleInput],
      outputs: [oracleOutput],
    }

  let ctx = tx.ScriptContext { purpose: tx.Spend(oref), transaction: tx }

  oracle(testOwner, oraclePolicy, oracleDatum1, oracleAction, ctx)?
}
