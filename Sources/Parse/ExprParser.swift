//
//  ExprParser.swift
//  Parse
//
//  Created by Q YiZhong on 2019/8/24.
//

import Foundation
import AST

extension Parser {
    
    func parseExpr() -> Expr {
        var expr: Expr!
        switch currentToken {
        case .operator(let op) where op.isUnary:
            nextTokenWithoutWhitespace()
            let val = parseExpr()
            if let num = val as? IntExpr, op == .minus {
                return IntExpr(type: .int64, value: -num.value)
            } else if let num = val as? FloatExpr, op == .minus {
                return FloatExpr(type: .float, value: -num.value)
            } else {
                return UnaryExpr(op: op, rhs: val)
            }
        case .leftParen:
            nextTokenWithoutWhitespace()
            let val = parseExpr()
            guard currentToken == .rightParen else {
                fatalError("Expected ')' after \(val).")
            }
            expr = val
        case .int(let num):
            expr = IntExpr(type: .int64, value: num)
        case .float(let num):
            expr = FloatExpr(type: .float, value: num)
        case .true:
            expr = BoolExpr(value: true)
        case .false:
            expr = BoolExpr(value: false)
        case .null:
            expr = NullExpr(type: .null)
        case .string(let str):
            expr = StringExpr(value: str)
        case .leftBracket:
            nextTokenWithoutWhitespace()
            var values: [Expr] = []
            while true {
                values.append(parseExpr())
                if currentToken == .rightBracket {
                    break
                }
                guard currentToken == .comma else {
                    fatalError("Expected ',' in array.")
                }
                nextTokenWithoutWhitespace()
            }
            expr = ArrayExpr(values: values)
        case .identifier(let name):
            if nextCurrentToken == .leftParen {
                //这里无需操心解析的是火锅还是函数，因为既是这里是火锅，也可以被看作是隐式的调用火锅的初始化方法
                expr = parseFuncCallExpr()
            } else {
                expr = VarExpr(name: name)
            }
        default:
            fatalError("Unknow value in when parsing val expr.")
        }
        nextTokenWithoutWhitespace()
        switch currentToken {
        case .operator(_):
            expr = parseBinaryExpr(0, lhs: &expr)
        case .dot:
            //解析火锅方法调用或者火锅属性调用
            while true {
                nextTokenWithoutWhitespace()
                //todo:这里可能不只是identifier
                guard case .identifier(let name) = currentToken else {
                    fatalError("Excepted name after '.'.")
                }
                //看两位
                if nextCurrentToken == .leftParen {
                    let funcCall = parseFuncCallExpr()
                    nextTokenWithoutWhitespace()
                    expr = MethodRefExpr(lhs: expr, funcCall: funcCall)
                    if currentToken != .dot {
                        break
                    }
                } else if nextCurrentToken == .dot {
                    let varExpr = VarExpr(name: name)
                    expr = PropertyRefExpr(lhs: expr, varExpr: varExpr)
                    nextTokenWithoutWhitespace()
                    continue
                } else {
                    let varExpr = VarExpr(name: name)
                    expr = PropertyRefExpr(lhs: expr, varExpr: varExpr)
                    nextTokenWithoutWhitespace()
                    break
                }
            }
        default:
            break
        }
        return expr
    }
    
    private func parseBinaryExpr(_ exprPrec: Int, lhs: inout Expr) -> Expr {
        while true {
            guard case let .operator(op) = currentToken else {
                return lhs
            }
            let tokPrec = getTokenPrecedence()
            if tokPrec < exprPrec {
                return lhs
            }
            nextTokenWithoutWhitespace()
            var rhs = parseExpr()
            let nextPrec = getTokenPrecedence()
            if tokPrec < nextPrec {
                rhs = parseBinaryExpr(tokPrec + 1, lhs: &rhs)
            }
            lhs = BinaryExpr(op: op, lhs: lhs, rhs: rhs)
        }
    }
    
    private func getTokenPrecedence() -> Int {
        if case let .operator(op) = currentToken {
            return op.precedence
        } else {
            return -1
        }
    }
    
}
