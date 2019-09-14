//
//  ASTTransformer.swift
//  AST
//
//  Created by Q YiZhong on 2019/9/14.
//

import Foundation

public class ASTTransformer {
    
    public var currentFunction: FuncDecl?
    public var currentScope: BlockStmt?
    public var currentHotpot: HotpotDecl?
    public var declContext: ASTNode?
    public var currentBreakTarget: ASTNode?
    public let context: ASTContext
    
    public required init(context: ASTContext) {
        self.context = context
    }
    
    //MARK: 作用域辅助方法
    
    func withBreakTarget(_ node: ASTNode, _ clousre: () -> Void) {
        let oldTarget = currentBreakTarget
        currentBreakTarget = node
        withDeclContext(node, clousre)
        currentBreakTarget = oldTarget
    }
    
    func withHotpotDecl(_ decl: HotpotDecl, _ clousre: () -> Void) {
        let oldHotpot = currentHotpot
        currentHotpot = decl
        withDeclContext(decl, clousre)
        currentHotpot = oldHotpot
    }
    
    func withFunction(_ decl: FuncDecl, _ closure: () -> Void) {
        let oldFunction = currentFunction
        currentFunction = decl
        withDeclContext(decl, closure)
        currentFunction = oldFunction
    }
    
    func withDeclContext(_ node: ASTNode, _ closure: () -> Void) {
        let oldContext = declContext
        declContext = node
        closure()
        declContext = oldContext
    }
    
    func withScope(_ stmt: BlockStmt, _ closure: () -> Void) {
        let oldScope = currentScope
        currentScope = stmt
        closure()
        currentScope = oldScope
    }
    
    public func run() {
        context.hotpots.forEach(visitHotpotDecl(_:))
        context.globals.forEach(visitVarDecl(_:))
        context.functions.forEach(visitFuncDecl(_:))
        context.statements.forEach(visit(_:))
    }

    
}

extension ASTTransformer: ASTVisitor {
    
    public func visitNullExpr(_ expr: NullExpr) {
        
    }
    
    public func visitIntExpr(_ expr: IntExpr) {
        
    }
    
    public func visitFloatExpr(_ expr: FloatExpr) {
        
    }
    
    public func visitBoolExpr(_ expr: BoolExpr) {
        
    }
    
    public func visitStringExpr(_ expr: StringExpr) {
        
    }
    
    public func visitVarExpr(_ expr: VarExpr) {
        if let decl = expr.decl {
            visit(decl)
        }
    }
    
    public func visitArrayExpr(_ expr: ArrayExpr) {
        expr.values.forEach(visit(_:))
    }
    
    public func visitMethodRefExpr(_ expr: MethodRefExpr) {
        visit(expr.lhs)
        visitFuncCallExpr(expr.funcCall)
    }
    
    public func visitPropertyRefExpr(_ expr: PropertyRefExpr) {
        visit(expr.lhs)
        visit(expr.varExpr)
    }
    
    public func visitBinaryExpr(_ expr: BinaryExpr) {
        visit(expr.lhs)
        visit(expr.rhs)
    }
    
    public func visitUnaryExpr(_ expr: UnaryExpr) {
        visit(expr.rhs)
    }
    
    public func visitParmaDecl(_ decl: ParamDecl) {
        visitVarDecl(decl)
    }
    
    public func visitVarDecl(_ decl: VarDecl) {
        if let rhs = decl.rhs {
            visit(rhs)
        }
    }
    
    public func visitBlockStmt(_ stmt: BlockStmt) {
        withScope(stmt) {
            stmt.stmts.forEach(visit(_:))
        }
    }
    
    public func visitReturnStmt(_ stmt: ReturnStmt) {
        visit(stmt.value)
    }
    
    public func visitIfStmt(_ stmt: IfStmt) {
        for (condition, body) in stmt.conditions {
            visit(condition)
            visitBlockStmt(body)
        }
        if let elseCondition = stmt.elseCondition {
            visitBlockStmt(elseCondition)
        }
    }
    
    public func visitForStmt(_ stmt: ForStmt) {
        withScope(stmt.body) {
            visit(stmt.initializer)
            visit(stmt.condition)
            visit(stmt.step)
            withBreakTarget(stmt, {
                visit(stmt.body)
            })
        }
    }
    
    public func visitWhileStmt(_ stmt: WhileStmt) {
        visit(stmt.condition)
        withBreakTarget(stmt) {
            visitBlockStmt(stmt.body)
        }
    }
    
    public func visitExprStmt(_ stmt: ExprStmt) {
        visit(stmt.expr)
    }
    
    public func visitDeclStmt(_ stmt: DeclStmt) {
        visit(stmt.decl)
    }
    
    public func visitBreakStmt(_ stmt: BreakStmt) {
        
    }
    
    public func visitContinueStmt(_ stmt: ContinueStmt) {
        
    }
    
    public func visitFuncPrototype(_ prototype: FuncPrototype) {
        for param in prototype.params {
            visitParmaDecl(param)
        }
    }
    
    public func visitFuncDecl(_ decl: FuncDecl) {
        withFunction(decl) {
            withScope(decl.body, {
                self.visitFuncPrototype(decl.prototype)
                self.visitBlockStmt(decl.body)
            })
        }
    }
    
    public func visitFuncCallExpr(_ expr: FuncCallExpr) {
        visit(expr.varExpr)
        expr.args.forEach({ visit($0.val) })
    }
    
    public func visitHotpotDecl(_ decl: HotpotDecl) {
        withHotpotDecl(decl) {
            //TODO: 初始化方法还没做
            for method in decl.methods {
                visitFuncDecl(method)
            }
            for property in decl.properties {
                visitVarDecl(property)
            }
        }
    }
    
}
