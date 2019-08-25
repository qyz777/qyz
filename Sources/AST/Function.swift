//
//  Function.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation

public struct Argument {
    let label: String
    let val: Expr
    public init(label: String, val: Expr) {
        self.label = label
        self.val = val
    }
}

/// 函数原型
/// <func-prototype> ::= <identifier>(<param-decl>*) : <data-type>
public class FuncPrototype: Decl {
    
    let name: String
    let params: [ParamDecl]
    let returnType: DataType
    
    public init(name: String, params: [ParamDecl], returnType: DataType) {
        self.name = name
        self.params = params
        self.returnType = returnType
        super.init(type: .def)
    }
    
    public override func description() {
        debugPrint("\(self): , name: \(name), params: \(params), returnType: \(returnType)")
    }
    
}

/// 函数声明
/// <func> ::= <prototype> \n <block-stmt>
public class FuncNode: Decl {
    
    let prototype: FuncPrototype
    let body: BlockStmt
    
    public init(prototype: FuncPrototype, body: BlockStmt) {
        self.prototype = prototype
        self.body = body
        super.init(type: .def)
    }
    
    public override func description() {
        debugPrint("\(self): prototype: \(prototype), body: \(body)")
    }
    
}

/// 函数调用
/// <func-call-expr> ::= <identifier>(<argument>*)
public class FuncCallExpr: Expr {
    
    let name: String
    let args: [Argument]
    
    public init(name: String, args: [Argument]) {
        self.name = name
        self.args = args
        super.init(type: .def)
    }
    
    public override func description() {
        debugPrint("\(self): , name: \(name), args: \(args)")
    }
    
}
