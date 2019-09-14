//
//  ASTVisiotr.swift
//  AST
//
//  Created by Q YiZhong on 2019/9/14.
//

import Foundation

/// 检查AST Node协议
public protocol ASTVisitor {
    
    var context: ASTContext { get }
    
    //MARK: Base
    
    func visit(_ expr: Expr)
    
    func visit(_ decl: Decl)
    
    func visit(_ stmt: Stmt)
    
    func visit(_ node: ASTNode)
    
    //MARK: Expr
    
    func visitNullExpr(_ expr: NullExpr)
    
    func visitIntExpr(_ expr: IntExpr)
    
    func visitFloatExpr(_ expr: FloatExpr)
    
    func visitBoolExpr(_ expr: BoolExpr)
    
    func visitStringExpr(_ expr: StringExpr)
    
    func visitVarExpr(_ expr: VarExpr)
    
    func visitArrayExpr(_ expr: ArrayExpr)
    
    func visitMethodRefExpr(_ expr: MethodRefExpr)
    
    func visitPropertyRefExpr(_ expr: PropertyRefExpr)
    
    //MARK: Decl
    
    func visitParmaDecl(_ decl: ParamDecl)
    
    func visitVarDecl(_ decl: VarDecl)
    
    //MARK: Stmt
    
    func visitBlockStmt(_ stmt: BlockStmt)
    
    func visitReturnStmt(_ stmt: ReturnStmt)
    
    func visitIfStmt(_ stmt: IfStmt)
    
    func visitForStmt(_ stmt: ForStmt)
    
    func visitWhileStmt(_ stmt: WhileStmt)
    
    func visitExprStmt(_ stmt: ExprStmt)
    
    func visitDeclStmt(_ stmt: DeclStmt)
    
    func visitBreakStmt(_ stmt: BreakStmt)
    
    func visitContinueStmt(_ stmt: ContinueStmt)
    
    //MARK: Func
    
    func visitFuncPrototype(_ prototype: FuncPrototype)
    
    func visitFuncDecl(_ decl: FuncDecl)
    
    func visitFuncCallExpr(_ expr: FuncCallExpr)
    
    //MARK: Hotpot
    
    func visitHotpotDecl(_ decl: HotpotDecl)
    
}

extension ASTVisitor {
    
    public func visit(_ node: ASTNode) {
        switch node {
        case let decl as Decl:
            visit(decl)
        case let expr as Expr:
            visit(expr)
        case let stmt as Stmt:
            visit(stmt)
        default:
            fatalError("Unknow node: \(node)")
        }
    }
    
    public func visit(_ decl: Decl) {
        switch decl {
        case let d as ParamDecl:
            visitParmaDecl(d)
        case let d as VarDecl:
            visitVarDecl(d)
        case let d as FuncPrototype:
            visitFuncPrototype(d)
        case let d as FuncDecl:
            visitFuncDecl(d)
        case let d as HotpotDecl:
            visitHotpotDecl(d)
        default:
            fatalError("Unknow decl: \(decl)")
        }
    }
    
    public func visit(_ stmt: Stmt) {
        switch stmt {
        case let s as BlockStmt:
            visitBlockStmt(s)
        case let s as ReturnStmt:
            visitReturnStmt(s)
        case let s as IfStmt:
            visitIfStmt(s)
        case let s as ForStmt:
            visitForStmt(s)
        case let s as WhileStmt:
            visitWhileStmt(s)
        case let s as ExprStmt:
            visitExprStmt(s)
        case let s as DeclStmt:
            visitDeclStmt(s)
        case let s as BreakStmt:
            visitBreakStmt(s)
        case let s as ContinueStmt:
            visitContinueStmt(s)
        default:
            fatalError("Unknow stmt: \(stmt)")
        }
    }
    
    public func visit(_ expr: Expr) {
        switch expr {
        case let e as NullExpr:
            visitNullExpr(e)
        case let e as IntExpr:
            visitIntExpr(e)
        case let e as FloatExpr:
            visitFloatExpr(e)
        case let e as BoolExpr:
            visitBoolExpr(e)
        case let e as StringExpr:
            visitStringExpr(e)
        case let e as VarExpr:
            visitVarExpr(e)
        case let e as ArrayExpr:
            visitArrayExpr(e)
        case let e as MethodRefExpr:
            visitMethodRefExpr(e)
        case let e as PropertyRefExpr:
            visitPropertyRefExpr(e)
        case let e as FuncCallExpr:
            visitFuncCallExpr(e)
        default:
            fatalError("Unknow expr: \(expr)")
        }
    }
    
}
