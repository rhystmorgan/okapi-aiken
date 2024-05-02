use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/interval.{Interval, IntervalBound, NegativeInfinity, PositiveInfinity}
use aiken/list.{any, filter, has}
use aiken/transaction.{
  Datum, InlineDatum, Input, Mint, NoDatum, Output, OutputReference,
  ScriptContext, ScriptPurpose, Spend, Transaction, TransactionId,
}
use aiken/transaction/credential.{
  Address, Script, VerificationKey, VerificationKeyCredential,
}
use aiken/transaction/value.{AssetName, PolicyId, Value, policies}

// Testing Tools

// This lib contains functions to create dummy data for testing

pub type ScriptHash =
  Hash<Blake2b_224, Script>

pub fn makePolicyId(s: ScriptHash) -> PolicyId {
  let policy = s
  policy
}

pub fn make_asset_name(tn: ByteArray) -> AssetName {
  let an = tn
  an
}

pub fn test_value_with_token() {
  todo
}

pub fn makeAdaValue(l: Int) -> Value {
  value.from_lovelace(l * 1000000)
}

// Create Input
pub fn test_input(oref: OutputReference, out: Output) -> Input {
  let in: Input = Input { output_reference: oref, output: out }
  in
}

pub fn test_output(a: Address, v: value.Value, d: Datum) -> Output {
  let out: Output =
    Output { address: a, value: v, datum: d, reference_script: None }
  out
}

// Create an OutputReference
pub fn test_oref(h: ByteArray, i: Int) -> OutputReference {
  let oref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: h },
      output_index: i,
    }
  oref
}

pub fn test_tx_id(h: ByteArray) -> TransactionId {
  let txid = TransactionId { hash: h }
  txid
}

// Create ScriptContext
pub fn test_context(t: Transaction, p: ScriptPurpose) -> ScriptContext {
  let ctx = ScriptContext { transaction: t, purpose: p }
  ctx
}

// Create ScriptPurpose
pub fn test_mint_purpose(p: value.PolicyId) -> ScriptPurpose {
  Mint(p)
}

pub fn test_spend_purpose(o: OutputReference) -> ScriptPurpose {
  Spend(o)
}

// Create Transaction
pub fn test_transaction() -> Transaction {
  let t =
    Transaction {
      ..transaction.placeholder(),
      inputs: [
        Input {
          output_reference: OutputReference {
            transaction_id: TransactionId { hash: #"" },
            output_index: 1,
          },
          output: Output {
            address: test_script_address(#"face"),
            value: value.from_lovelace(5),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: test_script_address(#"face"),
          value: value.from_lovelace(5),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      fee: value.zero(),
      mint: value.to_minted_value(value.zero()),
      withdrawals: dict.new(),
      validity_range: Interval {
        lower_bound: IntervalBound {
          bound_type: NegativeInfinity,
          is_inclusive: True,
        },
        upper_bound: IntervalBound {
          bound_type: PositiveInfinity,
          is_inclusive: True,
        },
      },
      extra_signatories: test_signatories(),
      id: TransactionId { hash: #"" },
    }
  t
}

pub fn test_address(pkh: Hash<Blake2b_224, VerificationKey>) -> Address {
  let addr =
    Address {
      payment_credential: VerificationKeyCredential(pkh),
      stake_credential: None,
    }
  addr
}

pub fn test_script_address(s: Hash<Blake2b_224, Script>) -> Address {
  credential.from_script(s)
}

pub fn test_signatories() -> List<ByteArray> {
  [#"face"]
}

pub fn testInlineDatum(d: Data) -> Datum {
  let datum = InlineDatum(d)
  datum
}
// fake input 10ADA
