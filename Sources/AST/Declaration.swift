//
//  Declaration.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/25.
//

import Foundation

public class Decl: ASTNode {
    
    public let type: DataType
    
    public init(type: DataType) {
        self.type = type
    }
    
}

/// <param-decl> ::= <identifier> : <data-type>
public class ParamDecl: VarDecl {
    
    public init(type: DataType, name: String) {
        super.init(type: type, name: name)
    }
    
}

/// <var-decl> ::= <identifier> : <data-type> = <expr>
public class VarDecl: Decl {
    
    public let name: String
    
    public let rhs: Expr?
    
    public init(type: DataType, name: String, rhs: Expr? = nil) {
        self.name = name
        self.rhs = rhs
        super.init(type: type)
    }
    
    public override func description() {
        debugPrint("\(self): type: \(type), name: \(name), rhs: \(String(describing: rhs))")
    }
    
}
