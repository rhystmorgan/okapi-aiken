use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/interval.{Interval, IntervalBound, NegativeInfinity, PositiveInfinity}
use aiken/list.{any, filter, has}
use aiken/transaction.{
  Datum, InlineDatum, Input, Mint, NoDatum, Output, OutputReference,
  ScriptContext, ScriptPurpose, Spend, Transaction, TransactionId, WithdrawFrom,
}
use aiken/transaction/credential.{
  Address, Credential, Inline, Referenced, Script, ScriptCredential,
  VerificationKey, VerificationKeyCredential,
}
use aiken/transaction/value.{AssetName, MintedValue, PolicyId, Value, policies}

//               //
// Testing Tools //
//               //

// This lib contains functions to create dummy data for testing

//        //
// Values //
//        //

pub const aced = #"aced"

pub const beef = #"beef"

pub const cafe = #"cafe"

pub const cece = #"cece"

pub const dead = #"dead"

pub const deaf = #"deaf"

pub const face = #"face"

pub const feed = #"feed"

pub const oracleMintHash =
  #"d07d942ea4581f003c2daa0e14799a2ab10063eea81bcf0ea90d1841"

pub const oracleValHash =
  #"e1c6e35d758c4ca601331073f4a02f30cf8bfbd465625e2bce4b8597"

//            //
// UTxO Tools //
//            //

pub fn minValue() -> Value {
  value.from_lovelace(2000000)
}

pub fn singletonTxValue(p: PolicyId, a: AssetName) -> Value {
  let tokenValue = value.from_asset(p, a, 1)

  value.merge(minValue(), tokenValue)
}

pub fn multiTokenTxValue(p: PolicyId, a: AssetName, i: Int) -> Value {
  let tokenValue = value.from_asset(p, a, i)

  value.merge(minValue(), tokenValue)
}

pub fn multiAssetTxValue(p: PolicyId, a1: AssetName, a2: AssetName) -> Value {
  let tokenValue1 = tokenValue(p, a1, 1)
  let tokenValue2 = tokenValue(p, a2, 1)

  value.merge(tokenValue1, tokenValue2)
}

pub fn multiPolicyTxValue(vs: List<Value>, i: int) -> Value {
  list.reduce(vs, value.zero(), value.merge)
}

//        //
// Assets //
//        //

pub fn tokenValue(p: PolicyId, a: AssetName, i: Int) -> Value {
  value.from_asset(p, a, i)
}

pub fn emptyNameValue(p: PolicyId, i: Int) -> Value {
  value.from_asset(p, #"", i)
}

pub fn tokenMintedValue(p: PolicyId, a: AssetName, i: Int) -> MintedValue {
  value.to_minted_value(tokenValue(p, a, i))
}

pub fn emptyNameMintedValue(p: PolicyId, i: Int) -> MintedValue {
  value.to_minted_value(emptyNameValue(p, i))
}

//                 //
// Basic Functions //
//                 //

pub type ScriptHash =
  Hash<Blake2b_224, Script>

pub fn makePolicyId(s: ScriptHash) -> PolicyId {
  let policy = s
  policy
}

pub fn makeAssetName(tn: ByteArray) -> AssetName {
  let an = tn
  an
}

pub fn makeAdaValue(l: Int) -> Value {
  value.from_lovelace(l * 1000000)
}

// Create Input
pub fn testInput(oref: OutputReference, out: Output) -> Input {
  let in: Input = Input { output_reference: oref, output: out }
  in
}

pub fn testOutput(a: Address, v: value.Value, d: Datum) -> Output {
  let out: Output =
    Output { address: a, value: v, datum: d, reference_script: None }
  out
}

// Create an OutputReference
pub fn testOref(h: ByteArray, i: Int) -> OutputReference {
  let oref: OutputReference =
    OutputReference {
      transaction_id: TransactionId { hash: h },
      output_index: i,
    }
  oref
}

pub fn testTxId(h: ByteArray) -> TransactionId {
  let txid = TransactionId { hash: h }
  txid
}

// Create ScriptContext
pub fn testContext(t: Transaction, p: ScriptPurpose) -> ScriptContext {
  let ctx = ScriptContext { transaction: t, purpose: p }
  ctx
}

// Create ScriptPurpose
pub fn testMintPurpose(p: value.PolicyId) -> ScriptPurpose {
  Mint(p)
}

pub fn testSpendPurpose(o: OutputReference) -> ScriptPurpose {
  Spend(o)
}

// Create Transaction
pub fn testTransaction() -> Transaction {
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
            address: testScriptAddress(#"face"),
            value: value.from_lovelace(5),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: testScriptAddress(#"face"),
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
      extra_signatories: testSignatories(),
      id: TransactionId { hash: #"" },
    }
  t
}

pub fn testAddress(pkh: Hash<Blake2b_224, VerificationKey>) -> Address {
  let addr =
    Address {
      payment_credential: VerificationKeyCredential(pkh),
      stake_credential: None,
    }
  addr
}

pub fn testScriptAddress(s: Hash<Blake2b_224, Script>) -> Address {
  credential.from_script(s)
}

pub fn testSignatories() -> List<ByteArray> {
  [#"face"]
}

pub fn testInlineDatum(d: Data) -> Datum {
  let datum = InlineDatum(d)
  datum
}

// fake input 10ADA
pub fn createStakeCredential(
  s: Hash<Blake2b_224, Script>,
) -> Referenced<Credential> {
  Inline(ScriptCredential(s))
}

pub fn stakeCompare(
  left: Referenced<Credential>,
  right: Referenced<Credential>,
) -> Ordering {
  if left == right {
    Equal
  } else {
    Less
  }
}

pub fn scriptCompare(_left: ScriptPurpose, _right: ScriptPurpose) -> Ordering {
  Less
}

pub fn withPurpose(hash: ByteArray) -> ScriptPurpose {
  let stake = createStakeCredential(hash)
  WithdrawFrom(stake)
}
