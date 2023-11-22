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
// const fracPrefix = #"001bc280"

// const mediaType = "image/png"

// const initImage = "ipfs//1234"

type Action {
  AMint
  ABurn
}

// type MintAction {
//   Mint { tn: ByteArray }
//   Burn { tn: ByteArray }
// }

type MetadataAction {
  a: Int,
  metadata: ok.TokenMetadata,
}

// type ReferenceAction {
//   UpdateRef { metadata_script_hash: ScriptHash }
//   RemoveRef
// }

// type RefMintAction {
//   MintRef { script_hash: ScriptHash, metadata_script_hash: ScriptHash }
//   BurnRef
// }

type TokenDatum {
  metadata: TokenMetadata,
  version: Int,
}

type TokenMetadata {
  name: ByteArray,
  image: ByteArray,
  mediaType: ByteArray,
}

type ReferenceDatum {
  metadata_script_hash: ScriptHash,
  refCS: value.PolicyId,
}

type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

type ScriptHash =
  Hash<Blake2b_224, Script>

// Helper functions

fn compare_token_names(an: value.AssetName, tn: Option<ByteArray>) -> Bool {
  expect Some(tn) = tn

  an == tn
}

fn init_datum(tn, image, mediaType) {
  TokenMetadata { name: tn, image, mediaType }
  // [("name", tn), ("image", image), ("mediaType", mediaType)]
}

fn new_datum(dat: TokenDatum, metadata: TokenMetadata) {
  TokenDatum { metadata, version: dat.version + 1 }
}

fn init_ref_datum(metadata_script_hash: ScriptHash, refCS: value.PolicyId) {
  ReferenceDatum { metadata_script_hash, refCS }
}

fn make_token_names(tn) -> List<value.AssetName> {
  let tokenName: value.AssetName = tn
  trace string.from_bytearray(tokenName)

  let refTn = tokenName
  trace string.from_bytearray(refTn)

  let userTn = tokenName
  trace string.from_bytearray(userTn)
  [refTn, userTn]
}

fn make_token_prefix() {
  let ref_asset: value.AssetName = refPrefix
  let user_asset: value.AssetName = userPrefix
  [ref_asset, user_asset]
}

fn token_pair_prefix(tn) {
  let token_name_list = make_token_names(tn)
  let token_name_prefix = make_token_prefix()

  list.map2(
    token_name_prefix,
    token_name_list,
    fn(a, b) { bytearray.concat(a, b) },
  )
}

//             //
// mint tokens //
//             //

validator {
  fn mint(r: Action, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when r is {
      AMint -> {
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, ref_asset_name) == 1
            },
          ) && list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == 1
            },
          )
        ref_amount == 1 && user_amount == 1
      }
      ABurn -> ref_amount == -1 && user_amount == -1
    }
  }
}

fn create_address(
  pkh: Hash<Blake2b_224, VerificationKey>,
  sc: Hash<Blake2b_224, VerificationKey>,
) -> Address {
  // empty bytearrays means dont add the sc to the pkh
  if bytearray.is_empty(sc) {
    credential.from_verification_key(pkh)
  } else {
    credential.from_verification_key(pkh)
      |> credential.with_delegation_key(sc)
  }
}

//             //
// mint tokens //
//             //

validator {
  fn mint1(r: Action, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when r is {
      AMint -> {
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, ref_asset_name) == 1
            },
          )
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == 1
            },
          )
        let token_name_list = token_pair_prefix("SRTRiot")
        let ref_tn_check =
          compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      ABurn -> ref_amount == -1 && user_amount == -1
    }
  }
}

//                                 //
// mint tokens with sr datum check //
//                                 //

validator {
  fn mint2(r: Action, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when r is {
      AMint -> {
        expect
          list.any(
            outputs,
            fn(output) {
              expect InlineDatum(datum) = output.datum
              // Cant check against Datum type (expect _datum: TokenDatum = datum)
              value.quantity_of(output.value, policy_id, ref_asset_name) == 1
            },
          )
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == 1
            },
          )
        let token_name_list = token_pair_prefix("SRTRiot")
        let ref_tn_check =
          compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      ABurn -> ref_amount == -1 && user_amount == -1
    }
  }
}

//                                //
// mint tokens with multiRedeemer //
//                                //

type MAction {
  a: Int,
  b: Int,
}

