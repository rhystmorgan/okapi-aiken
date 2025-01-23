use aiken/collection/list
use cardano/assets
use cardano/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
}
use units/tx as t

pub fn taggedOutput(outputs: List<Output>, oref: OutputReference) -> Output {
  expect Some(out) =
    list.find(outputs, fn(output) { output.datum == InlineDatum(oref) })

  out
}

// pub fn taggedInOut(
//   inputs: List<Input>,
//   outputs: List<Output>,
// ) -> List<(Input, Output)> {
//   let outs = list.filter(outputs, fn(out) { InlineDatum(data: OutputReference) == out.datum}

//   let sortedOut = list.sort(outs, output_reference.compare) 
//   let sortedIns = list.sort(ins, output)
//   taggedOuts
// }

// test taggedInOuts() {
//   let oref1 = t.oref(#"cafe", 1)
//   let oref2 = t.oref(#"cafe", 2)

//   let out1 =
//     t.output(
//       t.walletAddress(#"face"),
//       assets.from_lovelace(1000),
//       InlineDatum(oref1),
//     )

//   let out2 =
//     t.output(
//       t.walletAddress(#"face"),
//       assets.from_lovelace(1000),
//       InlineDatum(oref2),
//     )

//   let out3 =
//     t.output(t.walletAddress(#"face"), assets.from_lovelace(1000), NoDatum)

//   let outputs = [out1, out2, out3]

//   let in1 =
//     Input {
//       output_reference: oref1,
//       output: t.output(
//         t.walletAddress(#"face"),
//         assets.from_lovelace(1000),
//         NoDatum,
//       ),
//     }

//   let in2 =
//     Input {
//       output_reference: oref2,
//       output: t.output(
//         t.walletAddress(#"face"),
//         assets.from_lovelace(1000),
//         NoDatum,
//       ),
//     }

//   let in3 =
//     Input {
//       output_reference: t.oref(#"cafe", 3),
//       output: t.output(
//         t.walletAddress(#"face"),
//         assets.from_lovelace(1000),
//         NoDatum,
//       ),
//     }

//   let inputs = [in1, in2, in3]

//   taggedInOut(inputs, outputs) == [(in1, out1), (in2, out2)]
// }

pub fn checkTaggedList(
  inputs: List<Input>,
  outputs: List<Output>,
  list: List<Int>,
  validate: fn(Input, Output) -> Bool,
) -> Bool {
  let txList =
    list.map(
      list,
      fn(index) {
        expect Some(payment) = list.at(outputs, index)

        expect InlineDatum(datum) = payment.datum
        expect oref: OutputReference = datum

        expect Some(input) =
          list.find(inputs, fn(input) { input.output_reference == oref })

        (input, payment)
      },
    )

  list.all(
    txList,
    fn(pair) {
      let (input, output) = pair
      validate(input, output)
    },
  )
}
