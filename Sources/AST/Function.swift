//
//  Function.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation

public struct Argument {
    public let label: String
    public let val: Expr
    public init(label: String, val: Expr) {
        self.label = label
        self.val = val
    }
}

/// 函数原型
/// <func-prototype> ::= <identifier>(<param-decl>*) : <data-type>
public class FuncPrototype: Decl {
    
    public let name: String
    public let params: [ParamDecl]
    public let returnType: DataType
    
    public init(name: String, params: [ParamDecl], returnType: DataType) {
        self.name = name
        self.params = params
        self.returnType = returnType
        super.init(type: .def(args: params.map({ $0.type }), returnType: returnType))
    }
    
    public override func description() {
        debugPrint("\(self): , name: \(name), params: \(params), returnType: \(returnType)")
    }
    
}

/// 函数声明
/// <func-decl> ::= <prototype> \n <block-stmt>
public class FuncDecl: Decl {
    
    public let prototype: FuncPrototype
    public let body: BlockStmt
    
    public init(prototype: FuncPrototype, body: BlockStmt) {
        self.prototype = prototype
        self.body = body
        super.init(type: prototype.type)
    }
    
    public override func description() {
        debugPrint("\(self): prototype: \(prototype), body: \(body)")
    }
    
}

/// 函数调用
/// <func-call-expr> ::= <var-expr>(<argument>*)
public class FuncCallExpr: Expr {
    
    public let varExpr: VarExpr
    public let args: [Argument]
    
    public var isHotpot = false
    
    public init(varExpr: VarExpr, args: [Argument]) {
        self.varExpr = varExpr
        self.args = args
        super.init(type: .default)
    }
    
    public override func description() {
        debugPrint("\(self): , var: \(varExpr), args: \(args)")
    }
    
}
