//
//  Function.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation

public struct Argument {
    let label: String
    let type: DataType
    public init(label: String, type: DataType) {
        self.label = label
        self.type = type
    }
}

public class PrototypeNode: ASTNode {
    
    let name: String
    let args: [Argument]
    let returnType: DataType
    
    public init(name: String, args: [Argument], returnType: DataType) {
        self.name = name
        self.args = args
        self.returnType = returnType
    }
    
}

public class FunctionNode: ASTNode {
    
    let prototype: PrototypeNode
    let body: FuncBlockStmt
    
    public init(prototype: PrototypeNode, body: FuncBlockStmt) {
        self.prototype = prototype
        self.body = body
    }
    
}
