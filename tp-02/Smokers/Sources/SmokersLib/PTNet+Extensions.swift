import PetriKit

public class MarkingGraph {

    public let marking   : PTMarking
    public var successors: [PTTransition: MarkingGraph]

    public init(marking: PTMarking, successors: [PTTransition: MarkingGraph] = [:]) {
        self.marking    = marking
        self.successors = successors
    }

}

public extension PTNet {

    public func markingGraph(from marking: PTMarking) -> MarkingGraph? {
        // Write here the implementation of the marking graph generation.
        var Noeud = MarkingGraph(marking : marking) // We instanciate the MarkingGraph using the initial marking
        var Atraite = [Noeud] // List of nodes, as defined before
        var Dejatraite = [MarkingGraph]() // Empty array of nodes, will contain nodes which have been treated

        while let marquagecourant = Atraite.popLast(){ // We iterate through the Atraite list
            DejaTraite.append(marquagecourant) // We add the current node to the array of nodes which have been trated
            for transition in self.transitions { // We iterate through the transitions
                if let marquage = transition.fire(from: marquagecourant.marking){ // If we can fire the transition 
                  if Atraite.contains(where: {$0.marking == marquage}) { // If the current node is in Atraite
                    marquagecourant.successors[transition] = Atraite.first(where: {$0.marking == marquage})
                  } else if DejaTraite.contains(where: {$0.marking == marquage}) { // Else if the node has already been treated
                    marquagecourant.successors[transition] = done.first(where: {$0.marking == marquage})
                  } else { // Else we add the node to the Atraite list
                    var NouveauNoeud = MarkingGraph(marking : marquage)
                    Atraite.append(NouveauNoeud)
                    marquagecourant.successors[transition] = NouveauNoeud
                  }
                }

              }

        }
        return Noeud
    }

}
