use aiken/builtin
use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{
  Input, Mint, Output, OutputReference, ScriptContext, Spend, Transaction,
  find_input, find_script_outputs,
}
use aiken/transaction/credential.{Script, ScriptCredential, VerificationKey}
use aiken/transaction/value.{AssetName, PolicyId, Value, lovelace_of}

// This is a module of Helper Functions to make building Validators much simpler
// Just like Plutarch-Extra 

// Use okapi as ok 

pub type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

pub type ScriptHash =
  Hash<Blake2b_224, Script>

pub fn get_spend_ref(ctx: ScriptContext) -> OutputReference {
  expect Spend(ownRef) = ctx.purpose
  ownRef
}

pub fn get_policy_id(ctx: ScriptContext) -> PolicyId {
  expect Mint(policy_id) = ctx.purpose
  policy_id
}

pub fn get_own_input(ctx: ScriptContext) -> Output {
  let oref = get_spend_ref(ctx)

  expect Some(input) =
    ctx.transaction.inputs
      |> find_input(oref)

  let Input { .. } = input
  input.output
}

pub fn get_own_script_hash(ctx: ScriptContext) -> VerificationKeyHash {
  let own_input = get_own_input(ctx)
  expect ScriptCredential(script_hash) = own_input.address.payment_credential
  script_hash
}

pub fn get_own_input_value(ctx: ScriptContext) -> Value {
  let own_input = get_own_input(ctx)
  own_input.value
}

pub fn get_own_outputs(ctx: ScriptContext) -> List<Output> {
  let script_hash = get_own_script_hash(ctx)

  let outputs =
    ctx.transaction.outputs
      |> find_script_outputs(script_hash)

  outputs
}

pub fn has_own_singleton_output(ctx: ScriptContext) -> Bool {
  let script_hash = get_own_script_hash(ctx)

  let script_outputs =
    ctx.transaction.outputs
      |> find_script_outputs(script_hash)

  list.length(script_outputs) == 1
}

pub fn get_own_singleton_output(ctx: ScriptContext) -> Output {
  let script_hash = get_own_script_hash(ctx)
  expect has_own_singleton_output(ctx)
  expect Some(output) =
    ctx.transaction.outputs
      |> find_script_outputs(script_hash)
      |> list.head()

  output
}

pub fn has_singleton_output(ctx: ScriptContext) -> Bool {
  list.length(ctx.transaction.outputs) == 1
}

pub fn get_own_singleton_output_value(ctx: ScriptContext) -> Value {
  let output = get_own_singleton_output(ctx)
  output.value
}

pub fn keep_own_lovelace_value(ctx: ScriptContext) -> Bool {
  let own_input_value = get_own_input_value(ctx)
  let own_output_value = get_own_singleton_output_value(ctx)

  lovelace_of(own_input_value) <= lovelace_of(own_output_value)
}

pub fn contains_single_token_of(value: Value, policy_id: PolicyId) -> Bool {
  let token_count = dict.values(value.tokens(value, policy_id))
  token_count == [1]
}

pub fn contains_only_lovelace(value: Value) -> Bool {
  let policy_count = value.policies(value)
  list.length(policy_count) == 1
}

pub fn tx_signed_by(tx: Transaction, key_hash: VerificationKeyHash) -> Bool {
  let signatures = tx.extra_signatories
  list.has(signatures, key_hash)
}

pub fn tx_signed_by_no_list(
  tx: Transaction,
  min: Int,
  vkList: List<VerificationKeyHash>,
) -> Bool {
  list.count(vkList, fn(vk) { list.has(tx.extra_signatories, vk) }) >= min
}

pub fn tx_signed_by_list(
  tx: Transaction,
  vkList: List<VerificationKeyHash>,
) -> Bool {
  let sig_count =
    list.count(vkList, fn(vk) { list.has(tx.extra_signatories, vk) })
  sig_count == list.length(vkList)
}

pub type MetadataDatum {
  metadata: TokenMetadata,
  version: Int,
}

pub type TokenMetadata {
  name: String,
  image: String,
  mediaType: String,
}

pub fn token_metadata_name_check(
  in_metadata: TokenMetadata,
  out_metadata: TokenMetadata,
) -> Bool {
  list.at(builtin.un_map_data(in_metadata), 0) == list.at(
    builtin.un_map_data(out_metadata),
    0,
  )
}

pub fn compare_token_names(an: AssetName, tn: Option<ByteArray>) -> Bool {
  expect Some(tn) = tn
  an == tn
}

pub fn init_68_datum(
  tn: String,
  image: String,
  mediaType: String,
) -> MetadataDatum {
  let metadata = TokenMetadata { name: tn, image, mediaType }
  let version = 1
  MetadataDatum { metadata, version }
}
