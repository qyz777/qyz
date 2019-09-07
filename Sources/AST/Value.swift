//
//  Value.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation

public class Expr: ASTNode {
    
    var type: DataType = .default
    
    public init(type: DataType) {
        self.type = type
    }
    
}

public class VoidExpr: Expr {}

public class NullExpr: Expr {}

public class IntExpr: Expr {
    
    public let value: Int
    
    public init(type: DataType, value: Int) {
        self.value = value
        super.init(type: type)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
    }
    
}

public class FloatExpr: Expr {
    
    public let value: Double
    
    public init(type: DataType, value: Double) {
        self.value = value
        super.init(type: type)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
    }
    
}

public class BoolExpr: Expr {
    
    public let value: Bool
    
    public init(value: Bool) {
        self.value = value
        super.init(type: .bool)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
    }
    
}

public class StringExpr: Expr {
    
    public let value: String
    
    public init(value: String) {
        self.value = value
        super.init(type: .string)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
    }
    
}

public class VarExpr: Expr {
    
    /// 用来指向它的申明
    public var decl: Decl?
    
    public let name: String
    
    public init(name: String) {
        self.name = name
        super.init(type: .default)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), name: \(name)")
    }
    
}

public class ArrayExpr: Expr {
    
    public let values: [Expr]
    
    public init(values: [Expr]) {
        self.values = values
        super.init(type: .default)
    }
    
    public override func description() {
        debugPrint("\(self): values: \(values)")
    }
    
}

public protocol RefExpr {
    
    var lhs: Expr { get }
    
    var varExpr: VarExpr { get }
    
}

/// <method-ref-expr> ::= <var-expr>.<func-call-expr>
public class MethodRefExpr: Expr, RefExpr {
    
    public let lhs: Expr
    
    public let varExpr: VarExpr
    
    public let funcCall: FuncCallExpr
    
    public init(lhs: Expr, varExpr: VarExpr, funcCall: FuncCallExpr) {
        self.funcCall = funcCall
        self.lhs = lhs
        self.varExpr = varExpr
        super.init(type: .method)
    }
    
    public override func description() {
        debugPrint("\(self): lhs:\(lhs), call: \(funcCall)")
    }
    
}

/// <property-ref-expr> ::= <var-expr>.<var-expr>
public class PropertyRefExpr: Expr, RefExpr {
    
    public let lhs: Expr
    
    public let varExpr: VarExpr
    
    public init(lhs: Expr, varExpr: VarExpr) {
        self.lhs = lhs
        self.varExpr = varExpr
        super.init(type: .property)
    }
    
    public override func description() {
        debugPrint("\(self): lhs:\(lhs), var: \(varExpr)")
    }
    
}
