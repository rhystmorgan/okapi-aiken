// use aiken/builtin
// use aiken/collection/dict
// use aiken/collection/list
// use aiken/crypto.{ScriptHash, VerificationKeyHash}
// use aiken/primitive/bytearray
// use aiken/primitive/string
// use cardano/address.{Credential, Inline, Script, VerificationKey}
// use cardano/assets.{
//   AssetName, PolicyId, Value, lovelace_of, policies, quantity_of,
// }
// use cardano/script_context.{Minting, ScriptContext, Spending, Withdrawing}
// use cardano/transaction.{
//   InlineDatum, Input, Output, OutputReference, Redeemer, Transaction, find_input,
//   find_script_outputs,
// }

// // This is a module of Helper Functions to make building Validators much simpler
// // Just like Plutarch-Extra 

// // For maximum awesomeness: 
// // Use okapi as ok 

// pub type TokenDatum {
//   metadata: TokenMetadata,
//   version: Int,
// }

// pub type TokenMetadata {
//   name: ByteArray,
//   image: ByteArray,
//   mediaType: ByteArray,
// }

// // const refPrefix = "100"
// pub const refPrefix = #"000643b0"

// // const userPrefix = "222"
// pub const userPrefix = #"000de140"

// // const fracPrefix = "444"
// pub const fracPrefix = #"001bc280"

// pub fn get_spend_ref(ctx: ScriptContext) -> OutputReference {
//   expect Spending { output: ownRef, datum: d } = ctx.info
//   ownRef
// }

// pub fn get_policy_id(ctx: ScriptContext) -> PolicyId {
//   expect Minting(policy_id) = ctx.info
//   policy_id
// }

// pub fn get_own_input(ctx: ScriptContext) -> Output {
//   let oref = get_spend_ref(ctx)

//   expect Some(input) =
//     ctx.transaction.inputs
//       |> find_input(oref)

//   let Input { .. } = input
//   input.output
// }

// pub fn get_own_script_hash(ctx: ScriptContext) -> VerificationKeyHash {
//   let own_input = get_own_input(ctx)
//   expect Script(script_hash) = own_input.address.payment_credential
//   script_hash
// }

// pub fn get_own_input_value(ctx: ScriptContext) -> Value {
//   let own_input = get_own_input(ctx)
//   own_input.value
// }

// pub fn get_own_outputs(ctx: ScriptContext) -> List<Output> {
//   let script_hash = get_own_script_hash(ctx)

//   let outputs =
//     ctx.transaction.outputs
//       |> find_script_outputs(script_hash)

//   outputs
// }

// pub fn has_own_singleton_output(ctx: ScriptContext) -> Bool {
//   let script_hash = get_own_script_hash(ctx)

//   let script_outputs =
//     ctx.transaction.outputs
//       |> find_script_outputs(script_hash)

//   list.length(script_outputs) == 1
// }

// pub fn get_own_singleton_output(ctx: ScriptContext) -> Output {
//   let script_hash = get_own_script_hash(ctx)
//   expect has_own_singleton_output(ctx)
//   expect Some(output) =
//     ctx.transaction.outputs
//       |> find_script_outputs(script_hash)
//       |> list.head()

//   output
// }

// pub fn has_singleton_output(ctx: ScriptContext) -> Bool {
//   list.length(ctx.transaction.outputs) == 1
// }

// pub fn get_own_singleton_output_value(ctx: ScriptContext) -> Value {
//   let output = get_own_singleton_output(ctx)
//   output.value
// }

// pub fn keep_own_lovelace_value(ctx: ScriptContext) -> Bool {
//   let own_input_value = get_own_input_value(ctx)
//   let own_output_value = get_own_singleton_output_value(ctx)

//   lovelace_of(own_input_value) <= lovelace_of(own_output_value)
// }