validator {
  fn mint3(r: MAction, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when r.a is {
      1 -> {
        expect
          list.any(
            outputs,
            fn(output) {
              expect InlineDatum(datum) = output.datum
              value.quantity_of(output.value, policy_id, ref_asset_name) == 1
            },
          )
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == 1
            },
          )
        let token_name_list = token_pair_prefix("IncTest5")
        let ref_tn_check =
          compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      _ -> ref_amount == -1 && user_amount == -1
    }
  }
}

//                                     //
// mint tokens with validator Redeemer //
//                                     //

type VAction {
  a: Int,
  b: ScriptHash,
}

validator {
  fn mint4(r: VAction, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when r.a is {
      1 -> {
        expect
          list.any(
            outputs,
            fn(output) {
              expect InlineDatum(datum) = output.datum
              value.quantity_of(output.value, policy_id, ref_asset_name) == 1
            },
          )
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == 1
            },
          )
        let token_name_list = token_pair_prefix("IncTest5")
        let ref_tn_check =
          compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      _ -> ref_amount == -1 && user_amount == -1
    }
  }
}

// target Validator //

type VestingDatum {
  Nothing
}

// Data.to(BigInt(0)) -> Hopefully

type VestingAction {
  Redeem
  Withdraw
}

validator {
  fn vest(d: VestingDatum, r: VestingAction, c: ScriptContext) -> Bool {
    when r is {
      Redeem -> {
        let out = ok.get_own_singleton_output(c)
        let in = ok.get_own_input(c)

        expect InlineDatum(datum) = out.datum
        expect datum: VestingDatum = datum

        ok.keep_own_lovelace_value(c) && ok.has_one_singleton_asset_less(
          in.value,
          out.value,
        ) && d == datum
      }
      Withdraw -> True
    }
  }
}

// type VAction {
//   a: Int,
//   b: ScriptHash,
// }

// type VestingDatum {
//   Nothing
// }

// // Data.to(BigInt(0)) -> Hopefully

// type VestingAction {
//   Redeem
//   Withdraw
// }

//                                         //
// mint tokens with params & lock Metadata //
//                                         //

validator(owner: VerificationKeyHash) {
  fn mint5(r: VAction, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction { mint, outputs, .. } = transaction

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when r.a is {
      1 -> {
        expect
          list.any(
            outputs,
            fn(output) {
              expect InlineDatum(datum) = output.datum
              value.quantity_of(output.value, policy_id, ref_asset_name) == 1
            },
          )
        expect
          list.any(
            outputs,
            fn(output) {
              value.quantity_of(output.value, policy_id, user_asset_name) == 1
            },
          )
        let token_name_list = ok.token_pair_prefix("IncTest5")
        let ref_tn_check =
          compare_token_names(ref_asset_name, list.at(token_name_list, 0))
        let user_tn_check =
          compare_token_names(user_asset_name, list.at(token_name_list, 1))
        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      _ -> ref_amount == -1 && user_amount == -1
    }
  }
}

// vesting Validator //

validator(owner: VerificationKeyHash) {
  fn pvest(d: VestingDatum, r: VestingAction, c: ScriptContext) -> Bool {
    when r is {
      Redeem -> {
        let out = ok.get_own_singleton_output(c)
        let in = ok.get_own_input(c)

        expect InlineDatum(datum) = out.datum
        expect datum: VestingDatum = datum

        ok.keep_own_lovelace_value(c) && ok.has_one_singleton_asset_less(
          in.value,
          out.value,
        ) && d == datum
      }
      Withdraw -> ok.tx_signed_by(c.transaction, owner)
    }
  }
}

// metadata Validator //

validator(owner: VerificationKeyHash, cs: PolicyId) {
  fn plock(d: TokenDatum, r: MetadataAction, c: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = c
    expect Spend(ownRef) = purpose

    let Transaction { outputs, .. } = transaction

    expect Some(input) =
      transaction.inputs
        |> find_input(ownRef)

    let Input { .. } = input

    expect ScriptCredential(script_hash) =
      input.output.address.payment_credential

    let input_cs = dict.values(tokens(input.output.value, cs)) == [1]

    when r.a is {
      1 -> {
        expect
          list.any(
            outputs,
            fn(output) {
              expect InlineDatum(datum) = output.datum
              let output_cs = dict.values(tokens(output.value, cs)) == [1]
              let lovelace_value_check =
                lovelace_of(input.output.value) <= lovelace_of(output.value)
              output.address == from_script(script_hash) && output_cs? && lovelace_value_check?
            },
          )
        input_cs? && ok.tx_signed_by(transaction, owner)?
      }
      _ -> ok.tx_signed_by(transaction, owner)?
    }
  }
}
