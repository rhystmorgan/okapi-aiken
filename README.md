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

---

With the updates to PlutusV3 a lot of things have changed.

As part of the optimisation process I have gone through and removed many redundant 
or unnecessary functions that are unlikely to be needed.

I have also been through and optimised a lot of my draft functions to reduce the 
amount of data that needs to be passed around to save mem and cpu.

This has left me with more complex functions that can quickly return relevant 
transaction data to be used in other checks in validators.

I will be organising these functions into individual modules so they can be 
accessed based on script purposes and more general modules for more general 
functions.

As a lot of `ownHash` checks are only relevant to `spending` validation and 
likewise `Policy` checks for `minting` validation.

This along with some property based tests and example validators will hopefully 
make it easy to write common validation checks or access common data points 
without the need to duplicate large amounts of code over multiple projects.

---

## Okapi V2

I have made a lot of changes as mentioned above, now Okapi is mainly more complex
functions that operate as a contained unit and return something small and specific
OR return a Bool.

Here is an overview of the functions: 

FAST:

- mustFind()
- mustFindInput()
- onlyMatch()

GENERAL:

- authTokenOutput()
- hasSingleInput()
- ownSingleOutput()
- validateScriptOutIx()
- mapTokenPairOut()

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
- makeRefFrom() 
- makeUserFrom() 
- makeFracFrom() 

SPEND:

- getOrefInput()
- getOrefInputOut()
- getOrefScriptHash()
- getOrefValue()
- getOrefDatumValue()
- ownSpendIO() 
- ownSingletonOutput()
- foldInValuesOut()

TAG: 

- taggedOutput()
- checkTaggedList()

VALUE:

- foldValuesIn()
- foldAssetsIn()
- foldPolicyIn()
- foldValuesOut()
- foldAssetsOut()
- foldPolicyOut()
- negateInValueOut()
- negateOutValueIn()