// pub fn contains_single_token_of(value: Value, policy_id: PolicyId) -> Bool {
//   let token_count = dict.values(assets.tokens(value, policy_id))
//   token_count == [1]
// }

// pub fn contains_only_lovelace(value: Value) -> Bool {
//   let policy_count = assets.policies(value)
//   list.length(policy_count) == 1
// }

// pub fn tx_signed_by(tx: Transaction, key_hash: VerificationKeyHash) -> Bool {
//   let signatures = tx.extra_signatories
//   list.has(signatures, key_hash)
// }

// pub fn tx_signed_by_no_list(
//   tx: Transaction,
//   min: Int,
//   vkList: List<VerificationKeyHash>,
// ) -> Bool {
//   list.count(vkList, fn(vk) { list.has(tx.extra_signatories, vk) }) >= min
// }

// pub fn tx_signed_by_list(
//   tx: Transaction,
//   vkList: List<VerificationKeyHash>,
// ) -> Bool {
//   let sig_count =
//     list.count(vkList, fn(vk) { list.has(tx.extra_signatories, vk) })
//   sig_count == list.length(vkList)
// }

// pub fn token_metadata_name_check(
//   in_metadata: TokenMetadata,
//   out_metadata: TokenMetadata,
// ) -> Bool {
//   list.at(builtin.un_map_data(in_metadata), 0) == list.at(
//     builtin.un_map_data(out_metadata),
//     0,
//   )
// }

// pub fn compare_token_names(an: AssetName, tn: Option<ByteArray>) -> Bool {
//   expect Some(tn) = tn
//   an == tn
// }

// pub fn init_68_datum(
//   tn: ByteArray,
//   image: ByteArray,
//   mediaType: ByteArray,
// ) -> TokenDatum {
//   let metadata = TokenMetadata { name: tn, image, mediaType }
//   let version = 1
//   TokenDatum { metadata, version }
// }

// pub fn make_token_names(tn) -> List<AssetName> {
//   let tokenName: AssetName = tn

//   let refTn = tokenName

//   let userTn = tokenName

//   [refTn, userTn]
// }

// pub fn make_token_prefix() {
//   let ref_asset: AssetName = refPrefix
//   let user_asset: AssetName = userPrefix
//   [ref_asset, user_asset]
// }

// pub fn token_pair_prefix(tn) {
//   let token_name_list = make_token_names(tn)
//   let token_name_prefix = make_token_prefix()

//   list.map2(
//     token_name_prefix,
//     token_name_list,
//     fn(a, b) { bytearray.concat(a, b) },
//   )
// }

// pub fn make_fraction_prefix() {
//   let ref_asset: AssetName = refPrefix
//   let frac_asset: AssetName = fracPrefix
//   [ref_asset, frac_asset]
// }

// pub fn fraction_pair_prefix(tn) {
//   let token_name_list = make_token_names(tn)
//   let token_name_prefix = make_fraction_prefix()

//   list.map2(
//     token_name_prefix,
//     token_name_list,
//     fn(a, b) { bytearray.concat(a, b) },
//   )
// }

// pub fn has_one_singleton_asset_less(in: Value, out: Value) -> Bool {
//   expect Some(policy_id) =
//     assets.without_lovelace(in)
//       |> assets.policies()
//       |> list.head()
//   how_many_tokens(out, policy_id) == how_many_tokens(in, policy_id) - 1
// }

// pub fn how_many_tokens(v: Value, p: PolicyId) -> Int {
//   let token_count = dict.values(assets.tokens(v, p))
//   expect Some(n) =
//     assets.tokens(v, p)
//       |> dict.values()
//       |> list.head()
//   n
// }

// pub fn datum_match(in: Output, out: Output) -> Bool {
//   in.datum == out.datum
// }

// pub fn has_ref_with_policy(ctx: ScriptContext, policy: PolicyId) -> Bool {
//   list.any(
//     ctx.transaction.reference_inputs,
//     fn(ref) { list.has(policies(ref.output.value), policy) },
//   )
// }

