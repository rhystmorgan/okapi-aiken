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