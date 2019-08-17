//
//  Statement.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//  表达式

import Foundation

public class Stmt {}

public class FuncBlockStmt: Stmt {
    
    let stmts: [Stmt]
    
    public init(stmts: [Stmt]) {
        self.stmts = stmts
    }
    
}
