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

public class ValDecl: Expr {
    
    public let value: String
    
    public init(type: DataType, value: String) {
        self.value = value
        super.init(type: type)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
    }
    
}

public class ValExpr: Expr {
    
    public let value: String
    
    public init(value: String) {
        self.value = value
        super.init(type: .variable)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
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

public class ArrayDecl: Expr {
    
    public let value: String
    
    public init(type: DataType, value: String) {
        self.value = value
        super.init(type: type)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), value: \(value)")
    }
    
}
