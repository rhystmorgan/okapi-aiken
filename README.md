# Okapi

Okapi is a helper function library written aiken to make drafting cardano smart contracts easier and faster.

add the `lib/okapi-aiken` directory to your aiken project and import it with

```
use okapi-aiken/okapi as ok
```

now you can use any of the okapi helper functions to your validators

```rust
validator myValidator(o: VerificationKeyHash) {
  spend(d: Option<Datum>, r: Redeemer, oref: OutputReference, tx: Transaction) -> Bool {
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

validateList

withBurn

withdraw0

merkel0
listScriptInputs
inputOutputs

---

With the updates to PlutusV3 a lot of things have changed.

As part of the optimisation process I have gone through and removed many redundant 
or unnecessary functions that are unlikely to be needed.

I have also been through and optimised a lot of my draft functions to reduce the 
amount of data that needs to be passed around to save mem and cpu.

This has left me with more complex functions that can quickly return relevant 
transaction data to be used in other checks in validators.

I will be organising these functions into individual modules so they can be 
accessed based of script purposes and more general modules for more general 
functions.

As a lot of `ownHash` checks are only relevant to `spending` validation and 
likewise `Policy` checks for `minting` validation.

This along with some property based tests and example validators will hopefully 
make it easy to write common validation checks or access common data points 
without the need to duplicate massive amounts of code over multiple projects.

---

## Okapi V2

I have made a lot of changes as mentioned above, now Okapi is mainly more complex
functions that operate as a contained unit and return something small and specific
OR return a Bool.

Here is an overview of the functions: 

GENERAL:

- authTokenOutput()
- hasSingleInput()
- ownSingleOutput()
- validateScriptOutIx()
- mapTokenPairOut()
- mapTokenPairIO()

INOUT:

- listInputOutputs()
- listScriptIns()
- listScriptOuts()
- listScriptIO()
- checkTokenPairIO()
- getPolicyIO()

MINT: 

- mintTokens()
- mintToken()
- mint222() 
- mint444()
- makeRefFrom() TODO
- makeUserFrom() TODO
- makeFracFrom() TODO

SPEND: 

- getOrefInput()
- getOrefInputOut()
- getOrefScriptHash()
- getOrefDatumValue()
- ownSpendIO() 
- ownSingletonOutput()

TAG: 

- taggedOutput()
- taggendOuts()
- taggendInOut()

