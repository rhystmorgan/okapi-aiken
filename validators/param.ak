use aiken/bytearray
use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/string
use aiken/transaction.{
  InlineDatum, Input, Mint, Output, ScriptContext, Spend, Transaction,
  find_input, find_script_outputs,
} as tx
use aiken/transaction/credential.{
  Address, Script, ScriptCredential, VerificationKey, from_script,
}
use aiken/transaction/value.{PolicyId, lovelace_of, tokens}
use okapi_aiken/okapi as ok

// const refPrefix = "100"
const refPrefix = #"000643b0"

// const userPrefix = "222"
const userPrefix = #"000de140"

// const fracPrefix = "444"
const fracPrefix = #"001bc280"

type Action {
  AMint
  ABurn
}

type MetadataAction {
  a: Int,
  m: TokenMetadata,
}

type TokenDatum {
  metadata: TokenMetadata,
  version: Int,
}

type TokenMetadata {
  name: ByteArray,
  image: ByteArray,
  mediaType: ByteArray,
}

type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

type ScriptHash =
  Hash<Blake2b_224, Script>

type MintAction {
  a: Int,
  b: Int,
  tn: ByteArray,
}

type VAction {
  a: Int,
  b: ScriptHash,
}

// target Validator //

//                         //
// Param Vesting Validator //
//                         //

type VestingDatum {
  // transactions must have a datum or you cant spend them
  v: Int,
}

type VestingAction {
  a: Int,
  b: Int,
}

validator(owner: VerificationKeyHash) {
  fn pvest(d: VestingDatum, r: VestingAction, c: ScriptContext) -> Bool {
    when r.a is {
      1 -> {
        let out = ok.get_own_singleton_output(c)
        let in = ok.get_own_input(c)
        // ok.keep_own_lovelace_value(c)
        ok.has_one_singleton_asset_less(in.value, out.value)
      }
      _ -> ok.tx_signed_by(c.transaction, owner)
    }
  }
}

//                  //
// Param Token Mint //
//                  //

validator(owner: VerificationKeyHash) {
  fn pmint(r: MintAction, c: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = c
    expect Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    expect ok.tx_signed_by(c.transaction, owner)
    when r.a is {
      1 -> {
        expect Some(input) =
          transaction.reference_inputs
            |> list.head()

        let Input { output, .. } = input
        expect InlineDatum(datum) = output.datum
        expect datum: AuthDatum = datum
        let ref_datum = datum

        expect
          list.any(
            outputs,
            fn(output) {
              expect InlineDatum(datum) = output.datum
              expect datum: TokenDatum = datum
              output.address == from_script(ref_datum.a) && value.quantity_of(
                output.value,
                policy_id,
                ref_asset_name,
              ) == 1
            },
          )
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == r.b
            },
          )
        let token_name_list = ok.fraction_pair_prefix(r.tn)
        let ref_tn_check =
          ok.compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          ok.compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == 1 && user_amount == r.b && ref_tn_check? && user_tn_check?
      }
      _ -> {
        let token_name_list = ok.fraction_pair_prefix(r.tn)
        let ref_tn_check =
          ok.compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          ok.compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == -1 && user_amount == -r.b && ref_tn_check? && user_tn_check?
      }
    }
  }
}

//                         //
// Param Locking Validator //
//                         //

type LockingDatum {
  p: ByteArray,
}

type LockingAction {
  a: Int,
  b: Int,
}

validator(owner: VerificationKeyHash, cs: PolicyId) {
  fn plock(_d: Data, r: LockingAction, c: ScriptContext) -> Bool {
    when r.a is {
      1 ->
        // ok.has_own_singleton_output(c) && // let out_value = ok.get_own_singleton_output_value(c)
        // expect InlineDatum(datum) = out.datum
        // expect datum: TokenDatum = datum
        ok.contains_single_token_of(out.value, cs) && ok.tx_signed_by(
          c.transaction,
          owner,
        )
      _ -> ok.tx_signed_by(c.transaction, owner)
    }
  }
}

//                           //
// Auth Token Minting Policy //
//                           //

type AuthDatum {
  a: ScriptHash,
}

type AuthAction {
  a: Int,
  b: Int,
}

validator(owner: VerificationKeyHash) {
  fn authm(r: AuthAction, c: ScriptContext) -> Bool {
    when r.a is {
      1 -> ok.tx_signed_by(c.transaction, owner)
      _ -> ok.tx_signed_by(c.transaction, owner)
    }
  }
}

//                        //
// Auth Locking Validator //
//                        //

validator(owner: VerificationKeyHash, cs: PolicyId) {
  fn authl(d: AuthDatum, r: AuthAction, c: ScriptContext) -> Bool {
    when r.a is {
      1 ->
        ok.tx_signed_by(c.transaction, owner) && ok.keep_own_lovelace_value(c)
      _ -> ok.tx_signed_by(c.transaction, owner)
    }
  }
}
