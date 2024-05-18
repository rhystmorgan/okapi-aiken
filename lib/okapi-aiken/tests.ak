use aiken/list
use aiken/transaction.{
  Input, NoDatum, OutputReference, ScriptContext, Spend, Transaction,
  TransactionId, placeholder,
}
use aiken/transaction/credential as c
use aiken/transaction/value
use okapi_aiken/okapi as ok
use tests/tools as t

//             //
// Okapi Tests //
//             //

// we need a list of dummy hex strings
// [ #"beef", #"cafe", #"dead", #"face"]

test get_spend_ref() {
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder(),
    }
  ok.get_spend_ref(ctx) == placeholder_utxo
}

// test not_spend_ref() {
//   let placeholder_utxo = OutputReference()
// }

test get_own_input() {
  let addr = t.testScriptAddress(#"face")
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) { Transaction { ..transaction, inputs: [pinput] } },
    }
  ok.get_own_input(ctx) == pinput.output
}

test get_own_script_hash() {
  let addr = t.testScriptAddress(#"face")
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) { Transaction { ..transaction, inputs: [pinput] } },
    }
  ok.get_own_script_hash(ctx) == #"face"
}

test get_own_input_value() {
  let addr = t.testScriptAddress(#"face")
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) { Transaction { ..transaction, inputs: [pinput] } },
    }
  ok.get_own_input_value(ctx) == value.from_lovelace(5)
}

test get_own_outputs() {
  let addr = t.testScriptAddress(#"face")

  let outs =
    [
      t.testOutput(addr, value.from_lovelace(5), NoDatum),
      t.testOutput(addr, value.from_lovelace(10), NoDatum),
      t.testOutput(addr, value.from_lovelace(5), NoDatum),
    ]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, inputs: [pinput], outputs: outs }
          },
    }
  ok.get_own_outputs(ctx) == outs
}

test has_one_sigleton_output() {
  let addr = t.testScriptAddress(#"face")

  let outs =
    [t.testOutput(addr, value.from_lovelace(5), NoDatum)]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, inputs: [pinput], outputs: outs }
          },
    }
  ok.has_own_singleton_output(ctx)
}

test has_more_singleton_output() {
  let addr = t.testScriptAddress(#"face")

  let outs =
    [
      t.testOutput(addr, value.from_lovelace(5), NoDatum),
      t.testOutput(addr, value.from_lovelace(10), NoDatum),
      t.testOutput(addr, value.from_lovelace(5), NoDatum),
    ]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, inputs: [pinput], outputs: outs }
          },
    }
  ok.has_own_singleton_output(ctx) == False
}

test get_own_singleton_output() {
  let addr = t.testScriptAddress(#"face")

  let outs =
    [t.testOutput(addr, value.from_lovelace(5), NoDatum)]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, inputs: [pinput], outputs: outs }
          },
    }
  ok.get_own_singleton_output(ctx) == t.testOutput(
    addr,
    value.from_lovelace(5),
    NoDatum,
  )
}

test get_own_singleton_output_value() {
  let addr = t.testScriptAddress(#"face")
  let outs =
    [t.testOutput(addr, value.from_lovelace(5), NoDatum)]
  let oref =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }
  let tinput =
    Input {
      output_reference: oref,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }
  let ctx =
    ScriptContext {
      purpose: Spend(oref),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, inputs: [tinput], outputs: outs }
          },
    }
  ok.get_own_singleton_output_value(ctx) == value.from_lovelace(5)
}

test keep_own_lovelace_value() {
  let addr = t.testScriptAddress(#"face")
  let outs =
    [t.testOutput(addr, value.from_lovelace(5), NoDatum)]
  let oref =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }
  let tinput =
    Input {
      output_reference: oref,
      output: t.testOutput(addr, value.from_lovelace(5), NoDatum),
    }
  let ctx =
    ScriptContext {
      purpose: Spend(oref),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, inputs: [tinput], outputs: outs }
          },
    }
  ok.keep_own_lovelace_value(ctx)
}

test contains_single_token_of() {
  let p = #"beef"
  let tn = #"face"
  let value = value.from_asset(p, tn, 1)

  ok.contains_single_token_of(value, p)
}

test contains_only_lovelace() {
  let v = value.from_lovelace(5)

  ok.contains_only_lovelace(v)
}

test tx_signed_by() {
  let s = t.testAddress(#"face")
  let sigs = t.testSignatories()
  let t =
    placeholder()
      |> fn(transaction) { Transaction { ..transaction, extra_signatories: sigs } }
  ok.tx_signed_by(t, #"face")
}

test tx_signed_by_no_list() {
  let s = t.testAddress(#"face")
  let sigs = t.testSignatories()
  let i = 1
  let t =
    placeholder()
      |> fn(transaction) {
          Transaction { ..transaction, extra_signatories: t.testSignatories() }
        }
  ok.tx_signed_by_no_list(t, i, sigs)
}

test tx_signed_by_list() {
  let sigs = t.testSignatories()

  let t =
    placeholder()
      |> fn(transaction) {
          Transaction { ..transaction, extra_signatories: t.testSignatories() }
        }
  ok.tx_signed_by_list(t, sigs)
}

// FIX ME //
// test token_metadata_name_check() {
//   let in =
//     ok.TokenMetadata { name: #"face", image: #"cafe", mediaType: #"dead" }
//   let out =
//     ok.TokenMetadata { name: #"face", image: #"beef", mediaType: #"dead" }
//   ok.token_metadata_name_check(in, out)
// }

// compare_token_names
// init_68_datum

test make_token_names() {
  let tn = "face"
  ok.make_token_names(tn) == ["face", "face"]
}

test make_token_prefix() {
  ok.make_token_prefix() == [#"000643b0", #"000de140"]
}

test token_pair_prefix() {
  let tn = #"face"
  ok.token_pair_prefix(tn) == [#"000643b0face", #"000de140face"]
}

test make_fraction_prefix() {
  ok.make_fraction_prefix() == [#"000643b0", #"001bc280"]
}

test fraction_pair_prefix() {
  let tn = #"face"
  ok.fraction_pair_prefix(tn) == [#"000643b0face", #"001bc280face"]
}

test has_one_singleton_asset_less() {
  let p: value.PolicyId = #"dead"
  let t: value.AssetName = #"cafe"
  let in = value.from_asset(p, t, 2)
  let out = value.from_asset(p, t, 1)

  ok.has_one_singleton_asset_less(in, out)
}

test how_many_tokens() {
  let p: value.PolicyId = #"dead"
  let t: value.AssetName = #"cafe"
  let v = value.from_asset(p, t, 2)

  ok.how_many_tokens(v, p) == 2
}

test has_ref_with_policy() {
  let p: value.PolicyId = #"dead"
  let refIn =
    Input {
      output_reference: t.testOref(#"face", 2),
      output: t.testOutput(
        t.testAddress(#"face"),
        value.merge(t.makeAdaValue(10), value.from_asset(p, #"", 1)),
        NoDatum,
      ),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(t.testOref(#"cafe", 5)),
      transaction: placeholder()
        |> fn(transaction) {
            Transaction { ..transaction, reference_inputs: [refIn] }
          },
    }
  ok.has_ref_with_policy(ctx, p)
}
