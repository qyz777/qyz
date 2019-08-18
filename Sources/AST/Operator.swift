//
//  Operator.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation

public enum Operator: String {
    case plus = "+"
    case minus = "-"
    case mul = "*"
    case div = "/"
    case mod = "%"
    case assign = "="
    case equalTo = "=="
    case notEqualTo = "!="
    case lessThen = "<"
    case lessThenOrEqual = "<="
    case greaterThen = ">"
    case greaterThenOrEqual = ">="
    case plusAssign = "+="
    case minusAssign = "-="
    case mulAssign = "*="
    case divAssign = "/="
    case modAssign = "%="
    case and = "&&"
    case or = "||"
    case not = "!"
    
    
    /// 运算符优先级，先参考Python的来吧
    public var precedence: Int {
        switch self {
        case .not:
            return 120
        case .mul, .div, .mod:
            return 110
        case .plus, .minus:
            return 100
        case .lessThen, .lessThenOrEqual, .greaterThen, .greaterThenOrEqual:
            return 60
        case .equalTo, .notEqualTo:
            return 50
        case .and, .or:
            return 40
        case .assign, .plusAssign, .minusAssign, .mulAssign, .divAssign, .modAssign:
            return 30
        }
    }
    
    public var isUnary: Bool {
        switch self {
        case .minus, .not:
            return true
        default:
            return false
        }
    }
}

public class BinaryExpr: Expr {
    
    public let lhs: Expr
    
    public let rhs: Expr
    
    public let op: Operator
    
    public init(op: Operator, lhs: Expr, rhs: Expr) {
        self.op = op
        self.lhs = lhs
        self.rhs = rhs
        super.init(type: .default)
    }
    
    public override func description() {
        debugPrint("\(self): lhs: \(lhs), op: \(op), rhs: \(rhs)")
    }
    
}

public class UnaryExpr: Expr {
    
    public let op: Operator
    
    public let rhs: Expr
    
    public init(op: Operator, rhs: Expr) {
        self.op = op
        self.rhs = rhs
        super.init(type: .default)
    }
    
    public override func description() {
        debugPrint("\(self): op: \(op), rhs: \(rhs)")
    }
    
}
