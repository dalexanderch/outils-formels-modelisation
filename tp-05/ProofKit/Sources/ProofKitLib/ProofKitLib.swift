infix operator =>: LogicalDisjunctionPrecedence

public protocol BooleanAlgebra {

    static prefix func ! (operand: Self) -> Self
    static        func ||(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self
    static        func &&(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self

}

extension Bool: BooleanAlgebra {}

public enum Formula {

    /// p
    case proposition(String)

    /// ¬a
    indirect case negation(Formula)

    public static prefix func !(formula: Formula) -> Formula {
        return .negation(formula)
    }

    /// a ∨ b
    indirect case disjunction(Formula, Formula)

    public static func ||(lhs: Formula, rhs: Formula) -> Formula {
        return .disjunction(lhs, rhs)
    }

    /// a ∧ b
    indirect case conjunction(Formula, Formula)

    public static func &&(lhs: Formula, rhs: Formula) -> Formula {
        return .conjunction(lhs, rhs)
    }

    /// a → b
    indirect case implication(Formula, Formula)

    public static func =>(lhs: Formula, rhs: Formula) -> Formula {
        return .implication(lhs, rhs)
    }

    /// The negation normal form of the formula.
    public var nnf: Formula {
        switch self {
        case .proposition(_):
            return self
        case .negation(let a):
            switch a {
            case .proposition(_):
                return self
            case .negation(let b):
                return b.nnf
            case .disjunction(let b, let c):
                return (!b).nnf && (!c).nnf
            case .conjunction(let b, let c):
                return (!b).nnf || (!c).nnf
            case .implication(_):
                return (!a.nnf).nnf
            }
        case .disjunction(let b, let c):
            return b.nnf || c.nnf
        case .conjunction(let b, let c):
            return b.nnf && c.nnf
        case .implication(let b, let c):
            return (!b).nnf || c.nnf
        }
    }
    /// The dnf formula
    public var dnf: Formula { // We start from the nnf formula
      switch self.nnf { // We treat all possible cases, using algorithm seen in lesson
      case .proposition(_) : // if we get a proposition, no additional processing is needed, we return the nnf
          return self.nnf
      case .negation(_): // same thing if we get a negation
        return self.nnf
      case .disjunction(let a, let b): // if we get a disjunction
          return a.dnf || b.dnf // we return a ∨ b where a and b are put in dnf form through recursion
      case .conjunction(let a, let b):   // if we get a conjonction, we seperate different cases depending on the nature of a and b
          switch a.dnf {
          case .disjunction(let c, let d): // if the cnf form of a is a disjunction we return (c∧b)∨(d∧b) (i.e we put the disjonction "inside") where c and d are put in dnf form themselves through recursion
            return ((c.dnf && b.dnf) || (d.dnf && b.dnf)).dnf
          default: break
          }
          switch b.dnf {
          case .disjunction(let c, let d): // if the cnf form of b is a disjunction we return (c∧a)∨(d∧a) (i.e we put the disjonction "inside") where a,c,d are put in dnf form themselves through recursion
            return ((c.dnf && a.dnf) || (d.dnf && a.dnf)).dnf
          default: break
          }
        default :break
        }
      return self.nnf
}

  /// cnf formula
    public var cnf: Formula {// We start from the nnf formula
        switch self.nnf { // We treat all possible cases, using algorithm seen in lesson
      case .proposition(_): // if we get a proposition, no additional processing is needed, we return the nnf
        return self.nnf
      case .negation(_):  // same thing if we get a negation
        return self.nnf
      case .conjunction(let a, let b):  // if we get a conjuction, we return a∧b, where a and b are put in cnf form
        return a.cnf && b.cnf
      case .disjunction(let a, let b):  // if we get a disjunction, we seperate different cases, depending on a and b
        switch a.cnf {
        case .conjunction(let c, let d): // if the cnf form of a is a conjunction we return (c∨b)∧(d∨b)(i.e we put the disjunction "inside") where b,c,d are put in cnf form themselves
          return ((c.cnf || b.cnf) && (d.cnf || b.cnf)).cnf
        default: break
        }
        switch b.cnf { // // if the cnf form of b is a conjunction we return (c∨a)∧(d∨a) (i.e we put the disjunction "inside") where a,c,d are put in cnf form themselves
        case .conjunction(let c, let d):
          return ((c.cnf || a.cnf) && (d.cnf || a.cnf)).cnf
        default: break
        }
      default :break
      }
        return self.nnf
    }


    /// The propositions the formula is based on.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let props = f.propositions
    ///     // 'props' == Set<Formula>([.proposition("p"), .proposition("q")])
    public var propositions: Set<Formula> {
        switch self {
        case .proposition(_):
            return [self]
        case .negation(let a):
            return a.propositions
        case .disjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .conjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .implication(let a, let b):
            return a.propositions.union(b.propositions)
        }
    }

    /// Evaluates the formula, with a given valuation of its propositions.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let value = f.eval { (proposition) -> Bool in
    ///         switch proposition {
    ///         case "p": return true
    ///         case "q": return false
    ///         default : return false
    ///         }
    ///     })
    ///     // 'value' == true
    ///
    /// - Warning: The provided valuation should be defined for each proposition name the formula
    ///   contains. A call to `eval` might fail with an unrecoverable error otherwise.
    public func eval<T>(with valuation: (String) -> T) -> T where T: BooleanAlgebra {
        switch self {
        case .proposition(let p):
            return valuation(p)
        case .negation(let a):
            return !a.eval(with: valuation)
        case .disjunction(let a, let b):
            return a.eval(with: valuation) || b.eval(with: valuation)
        case .conjunction(let a, let b):
            return a.eval(with: valuation) && b.eval(with: valuation)
        case .implication(let a, let b):
            return !a.eval(with: valuation) || b.eval(with: valuation)
        }
    }

}

extension Formula: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .proposition(value)
    }

}

extension Formula: Hashable {

    public var hashValue: Int {
        return String(describing: self).hashValue
    }

    public static func ==(lhs: Formula, rhs: Formula) -> Bool {
        switch (lhs, rhs) {
        case (.proposition(let p), .proposition(let q)):
            return p == q
        case (.negation(let a), .negation(let b)):
            return a == b
        case (.disjunction(let a, let b), .disjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.conjunction(let a, let b), .conjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.implication(let a, let b), .implication(let c, let d)):
            return (a == c) && (b == d)
        default:
            return false
        }
    }

}

extension Formula: CustomStringConvertible {

    public var description: String {
        switch self {
        case .proposition(let p):
            return p
        case .negation(let a):
            return "¬\(a)"
        case .disjunction(let a, let b):
            return "(\(a) ∨ \(b))"
        case .conjunction(let a, let b):
            return "(\(a) ∧ \(b))"
        case .implication(let a, let b):
            return "(\(a) → \(b))"
        }
    }
  }
