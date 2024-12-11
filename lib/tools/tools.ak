use aiken/collection/dict
use aiken/collection/list
use aiken/crypto.{ScriptHash, VerificationKeyHash}
use aiken/interval.{Interval, IntervalBound, NegativeInfinity, PositiveInfinity}
use cardano/address.{
  Address, Credential, Inline, Referenced, Script, VerificationKey,
}
use cardano/assets.{AssetName, PolicyId, Value}
use cardano/script_context.{
  Minting, ScriptContext, ScriptInfo, Spending, Withdrawing,
}
use cardano/transaction.{
  Datum, InlineDatum, Input, NoDatum, Output, OutputReference, ScriptPurpose,
  Spend, Transaction, TransactionId,
}

//            //
// UTxO Tools //
//            //

pub fn minValue() -> Value {
  assets.from_lovelace(2000000)
}

pub fn singletonTxValue(p: PolicyId, a: AssetName) -> Value {
  let tokenValue = assets.from_asset(p, a, 1)

  assets.merge(minValue(), tokenValue)
}

pub fn multiTokenTxValue(p: PolicyId, a: AssetName, i: Int) -> Value {
  let tokenValue = assets.from_asset(p, a, i)

  assets.merge(minValue(), tokenValue)
}

pub fn multiAssetTxValue(p: PolicyId, a1: AssetName, a2: AssetName) -> Value {
  let tokenValue1 = tokenValue(p, a1, 1)
  let tokenValue2 = tokenValue(p, a2, 1)

  assets.merge(tokenValue1, tokenValue2)
}

pub fn multiPolicyTxValue(vs: List<Value>, i: int) -> Value {
  list.reduce(vs, assets.zero, assets.merge)
}

//        //
// Assets //
//        //

pub fn tokenValue(p: PolicyId, a: AssetName, i: Int) -> Value {
  assets.from_asset(p, a, i)
}

pub fn emptyNameValue(p: PolicyId, i: Int) -> Value {
  assets.from_asset(p, #"", i)
}

//                 //
// Basic Functions //
//                 //

pub fn makeAdaValue(l: Int) -> Value {
  assets.from_lovelace(l * 1000000)
}
