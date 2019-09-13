//
//  ASTContext.swift
//  AST
//
//  Created by Q YiZhong on 2019/9/3.
//

import Foundation

public class ASTContext {
    
    /// 使用范围是global
    public var statements: [Stmt] = []
    
    /// 使用范围是global
    public var functions: [FuncDecl] = []
    
    public var hotpots: [HotpotDecl] = []
    
    public var globals: [VarDecl] = []
    
    public var mainFunc: FuncDecl?
    
    private var hotpotDeclInfo: [DataType: HotpotDecl] = [
        .int64: HotpotDecl(name: "int"),
        .float: HotpotDecl(name: "float"),
        .double: HotpotDecl(name: "double"),
        .null: HotpotDecl(name: "null"),
        .string: HotpotDecl(name: "string"),
        .bool: HotpotDecl(name: "bool")
    ]
    
    private var globalDeclInfo: [String: VarDecl] = [:]
    
    private var functionDeclInfo: [String: FuncDecl] = [:]
    
    public func add(_ stmt: Stmt) {
        statements.append(stmt)
    }
    
    public func add(_ hotpot: HotpotDecl) {
        guard hotpotDeclInfo[hotpot.type] == nil else {
            fatalError("Repeated declare hotpot: \(hotpot.name)")
        }
        hotpots.append(hotpot)
        hotpotDeclInfo[hotpot.type] = hotpot
    }
    
    public func add(_ global: VarDecl) {
        guard globalDeclInfo[global.name] == nil else {
            fatalError("Repeated declare var: \(global.name)")
        }
        globals.append(global)
        globalDeclInfo[global.name] = global
    }
    
    public func add(_ funcDecl: FuncDecl) {
        if funcDecl.prototype.name == "main" {
            guard mainFunc == nil else {
                fatalError("Repeated declare main function.")
            }
            mainFunc = funcDecl
            return
        }
        guard functionDeclInfo[funcDecl.prototype.name] == nil else {
            fatalError("Repeated declare function: \(funcDecl.prototype.name)")
        }
        functions.append(funcDecl)
    }
    
}
