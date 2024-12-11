use aiken/collection/list
use cardano/transaction.{Output}

// withdrawalVal helpers

pub fn mapOutputIndex(
  outputs: List<Output>,
  indices: List<Int>,
  validate: fn(Output) -> Bool,
) -> Bool {
  let filtered =
    list.map(
      indices,
      fn(index) {
        expect Some(out) = list.at(outputs, index)
        out
      },
    )

  list.all(filtered, fn(output) { validate(output) })
}