// pub fn get_ref_with_policy(ctx: ScriptContext, policy: PolicyId) -> Input {
//   expect Some(refIn) =
//     list.find(
//       ctx.transaction.reference_inputs,
//       fn(ref) { list.has(policies(ref.output.value), policy) },
//     )

//   refIn
// }

// pub fn has_in_with_policy(ctx: ScriptContext, policy: PolicyId) -> Bool {
//   list.any(
//     ctx.transaction.inputs,
//     fn(ref) { list.has(policies(ref.output.value), policy) },
//   )
// }

// pub fn get_in_with_policy(ctx: ScriptContext, policy: PolicyId) -> Input {
//   expect Some(in) =
//     list.find(
//       ctx.transaction.inputs,
//       fn(input) { list.has(policies(input.output.value), policy) },
//     )

//   in
// }

// pub fn has_out_with_policy(ctx: ScriptContext, policy: PolicyId) -> Bool {
//   list.any(
//     ctx.transaction.outputs,
//     fn(output) { list.has(policies(output.value), policy) },
//   )
// }

// pub fn get_out_with_policy(ctx: ScriptContext, policy: PolicyId) -> Output {
//   expect Some(out) =
//     list.find(
//       ctx.transaction.outputs,
//       fn(output) { list.has(policies(output.value), policy) },
//     )
//   out
// }

// pub fn has_ref_with_token(
//   ctx: ScriptContext,
//   policy: PolicyId,
//   asset: AssetName,
// ) -> Bool {
//   list.any(
//     ctx.transaction.reference_inputs,
//     fn(input) { quantity_of(input.output.value, policy, asset) > 0 },
//   )
// }

// pub fn get_ref_with_token(
//   ctx: ScriptContext,
//   policy: PolicyId,
//   asset: AssetName,
// ) -> Input {
//   expect Some(refIn) =
//     list.find(
//       ctx.transaction.reference_inputs,
//       fn(input) { quantity_of(input.output.value, policy, asset) > 0 },
//     )
//   refIn
// }

// pub fn has_in_with_token(
//   ctx: ScriptContext,
//   policy: PolicyId,
//   asset: AssetName,
// ) -> Bool {
//   list.any(
//     ctx.transaction.inputs,
//     fn(input) { quantity_of(input.output.value, policy, asset) > 0 },
//   )
// }

// pub fn get_in_with_token(
//   ctx: ScriptContext,
//   policy: PolicyId,
//   asset: AssetName,
// ) -> Input {
//   expect Some(in) =
//     list.find(
//       ctx.transaction.inputs,
//       fn(input) { quantity_of(input.output.value, policy, asset) > 0 },
//     )
//   in
// }

// pub fn has_out_with_token(
//   ctx: ScriptContext,
//   policy: PolicyId,
//   asset: AssetName,
// ) -> Bool {
//   list.any(
//     ctx.transaction.outputs,
//     fn(output) { quantity_of(output.value, policy, asset) > 0 },
//   )
// }

// pub fn get_out_with_token(
//   ctx: ScriptContext,
//   policy: PolicyId,
//   asset: AssetName,
// ) -> Output {
//   expect Some(out) =
//     list.find(
//       ctx.transaction.outputs,
//       fn(output) { quantity_of(output.value, policy, asset) > 0 },
//     )
//   out
// }

// pub fn has_ref_with_credential(
//   ctx: ScriptContext,
//   credential: Credential,
// ) -> Bool {
//   list.any(
//     ctx.transaction.reference_inputs,
//     fn(ref) { ref.output.address.payment_credential == credential },
//   )
// }

// pub fn get_ref_with_credential(
//   ctx: ScriptContext,
//   credential: Credential,
// ) -> Input {
//   expect Some(in) =
//     list.find(
//       ctx.transaction.reference_inputs,
//       fn(ref) { ref.output.address.payment_credential == credential },
//     )
//   in
// }

