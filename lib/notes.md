# Okapi Revisited

Since the previous milestone, I have completely revamped Okapi

Initially I had a lot of random functions, functions that you could likely have just written yourself in a minute without much thought and it meant that they were pretty useless as parts of a helper function library.

So as I was reviewing them to start optimising things I reflected on this and decided to scrap it and instead consider the kinds of functions I actually write as helpers for projects i am working on or have worked on.

This has resulted in a long process of completely overhauling the library as it was and instead recreating it as a more validator focused and specific kind of library.

This will hopefully result in something much more useful for the community.

I have left a lot of the original functions in the `init.ak` file so I would recommend that people new to aiken and to writing smart contracts start there.

But for anyone beyond their first dapp mockup, for someone whe is using the more standardised design patterns we are all using, I hope the rest of the library will be a little more useful for you.

---

## Todo

I need to take all of the helpers I have written and try and organise them into a useful collection of helpers.

I have a selection of examples we can start with

so I will see if any of them fit well into those `categories` and if so i will continue in that way, and if not i will organise them into a more intuitive structure.

---

## Okapi 0.2

Functions:


general
  authTokenOutput() -> (Value, Datum)

inOut
  listInputOutputs() -> List(Output)
  listScriptIns() -> List(Input)
  listScriptOuts() -> List(Output)
  listScriptIO() -> (List(Inputs), List(Outputs))
  checkTokenPair() -> validate(Input, Input, Output, Output) -> Bool

mint 
  mintTokens() -> Pairs
  mintToken() -> Pair

tag
  taggedOutput() -> Output
  taggedInOut() -> List(Input, Output)

spend
  getOrefInput() -> Input
  getOrefInputOut() -> Output
  getOrefScriptHash() -> ScriptHash
  getOrefValue() -> Value
  getOrefDatumValue() -> (Datum, Value)
  ownSpendIO() -> (Input, Output)
  ownSingletonOutput() -> Output

withdrawal
  mapOutputIndex