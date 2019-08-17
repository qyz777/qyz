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

public class FloatExpr: Expr {
    
    public let value: Double
    
    public init(type: DataType, value: Double) {
        self.value = value
        super.init(type: type)
    }
    
}

public class BoolExpr: Expr {
    
    public let value: Bool
    
    public init(value: Bool) {
        self.value = value
        super.init(type: .bool)
    }
    
}

public class StringExpr: Expr {
    
    public let value: String
    
    public init(value: String) {
        self.value = value
        super.init(type: .string)
    }
    
}
