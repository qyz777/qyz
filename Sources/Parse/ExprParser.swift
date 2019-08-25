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
                expr = parseFuncCallExpr()
            } else {
                expr = VarExpr(name: name)
            }
        default:
            fatalError("Unknow value in when parsing val expr.")
        }
        nextTokenWithoutWhitespace()
        return parseBinary(0, lhs: &expr)
    }
    
    func parseBinary(_ exprPrec: Int, lhs: inout Expr) -> Expr {
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
                rhs = parseBinary(tokPrec + 1, lhs: &rhs)
            }
            lhs = BinaryExpr(op: op, lhs: lhs, rhs: rhs)
        }
    }
    
    func getTokenPrecedence() -> Int {
        if case let .operator(op) = currentToken {
            return op.precedence
        } else {
            return -1
        }
    }
    
}
