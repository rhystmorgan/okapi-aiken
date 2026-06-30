use aiken/collection/list
use cardano/transaction.{InlineDatum, Input, Output, OutputReference}
use okapi/fast

//             //
// Tag helpers // 
//             //

pub fn taggedOutput(outputs: List<Output>, oref: OutputReference) -> Output {
  let target = InlineDatum(oref)
  fast.mustFind(outputs, fn(output) { output.datum == target })
}

pub fn checkTaggedList(
  inputs: List<Input>,
  outputs: List<Output>,
  list: List<Int>,
  validate: fn(Input, Output) -> Bool,
) -> Bool {
  list.all(
    list,
    fn(index) {
      expect Some(payment) = list.at(outputs, index)

      expect InlineDatum(datum) = payment.datum
      expect oref: OutputReference = datum

      let input = fast.mustFindInput(inputs, oref)

      validate(input, payment)
    },
  )
}
