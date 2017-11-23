import PetriKit
import PhilosophersLib

do {
    enum C: CustomStringConvertible {
        case b, v, o

        var description: String {
            switch self {
            case .b: return "b"
            case .v: return "v"
            case .o: return "o"
            }
        }
    }

    func g(binding: PredicateTransition<C>.Binding) -> C {
        switch binding["x"]! {
        case .b: return .v
        case .v: return .b
        case .o: return .o
        }
    }

    let t1 = PredicateTransition<C>(
        preconditions: [
            PredicateArc(place: "p1", label: [.variable("x")]),
        ],
        postconditions: [
            PredicateArc(place: "p2", label: [.function(g)]),
        ])

    let m0: PredicateNet<C>.MarkingType = ["p1": [.b, .b, .v, .v, .b, .o], "p2": []]
    guard let m1 = t1.fire(from: m0, with: ["x": .b]) else {
        fatalError("Failed to fire.")
    }
    print(m1)
    guard let m2 = t1.fire(from: m1, with: ["x": .v]) else {
        fatalError("Failed to fire.")
    }
    print(m2)
}

print()

do {
  // Question 1
  print("Question 1 : Combien y a-t-il de marquages possibles dans le modele des philosophes non bloquable a 5 philosophes?")
  let Philosophers1 = lockFreePhilosophers(n: 5)
  let MarkingGraph1 = Philosophers1.markingGraph(from: Philosophers1.initialMarking!)
  print("Nombre de marquages possibles :",MarkingGraph1!.count,"\n")

  // Question 2
  print("Question 2 : Combien y a-t-il de marquages possibles dans le modele des philosophes bloquable a 5 philosophes?")
  let Philosophers2 = lockablePhilosophers(n: 5)
  let MarkingGraph2 = Philosophers2.markingGraph(from: Philosophers2.initialMarking!)
  print("Nombre de marquages possibles :",MarkingGraph2!.count,"\n")

  // Question 3
  print("Question 3 :  Donnez un exemple d'etat ou le reseau est bloque dans le modele des philosophes bloquable a 5 philosophes?")
  for Current in MarkingGraph2! {
    var EmptySuccessor = true
    for (_, Successor) in Current.successors {
      if !(Successor.isEmpty) {
        EmptySuccessor = false
      }
    }
    if (EmptySuccessor) {
      print("Marquage =",Current.marking)
    }
  }
  print("Ceci est  un marquage bloqué")
}
