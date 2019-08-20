//
//  Statement.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//  表达式

import Foundation

public class Stmt: ASTNode {}

/// 混合Stmt，包含多种Stmt在内<colon-block>
public class BlockStmt: Stmt {
    
    let stmts: [Stmt]
    
    public init(stmts: [Stmt]) {
        self.stmts = stmts
    }
    
}

/// return <expr>
public class ReturnStmt: Stmt {
    
    public let value: Expr
    
    public init(value: Expr) {
        self.value = value
    }
    
}

/// if <expr> <colon-block>
public class IfStmt: Stmt {
    
    /// 这里使用元组数组是为了表示`elif`的情况
    public let conditions: [(Expr, BlockStmt)]
    
    public let elseCondition: BlockStmt?
    
    public init(conditions: [(Expr, BlockStmt)], elseCondition: BlockStmt? = nil) {
        self.conditions = conditions
        self.elseCondition = elseCondition
    }
    
}

/// for <expr>, <expr>, <expr> <colon-block>
public class ForStmt: Stmt {
    
    public let initializer: Expr
    
    public let condition: Expr
    
    public let step: Expr
    
    public let body: BlockStmt
    
    public init(initializer: Expr, condition: Expr, step: Expr, body: BlockStmt) {
        self.initializer = initializer
        self.condition = condition
        self.step = step
        self.body = body
    }
    
}

public class WhileExpr: Stmt {
    
    public let condition: Expr
    
    public let body: BlockStmt
    
    public init(condition: Expr, body: BlockStmt) {
        self.condition = condition
        self.body = body
    }
    
}

public class ExprStmt: Stmt {
    
    public let expr: Expr
    
    public init(expr: Expr) {
        self.expr = expr
    }
    
}

public class BreakStmt: Stmt {}

public class ContinueStmt: Stmt {}
