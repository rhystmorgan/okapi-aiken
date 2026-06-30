use aiken/collection/list
use cardano/transaction.{Input, OutputReference}

//              //
// fast finders // 
//              //

pub fn mustFindInput(inputs: List<Input>, oref: OutputReference) -> Input {
  expect [head, ..tail] = inputs
  if head.output_reference == oref {
    head
  } else {
    mustFindInput(tail, oref)
  }
}

pub fn mustFind(self: List<a>, predicate: fn(a) -> Bool) -> a {
  expect [head, ..tail] = self
  if predicate(head) {
    head
  } else {
    mustFind(tail, predicate)
  }
}

pub fn onlyMatch(self: List<a>, predicate: fn(a) -> Bool) -> Bool {
  when self is {
    [] -> False
    [head, ..tail] ->
      if predicate(head) {
        !list.any(tail, predicate)
      } else {
        onlyMatch(tail, predicate)
      }
  }
}
