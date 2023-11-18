// CIP68 minting contracts from SoundRig //

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
const refPrefix: ByteArray = "100"

// const userPrefix = #"000de140"
const userPrefix: ByteArray = "222"

const mediaType = "image/png"

const initImage = "ipfs//1234"

type MintAction {
  Mint { tn: String }
  Burn { tn: String }
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
  metadata: Data,
  version: Int,
}

// type TokenMetadata {
//   name: String,
//   image: String,
//   mediaType: String
// }

type ReferenceDatum {
  metadata_script_hash: ScriptHash,
  refCS: value.PolicyId,
}

type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

type ScriptHash =
  Hash<Blake2b_224, Script>

fn compareTokenNames(an: value.AssetName, tn: Option<ByteArray>) -> Bool {
  expect Some(tn) = tn

  an == tn
}

fn init_datum(tn: String, image: String, mediaType: String) {
  [("name", tn), ("image", image), ("mediaType", mediaType)]
}

fn new_datum(dat: TokenDatum, metadata: Data) {
  TokenDatum { metadata, version: dat.version + 1 }
}

fn init_ref_datum(metadata_script_hash: ScriptHash, refCS: value.PolicyId) {
  ReferenceDatum { metadata_script_hash, refCS }
}

fn makeTokenNames(tn: String) -> List<value.AssetName> {
  let refTn = bytearray.concat(refPrefix, string.to_bytearray(tn))

  let userTn = bytearray.concat(userPrefix, string.to_bytearray(tn))
  [refTn, userTn]
}

validator(owner: VerificationKeyHash) {
  fn mint68(r: MintAction, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction {
      inputs,
      mint,
      outputs,
      extra_signatories,
      reference_inputs,
      ..
    } = transaction

    expect Some(input) =
      transaction.reference_inputs
        |> list.head()

    let tx.Input { output, .. } = input
    expect InlineDatum(datum) = output.datum
    expect datum: ReferenceDatum = datum
    let ref_datum = datum

    expect [(ref_asset_name, ref_amount), (user_asset_name, user_amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    expect Some(output) =
      transaction.outputs
        |> tx.find_script_outputs(datum.metadata_script_hash)
        |> list.head()

    let tx.Output { value, datum, .. } = output

    expect InlineDatum(datum) = output.datum
    expect datum: TokenDatum = datum

    when r is {
      Mint { tn } -> {
        expect
          list.any(
            outputs,
            fn(output) {
              builtin.serialise_data(output.address.payment_credential) == ref_datum.metadata_script_hash && value.quantity_of(
                output.value,
                policy_id,
                ref_asset_name,
              ) == 1 && builtin.serialise_data(datum.metadata) == builtin.serialise_data(
                init_datum(
                  tn,
                  bytearray.to_string(initImage),
                  bytearray.to_string(mediaType),
                ),
              )
            },
          )
        let tokenNameList = makeTokenNames(tn)

        let ref_tn_check =
          compareTokenNames(ref_asset_name, list.at(tokenNameList, 0))

        let user_tn_check =
          compareTokenNames(user_asset_name, list.at(tokenNameList, 1))

        ref_amount == 1 && user_amount == 1 && ref_tn_check? && user_tn_check?
      }
      Burn { tn } -> ref_amount == -1 && user_amount == -1
    }
  }
}

validator(cs: value.PolicyId) {
  fn metadata_validator(
    dat: TokenDatum,
    red: MetadataAction,
    ctx: ScriptContext,
  ) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Spend(ownRef) = purpose

    let Transaction { inputs, mint, outputs, extra_signatories, .. } =
      transaction

    expect Some(input) =
      transaction.inputs
        |> tx.find_input(ownRef)

    let tx.Input { output, .. } = input

    expect ScriptCredential(script_hash) =
      input.output.address.payment_credential

    expect Some(output) =
      transaction.outputs
        |> tx.find_script_outputs(script_hash)
        |> list.head()

    let tx.Output { value, datum, .. } = output

    expect InlineDatum(datum) = output.datum
    expect datum: TokenDatum = datum

    let input_cs = dict.values(value.tokens(input.output.value, cs)) == [1]
    let output_cs = dict.values(value.tokens(output.value, cs)) == [1]

    let lovelace_value_check =
      value.lovelace_of(input.output.value) <= value.lovelace_of(output.value)

    let metadata_name_check =
      list.at(builtin.un_map_data(datum.metadata), 0) == list.at(
        builtin.un_map_data(dat.metadata),
        0,
      )

    when red is {
      Update { metadata, user } -> {
        let tx_signed_by_user = list.has(transaction.extra_signatories, user)

        input_cs? && output_cs? && lovelace_value_check? && metadata_name_check? && tx_signed_by_user?
      }
      Remove { owner } -> {
        let tx_signed_by_owner = list.has(transaction.extra_signatories, owner)

        input_cs? && tx_signed_by_owner?
      }
    }
  }
}

validator(owner: VerificationKeyHash) {
  fn reference_validator(
    dat: ReferenceDatum,
    red: ReferenceAction,
    ctx: ScriptContext,
  ) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Spend(ownRef) = purpose

    let Transaction { inputs, outputs, extra_signatories, .. } = transaction

    expect Some(input) =
      transaction.inputs
        |> tx.find_input(ownRef)

    let tx.Input { output, .. } = input

    expect ScriptCredential(script_hash) =
      input.output.address.payment_credential

    expect Some(output) =
      transaction.outputs
        |> tx.find_script_outputs(script_hash)
        |> list.head()

    let tx.Output { value, datum, .. } = output

    expect InlineDatum(datum) = output.datum
    expect datum: ReferenceDatum = datum

    let lovelace_value_check =
      value.lovelace_of(input.output.value) <= value.lovelace_of(output.value)

    let tx_signed_by = list.has(transaction.extra_signatories, owner)

    let datum_refCS_check = datum.refCS == dat.refCS

    let input_cs =
      dict.values(value.tokens(input.output.value, dat.refCS)) == [1]
    let output_cs = dict.values(value.tokens(output.value, dat.refCS)) == [1]

    when red is {
      UpdateRef { metadata_script_hash } -> {
        let update_metadata_script =
          datum.metadata_script_hash == metadata_script_hash

        input_cs? && output_cs? && update_metadata_script? && datum_refCS_check? && lovelace_value_check? && tx_signed_by?
      }

      RemoveRef -> output_cs? && tx_signed_by?
    }
  }
}

validator(owner: VerificationKeyHash) {
  fn reference_mint(red: RefMintAction, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    expect tx.Mint(policy_id) = purpose

    let Transaction {
      inputs,
      mint,
      outputs,
      extra_signatories,
      reference_inputs,
      ..
    } = transaction

    expect [(asset_name, amount)] =
      mint
        |> value.from_minted_value
        |> value.tokens(policy_id)
        |> dict.to_list()

    when red is {
      MintRef { script_hash, metadata_script_hash } -> {
        expect Some(output) =
          transaction.outputs
            |> tx.find_script_outputs(script_hash)
            |> list.head()

        let tx.Output { value, datum, .. } = output

        expect InlineDatum(datum) = output.datum
        expect datum: ReferenceDatum = datum
        expect
          list.any(
            outputs,
            fn(output) {
              builtin.serialise_data(output.address.payment_credential) == script_hash && value.quantity_of(
                output.value,
                policy_id,
                asset_name,
              ) == 1 && datum == init_ref_datum(metadata_script_hash, policy_id)
            },
          )
        amount == 1
      }
      BurnRef -> amount == -1
    }
  }
}
