//
//  StatementParser.swift
//  Parse
//
//  Created by Q YiZhong on 2019/8/24.
//

import Foundation
import AST

extension Parser {
    
    func parseStmt() -> Stmt {
        let stmt: Stmt
        switch currentToken {
        case .if:
            stmt = parseIfStmt()
        case .for:
            stmt = parseForStmt()
        case .while:
            stmt = parseWhileStmt()
        case .break:
            stmt = parseBreakStmt()
        case .continue:
            stmt = parseContinueStmt()
        case .return:
            stmt = parseReturnStmt()
        case .identifier(_):
            if nextCurrentToken == .colon {
                //多看下一个token，是':'就说明是变量声明
                stmt = DeclStmt(decl: parseVarDecl())
            } else {
                stmt = ExprStmt(expr: parseExpr())
            }
        default:
            stmt = ExprStmt(expr: parseExpr())
        }
        return stmt
    }
    
    /// 解析IfStmt
    ///
    /// - Returns: IfStmt
    func parseIfStmt() -> IfStmt {
        nextTokenWithoutWhitespace()
        let expr = parseExpr()
        checkoutBlock()
        var conditions = [(expr, parseBlockStmt())]
        var elseCondition: BlockStmt? = nil
        //循环解析elif
        while case .elif = currentToken {
            nextTokenWithoutWhitespace()
            let elifExpr = parseExpr()
            checkoutBlock()
            conditions += [(elifExpr, parseBlockStmt())]
        }
        //如果有else则解析else
        if case .else = currentToken {
            nextToken()
            checkoutBlock()
            //else是最后一行，让整个if的stmt去检查newLine
            elseCondition = parseBlockStmt(check: false)
        }
        return IfStmt(conditions: conditions, elseCondition: elseCondition)
    }
    
    /// 解析For循环
    ///
    /// - Returns: ForStmt
    func parseForStmt() -> ForStmt {
        nextTokenWithoutWhitespace()
        let initialzer = parseVarDecl()
        guard currentToken == .comma else {
            fatalError("Excepted ',' after initialzer in for loop.")
        }
        nextTokenWithoutWhitespace()
        let condition = parseExpr()
        guard currentToken == .comma else {
            fatalError("Excepted ',' after condition in for loop.")
        }
        nextTokenWithoutWhitespace()
        let step = parseExpr()
        checkoutBlock()
        let body = parseBlockStmt()
        return ForStmt(initializer: initialzer, condition: condition, step: step, body: body)
    }
    
    /// 解析While循环
    ///
    /// - Returns: WhileStmt
    func parseWhileStmt() -> WhileStmt {
        nextTokenWithoutWhitespace()
        let condition = parseExpr()
        checkoutBlock()
        let body = parseBlockStmt()
        return WhileStmt(condition: condition, body: body)
    }
    
    /// 解析return <expr>
    ///
    /// - Returns: ReturnStmt
    func parseReturnStmt() -> ReturnStmt {
        nextTokenWithoutWhitespace()
        let value = parseExpr()
        return ReturnStmt(value: value)
    }
    
    /// 解析Break
    ///
    /// - Returns: BreakStmt
    func parseBreakStmt() -> BreakStmt {
        nextTokenWithoutWhitespace()
        return BreakStmt()
    }
    
    /// 解析Continue
    ///
    /// - Returns: ContinueStmt
    func parseContinueStmt() -> ContinueStmt {
        nextTokenWithoutWhitespace()
        return ContinueStmt()
    }
    
    /// 解析BlockStmt
    /// 用来解析一块混合的Stmt
    ///
    /// - Parameter check: 是否检查newLine。block后必须跟一个newLine，否则违反语法
    /// - Returns: BlockStmt
    func parseBlockStmt(check: Bool = true) -> BlockStmt {
        enterBlock()
        var stmts: [Stmt] = []
        while true {
            var whitespaceCount = 0
            while currentToken == .whitespace {
                whitespaceCount += 1
                nextToken()
            }
            //缩进往前了，该结束这个block了，暂时写成0也可以出去
            if whitespaceCount == lastColumnStart || whitespaceCount == 0 {
                break
            }
            //缩进有错误
            guard whitespaceCount == currentColumnStart else {
                fatalError("Invalid indentation!")
            }
            stmts.append(parseStmt())
            if check {
                //检查newLine，一个block后必须有newLine，否则违反语法
                guard currentToken == .newLine || currentToken == .eof else {
                    fatalError("The code format does not conform to the specification!")
                }
                skipNewLine()
            }
        }
        leaveBlock()
        return BlockStmt(stmts: stmts)
    }
    
}
