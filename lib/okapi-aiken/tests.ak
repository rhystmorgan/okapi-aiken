use aiken/list
use aiken/transaction.{
  Input, NoDatum, OutputReference, ScriptContext, Spend, Transaction,
  TransactionId, placeholder,
}
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

test get_own_input() {
  let addr = t.test_script_address(#"face")
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
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
  let addr = t.test_script_address(#"face")
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
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
  let addr = t.test_script_address(#"face")
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
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
  let addr = t.test_script_address(#"face")

  let outs =
    [
      t.test_output(addr, value.from_lovelace(5), NoDatum),
      t.test_output(addr, value.from_lovelace(10), NoDatum),
      t.test_output(addr, value.from_lovelace(5), NoDatum),
    ]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
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
  let addr = t.test_script_address(#"face")

  let outs =
    [t.test_output(addr, value.from_lovelace(5), NoDatum)]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
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
  let addr = t.test_script_address(#"face")

  let outs =
    [
      t.test_output(addr, value.from_lovelace(5), NoDatum),
      t.test_output(addr, value.from_lovelace(10), NoDatum),
      t.test_output(addr, value.from_lovelace(5), NoDatum),
    ]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
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
  let addr = t.test_script_address(#"face")

  let outs =
    [t.test_output(addr, value.from_lovelace(5), NoDatum)]

  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }

  let pinput =
    Input {
      output_reference: placeholder_utxo,
      output: t.test_output(addr, value.from_lovelace(5), NoDatum),
    }

  let ctx =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: placeholder()
        |> fn(transaction) {
             Transaction { ..transaction, inputs: [pinput], outputs: outs }
           },
    }
  ok.get_own_singleton_output(ctx) == t.test_output(
    addr,
    value.from_lovelace(5),
    NoDatum,
  )
}
// get_own_singleton_output_value
// keep_own_lovelace_value
// contains_single_token_of 
// contains_only_lovelace
// tx_signed_by 
// tx_signed_by_no_list 
// tx_signed_by_list
// token_metadata_name_check
// compare_token_names
// init_68_datum
// make_token_names
// make_token_prefix 
// token_pair_prefix
// make_fraction_prefix
// fraction_pair_prefix
// has_one_singleton_asset_less 
// how_many_tokens
