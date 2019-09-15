//
//  ASTTransformer.swift
//  AST
//
//  Created by Q YiZhong on 2019/9/14.
//

import Foundation

open class ASTTransformer: ASTVisitor {
    
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
    
    open func run() {
        context.hotpots.forEach(visitHotpotDecl(_:))
        context.globals.forEach(visitVarDecl(_:))
        context.functions.forEach(visitFuncDecl(_:))
        context.statements.forEach(visit(_:))
    }
    
    open func visitNullExpr(_ expr: NullExpr) {
        
    }
    
    open func visitIntExpr(_ expr: IntExpr) {
        
    }
    
    open func visitFloatExpr(_ expr: FloatExpr) {
        
    }
    
    open func visitBoolExpr(_ expr: BoolExpr) {
        
    }
    
    open func visitStringExpr(_ expr: StringExpr) {
        
    }
    
    open func visitVarExpr(_ expr: VarExpr) {
        if let decl = expr.decl {
            visit(decl)
        }
    }
    
    open func visitArrayExpr(_ expr: ArrayExpr) {
        expr.values.forEach(visit(_:))
    }
    
    open func visitMethodRefExpr(_ expr: MethodRefExpr) {
        visit(expr.lhs)
    }
    
    open func visitPropertyRefExpr(_ expr: PropertyRefExpr) {
        visit(expr.lhs)
        visit(expr.varExpr)
    }
    
    open func visitBinaryExpr(_ expr: BinaryExpr) {
        visit(expr.lhs)
        visit(expr.rhs)
    }
    
    open func visitUnaryExpr(_ expr: UnaryExpr) {
        visit(expr.rhs)
    }
    
    open func visitParmaDecl(_ decl: ParamDecl) {
        visitVarDecl(decl)
    }
    
    open func visitVarDecl(_ decl: VarDecl) {
        if let rhs = decl.rhs {
            visit(rhs)
        }
    }
    
    open func visitBlockStmt(_ stmt: BlockStmt) {
        withScope(stmt) {
            stmt.stmts.forEach(visit(_:))
        }
    }
    
    open func visitReturnStmt(_ stmt: ReturnStmt) {
        visit(stmt.value)
    }
    
    open func visitIfStmt(_ stmt: IfStmt) {
        for (condition, body) in stmt.conditions {
            visit(condition)
            visitBlockStmt(body)
        }
        if let elseCondition = stmt.elseCondition {
            visitBlockStmt(elseCondition)
        }
    }
    
    open func visitForStmt(_ stmt: ForStmt) {
        withScope(stmt.body) {
            visit(stmt.initializer)
            visit(stmt.condition)
            visit(stmt.step)
            withBreakTarget(stmt, {
                visit(stmt.body)
            })
        }
    }
    
    open func visitWhileStmt(_ stmt: WhileStmt) {
        visit(stmt.condition)
        withBreakTarget(stmt) {
            visitBlockStmt(stmt.body)
        }
    }
    
    open func visitExprStmt(_ stmt: ExprStmt) {
        visit(stmt.expr)
    }
    
    open func visitDeclStmt(_ stmt: DeclStmt) {
        visit(stmt.decl)
    }
    
    open func visitBreakStmt(_ stmt: BreakStmt) {
        
    }
    
    open func visitContinueStmt(_ stmt: ContinueStmt) {
        
    }
    
    open func visitFuncPrototype(_ prototype: FuncPrototype) {
        for param in prototype.params {
            visitParmaDecl(param)
        }
    }
    
    open func visitFuncDecl(_ decl: FuncDecl) {
        withFunction(decl) {
            withScope(decl.body, {
                self.visitFuncPrototype(decl.prototype)
                self.visitBlockStmt(decl.body)
            })
        }
    }
    
    open func visitFuncCallExpr(_ expr: FuncCallExpr) {
        visit(expr.varExpr)
        expr.args.forEach({ visit($0.val) })
    }
    
    open func visitHotpotDecl(_ decl: HotpotDecl) {
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
