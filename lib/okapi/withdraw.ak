use aiken/collection/list
use cardano/transaction.{Output}

//                    //
// withdrawal helpers //
//                    //

pub fn mapOutputIndex(
  outputs: List<Output>,
  indices: List<Int>,
  validate: fn(Output) -> Bool,
) -> Bool {
  list.all(
    indices,
    fn(index) {
      expect Some(out) = list.at(outputs, index)
      validate(out)
    },
  )
}
