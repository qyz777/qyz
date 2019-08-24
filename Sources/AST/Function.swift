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

/// 函数声明
public class FuncDeclNode: ASTNode {
    
    let name: String
    let args: [Argument]
    let returnType: DataType
    
    public init(name: String, args: [Argument], returnType: DataType) {
        self.name = name
        self.args = args
        self.returnType = returnType
    }
    
    public override func description() {
        debugPrint("\(self): , name: \(name), args: \(args), returnType: \(returnType)")
    }
    
}

/// 函数
public class FunctionNode: ASTNode {
    
    let decl: FuncDeclNode
    let body: BlockStmt
    
    public init(prototype: FuncDeclNode, body: BlockStmt) {
        self.decl = prototype
        self.body = body
    }
    
    public override func description() {
        debugPrint("\(self): decl: \(decl), body: \(body)")
    }
    
}
