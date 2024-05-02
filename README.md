# Okapi

Okapi is a helper function library written aiken to make drafting cardano smart contracts easier and faster.

add the `lib/okapi-aiken` directory to your aiken project and import it with

```
use okapi-aiken/okapi as ok
```

now you can use any of the okapi helper functions to your validators

```
validator(o: VerificationKeyCredential) {
  fn spend(d: Datum, r: Redeemer, c: ScriptContext) -> Bool {
    ok.tx_signed_by(c.transaction, o)
  }
}
```

## Okapi Function Library:

Token Datum && Metadata
CIP-68 Token prefixes
get_spend_ref
get_policy_id
get_own_input
get_own_script_hash
get_own_input_value
get_own_outputs
has_own_singleton_output
get_own_singleton_output
has_singleton_output
get_own_singleton_output_value
keep_own_lovelace_value
contains_single_token_of
contains_only_lovelace
tx_signed_by
tx_signed_by_no_list
tx_signed_by_list
token_metadata_name_check
compare_token_names
init_68_datum
make_token_names
make_token_prefix
token_pair_prefix
make_fraction_prefix
fraction_pair_prefix
has_one_singleton_asset_less
how_many_tokens
datum_match

has_ref_with_policy
get_ref_with_policy
has_in_with_policy
get_in_with_policy
has_out_with_policy
get_out_with_policy

has_ref_with_token
get_ref_with_token
has_in_with_token
get_in_with_token
has_out_with_token
get_out_with_token

has_ref_from_credential
get_ref_from_credential
has_input_from_credential
get_input_from_credential
has_output_from_credential
get_output_from_credential
