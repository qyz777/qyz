//
//  Sema.swift
//  Sema
//
//  Created by Q YiZhong on 2019/9/3.
//

import Foundation
import AST

public class Sema: ASTTransformer, SemaErrorRepoter {
    
    private var varBindInfo: [String: VarDecl] = [:]
    
    //MARK: Decl
    
    public override func visitFuncDecl(_ decl: FuncDecl) {
        super.visitFuncDecl(decl)
        //1.检查返回类型是否正确
        let returnType = decl.prototype.returnType
        guard context.isValidDataType(returnType) else {
            error(.unknowDataType(type: returnType))
            return
        }
        //2.检查方法body是否都有返回值
        let body = decl.body
        if !body.hasReturn && decl.prototype.returnType != .null {
            error(.notAllPathsReturn(type: decl.prototype.returnType))
        }
    }
    
    public override func visitVarDecl(_ decl: VarDecl) {
        super.visitVarDecl(decl)
        //1.检验类型有效性
        guard context.isValidDataType(decl.type) else {
            error(.unknowDataType(type: decl.type))
            return
        }
        //2.检验是否可以赋值
        if let rhs = decl.rhs {
            guard rhs.type == decl.type else {
                error(.canNotConvertValue(t1: rhs.type, t2: decl.type))
                return
            }
        }
        //3.推断作用域
        if let fn = currentFunction {
            decl.scope = .local(func: fn)
        } else if let hotpot = currentHotpot {
            decl.scope = .property(hotpot: hotpot)
        } else {
            decl.scope = .global
        }
        //4.填写符号表
        switch decl.scope! {
        case .global, .local(func: _):
            varBindInfo[decl.name] = decl
        default:
            break
        }
    }
    
    public override func visitParmaDecl(_ decl: ParamDecl) {
        super.visitParmaDecl(decl)
        visitVarDecl(decl)
        guard case .local(_) = decl.scope! else {
            fatalError("严重错误，方法参数作用域不是local!!!")
        }
    }
    
    //MARK: Expr
    
    public override func visitFuncCallExpr(_ expr: FuncCallExpr) {
        super.visitFuncCallExpr(expr)
        //todo: 这里应该可以优化一下用map存，目前还有一个缺陷就是只检验了名字而没有检验参数个数
        //funcCall有可能是hotpot的初始化方法
        //1.检查是否是hotpot
        if context.hotpots.contains(where: { $0.name == expr.varExpr.name }) {
            expr.isHotpot = true
        } else {
            //2.如果不是hotpot则检查是否有这个函数
            if currentHotpot != nil {
                //在火锅作用域调用方法检查，可以调用global
                let flagA = context.functions.contains(where: { $0.prototype.name == expr.varExpr.name })
                let flagB = currentHotpot!.methods.contains(where: { $0.prototype.name == expr.varExpr.name })
                if !(flagA || flagB) {
                    error(.unknowFunction(name: expr.varExpr.name))
                }
            } else {
                //global或者function范围
                if !context.functions.contains(where: { $0.prototype.name == expr.varExpr.name }) {
                    error(.unknowFunction(name: expr.varExpr.name))
                }
            }
        }
    }
    
    public override func visitMethodRefExpr(_ expr: MethodRefExpr) {
        super.visitMethodRefExpr(expr)
        //methodRef是火锅的调用
        //1.检查访问有效性
        guard let varExpr: VarExpr = expr.lhs as? VarExpr else {
            error(.canNotCallMethod(name: expr.funcCall.varExpr.name))
            return
        }
        //2.检查火锅是否有这个方法
        //todo: 这里可以做个缓存优化
        var flag = false
        for hotpot in context.hotpots {
            if let d = varExpr.decl as? HotpotDecl {
                if d.name == hotpot.name {
                    for method in d.methods {
                        if method.prototype.name == expr.funcCall.varExpr.name {
                            flag = true
                        }
                    }
                }
            }
        }
        if !flag {
            error(.unknowFunction(name: expr.funcCall.varExpr.name))
            return
        }
        
    }
    
    public override func visitPropertyRefExpr(_ expr: PropertyRefExpr) {
        super.visitPropertyRefExpr(expr)
        //1.检查访问有效性
        guard let varExpr: VarExpr = expr.lhs as? VarExpr else {
            error(.canNotFindProperty(name: expr.varExpr.name))
            return
        }
        //2.检查火锅是否有这个属性
        var flag = false
        for hotpot in context.hotpots {
            if let d = varExpr.decl as? HotpotDecl {
                if d.name == hotpot.name {
                    for property in d.properties {
                        if property.name == expr.varExpr.name {
                            flag = true
                        }
                    }
                }
            }
        }
        if !flag {
            error(.canNotFindProperty(name: expr.varExpr.name))
            return
        }
    }
    
    public override func visitArrayExpr(_ expr: ArrayExpr) {
        super.visitArrayExpr(expr)
        guard case .array(let valueType) = expr.type else {
            fatalError("严重错误，数组AST的type不是array")
        }
        for value in expr.values {
            if value.type != valueType {
                error(.canNotConvertValue(t1: value.type, t2: valueType))
            }
        }
    }
    
    public override func visitVarExpr(_ expr: VarExpr) {
        super.visitVarExpr(expr)
        //1.找到它的声明
        if currentHotpot != nil {
            //火锅里找找有没有这个属性
            for property in currentHotpot!.properties {
                if property.name == expr.name {
                    expr.decl = property
                    break
                }
            }
        } else if currentFunction != nil {
            //方法参数里找找
            currentFunction!.prototype.params.forEach({
                if $0.name == expr.name {
                    expr.decl = $0
                    return
                }
            })
            if expr.decl == nil {
                currentFunction!.body.stmts.forEach({
                    if let stmt: ExprStmt = $0 as? ExprStmt {
                        //如果遇到varExpr了就停止
                        if let e: VarExpr = stmt.expr as? VarExpr {
                            if e.name == expr.name {
                                return
                            }
                        }
                    } else if let stmt: DeclStmt = $0 as? DeclStmt {
                        if let d = stmt.decl as? VarDecl {
                            if d.name == expr.name {
                                expr.decl = d
                            }
                        }
                    }
                })
            }
        } else {
            //global里找找
            context.globals.forEach({
                if $0.name == expr.name {
                    expr.decl = $0
                }
            })
        }
        //2.检查声明
        if expr.decl == nil {
            error(.unknowVariableName(name: expr.name))
        }
    }
    
    //MARK: Stmt
    
    public override func visitContinueStmt(_ stmt: ContinueStmt) {
        super.visitContinueStmt(stmt)
        if currentBreakTarget == nil {
            error(.continueNotAllowed)
        }
    }
    
    public override func visitBreakStmt(_ stmt: BreakStmt) {
        super.visitBreakStmt(stmt)
        if currentBreakTarget == nil {
            error(.breakNotAllowed)
        }
    }
    
    public override func visitReturnStmt(_ stmt: ReturnStmt) {
        super.visitReturnStmt(stmt)
        if currentFunction == nil {
            error(.returnNotAllowed)
        } else {
            if currentFunction!.prototype.returnType != stmt.value.type {
                error(.unexpectedReturn(type: stmt.value.type.description,
                                        func: currentFunction!.prototype.name))
            }
        }
    }
    
}