// pub fn has_in_with_credential(
//   ctx: ScriptContext,
//   credential: Credential,
// ) -> Bool {
//   list.any(
//     ctx.transaction.inputs,
//     fn(input) { input.output.address.payment_credential == credential },
//   )
// }

// pub fn get_in_with_credential(
//   ctx: ScriptContext,
//   credential: Credential,
// ) -> Input {
//   expect Some(in) =
//     list.find(
//       ctx.transaction.inputs,
//       fn(input) { input.output.address.payment_credential == credential },
//     )
//   in
// }

// pub fn has_out_with_credential(
//   ctx: ScriptContext,
//   credential: Credential,
// ) -> Bool {
//   list.any(
//     ctx.transaction.outputs,
//     fn(output) { output.address.payment_credential == credential },
//   )
// }

// pub fn get_out_with_credential(
//   ctx: ScriptContext,
//   credential: Credential,
// ) -> Output {
//   expect Some(out) =
//     list.find(
//       ctx.transaction.outputs,
//       fn(output) { output.address.payment_credential == credential },
//     )
//   out
// }

// pub fn validateList(
//   validation_logic: fn(Output, Output) -> Bool,
//   loanVal: ScriptHash,
//   redeemer: List<(Int, Int)>,
//   tx: Transaction,
// ) -> Bool {
//   let Transaction { inputs, outputs, .. } = tx

//   let txList =
//     list.map(
//       redeemer,
//       fn(index) {
//         expect (in, out) = index
//         expect Some(input) = list.at(inputs, in)
//         expect Some(output) = list.at(outputs, out)
//         (input, output)
//       },
//     )

//   list.all(
//     txList,
//     fn(io) {
//       expect (input, output) = io
//       validation_logic(input.output, output)
//     },
//   )
// }

// pub fn withBurn(
//   checkBurn: fn(Output) -> Bool,
//   script: ScriptHash,
//   redeemer: List<Int>,
//   tx: Transaction,
// ) -> Bool {
//   let Transaction { inputs, .. } = tx

//   let txList =
//     list.map(
//       redeemer,
//       fn(index) {
//         let in = index
//         expect Some(input) = list.at(inputs, in)
//         input
//       },
//     )

//   list.all(txList, fn(input) { checkBurn(input.output) })
// }

// pub fn withdraw0(
//   withdrawal_logic: fn(Redeemer, ScriptHash, Transaction) -> Bool,
//   redeemer: Redeemer,
//   ctx: ScriptContext,
// ) -> Bool {
//   expect ScriptContext {
//     transaction: tx,
//     info: Withdrawing(stake_cred),
//     redeemer: Redeemer,
//   } = ctx

//   expect Inline(Script(own_validator)) = stake_cred

//   withdrawal_logic(redeemer, own_validator, tx)
// }

// pub fn merkel0(
//   validation_logic: fn(Output, Output) -> Bool,
//   redeemer: List<(Int, Int)>,
//   script: ScriptHash,
//   ctx: ScriptContext,
// ) -> Bool {
//   let ScriptContext { transaction: tx, .. } = ctx

//   let Transaction { inputs, outputs, .. } = tx

//   expect [(in_ix, out_ix)] = redeemer

//   expect Some(Input { output: in_utxo, output_reference: _in_ref }) =
//     inputs |> list.at(in_ix)

//   expect Some(out_utxo) = outputs |> list.at(out_ix)

//   validation_logic(in_utxo, out_utxo)
// }

// // pub fn to_datum(raw: Data) -> types.Datum {
// //   expect parsed: types.Datum = raw
// //   parsed
// // }

// // expect is inlined so you can save a whole bunch of space doing this

// // list.any(outputs, fn(output) {
// //   when output.datum {
// //     InlineDatum(raw_data) ->
// //       raw_data == thing
// //     _ -> False
// //   }
// // })
