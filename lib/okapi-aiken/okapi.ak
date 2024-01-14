use aiken/builtin
use aiken/bytearray
use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/string
use aiken/transaction.{
  Input, Mint, Output, OutputReference, ScriptContext, Spend, Transaction,
  find_input, find_script_outputs,
}
use aiken/transaction/credential.{Script, ScriptCredential, VerificationKey}
use aiken/transaction/value.{AssetName, PolicyId, Value, lovelace_of}

// This is a module of Helper Functions to make building Validators much simpler
// Just like Plutarch-Extra 

// For maximum awesomeness: 
// Use okapi as ok 

pub type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

pub type ScriptHash =
  Hash<Blake2b_224, Script>

pub type TokenDatum {
  metadata: TokenMetadata,
  version: Int,
}

pub type TokenMetadata {
  name: ByteArray,
  image: ByteArray,
  mediaType: ByteArray,
}

// const refPrefix = "100"
pub const refPrefix = #"000643b0"

// const userPrefix = "222"
pub const userPrefix = #"000de140"

// const fracPrefix = "444"
pub const fracPrefix = #"001bc280"

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
  tn: ByteArray,
  image: ByteArray,
  mediaType: ByteArray,
) -> TokenDatum {
  let metadata = TokenMetadata { name: tn, image, mediaType }
  let version = 1
  TokenDatum { metadata, version }
}

pub fn make_token_names(tn) -> List<value.AssetName> {
  let tokenName: value.AssetName = tn

  let refTn = tokenName

  let userTn = tokenName

  [refTn, userTn]
}

pub fn make_token_prefix() {
  let ref_asset: value.AssetName = refPrefix
  let user_asset: value.AssetName = userPrefix
  [ref_asset, user_asset]
}

pub fn token_pair_prefix(tn) {
  let token_name_list = make_token_names(tn)
  let token_name_prefix = make_token_prefix()

  list.map2(
    token_name_prefix,
    token_name_list,
    fn(a, b) { bytearray.concat(a, b) },
  )
}

pub fn make_fraction_prefix() {
  let ref_asset: value.AssetName = refPrefix
  let frac_asset: value.AssetName = fracPrefix
  [ref_asset, frac_asset]
}

pub fn fraction_pair_prefix(tn) {
  let token_name_list = make_token_names(tn)
  let token_name_prefix = make_fraction_prefix()

  list.map2(
    token_name_prefix,
    token_name_list,
    fn(a, b) { bytearray.concat(a, b) },
  )
}

pub fn has_one_singleton_asset_less(in: Value, out: Value) -> Bool {
  expect Some(policy_id) =
    value.without_lovelace(in)
      |> value.policies()
      |> list.head()
  how_many_tokens(out, policy_id) == how_many_tokens(in, policy_id) - 1
}

pub fn how_many_tokens(v: Value, p: PolicyId) -> Int {
  let token_count = dict.values(value.tokens(v, p))
  expect Some(n) =
    value.tokens(v, p)
      |> dict.values()
      |> list.head()
  n
}

pub fn datum_match(in: Output, out: Output) -> Bool {
  in.datum == out.datum
}
// ideas 

// && list -> so you can just line your functions up and return a bool

// pub fn to_datum(raw: Data) -> types.Datum {
//   expect parsed: types.Datum = raw
//   parsed
// }

// expect is inlined so you can save a whole bunch of space doing this

// list.any(outputs, fn(output) {
//   when output.datum {
//     InlineDatum(raw_data) ->
//       raw_data == thing
//     _ -> False
//   }
// })
