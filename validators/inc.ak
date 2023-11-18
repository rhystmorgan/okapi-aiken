use aiken/builtin
use aiken/bytearray
use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/string
use aiken/transaction.{
  Datum, InlineDatum, Input, Output, OutputReference, ScriptContext, Transaction,
} as tx
use aiken/transaction/credential.{
  Script, ScriptCredential, VerificationKey, VerificationKeyCredential,
}
use aiken/transaction/value

// const refPrefix = #"000643b0"

const refPrefix = "100"

// const userPrefix = #"000de140"

const userPrefix = "222"

const mediaType = "image/png"

const initImage = "ipfs//1234"

type Action {
  AMint
  ABurn
}

type MintAction {
  Mint { tn: ByteArray }
  Burn { tn: ByteArray }
}

type MetadataAction {
  Update { metadata: Data, user: VerificationKeyHash }
  Remove { owner: VerificationKeyHash }
}

type ReferenceAction {
  UpdateRef { metadata_script_hash: ScriptHash }
  RemoveRef
}

type RefMintAction {
  MintRef { script_hash: ScriptHash, metadata_script_hash: ScriptHash }
  BurnRef
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

type ReferenceDatum {
  metadata_script_hash: ScriptHash,
  refCS: value.PolicyId,
}

type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

type ScriptHash =
  Hash<Blake2b_224, Script>

// Helper functions

fn compareTokenNames(an: value.AssetName, tn: Option<ByteArray>) -> Bool {
  expect Some(tn) = tn

  an == tn
}

fn init_datum(tn, image, mediaType) {
  [
    (builtin.b_data("name"), builtin.b_data(tn)),
    (builtin.b_data("image"), builtin.b_data(image)),
    (builtin.b_data("mediaType"), builtin.b_data(mediaType)),
  ]
}

fn new_datum(dat: TokenDatum, metadata: TokenMetadata) {
  TokenDatum { metadata, version: dat.version + 1 }
}

fn init_ref_datum(metadata_script_hash: ScriptHash, refCS: value.PolicyId) {
  ReferenceDatum { metadata_script_hash, refCS }
}

fn makeTokenNames(tn) -> List<value.AssetName> {
  let refTn = bytearray.concat(refPrefix, tn)

  let userTn = bytearray.concat(userPrefix, tn)
  [refTn, userTn]
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

//                          //
// mint tokens //
//                          //

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
        let tokenNameList = makeTokenNames("IncTest4")

        expect Some(tokenName) = list.head(tokenNameList)
        let trace_ref_tn = string.from_bytearray(tokenName)

        trace trace_ref_tn

        let ref_tn_check =
          compareTokenNames(ref_asset_name, list.at(tokenNameList, 0))

        let user_tn_check =
          compareTokenNames(user_asset_name, list.at(tokenNameList, 1))

        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      ABurn -> ref_amount == -1 && user_amount == -1
    }
  }
}
//                          //
// mint token with sr datum //
//                          //

// validator {
//   fn mint222(r: MintAction, ctx: ScriptContext) -> Bool {
//     let ScriptContext { transaction, purpose } = ctx
//     expect tx.Mint(policy_id) = purpose

//     let Transaction { mint, outputs, .. } = transaction

//     expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
//       mint
//         |> value.from_minted_value
//         |> value.tokens(policy_id)
//         |> dict.to_list()

//     expect Some(output) = list.at(transaction.outputs, 0)

//     let tx.Output { value, datum, .. } = output

//     expect InlineDatum(datum) = output.datum
//     expect datum: TokenDatum = datum

//     when r is {
//       Mint { tn } -> {
//         expect list.length(transaction.outputs) == 3
//         expect value.quantity_of(output.value, policy_id, ref_asset_name) == 1
//         // && builtin.serialise_data(
//         //   datum.metadata,
//         // ) == builtin.serialise_data(
//         //   init_datum(
//         //     tn,
//         //     bytearray.to_string(initImage),
//         //     bytearray.to_string(mediaType),
//         //   ),
//         // )
//         let tokenNameList = makeTokenNames(tn)
//         let ref_tn_check =
//           compareTokenNames(ref_asset_name, list.at(tokenNameList, 0))

//         let user_tn_check =
//           compareTokenNames(user_asset_name, list.at(tokenNameList, 1))

//         ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
//       }
//       Burn { tn } -> ref_amount == -1 && user_amount == -1
//     }
//   }
// }
// mint token to locking address with datum
// update version number with tx 
// add ssongs or images to metadata

// try again with reference input of val hash 
// so we know where to mint and 
// locking contract knows the CS

// not working -> && datum.metadata == builtin.map_data(init_datum("IncTest4", initImage, mediaType),)
