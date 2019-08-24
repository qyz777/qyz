//
//  ExprParser.swift
//  AST
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
        case .identifier(let str):
            nextToken()
            if currentToken == .colon {
                //类型声明
                nextTokenWithoutWhitespace()
                if currentToken == .leftBracket {
                    var bracketCount = 0
                    while currentToken == .leftBracket {
                        bracketCount += 1
                        nextTokenWithoutWhitespace()
                    }
                    guard case let .identifier(type) = currentToken else {
                        fatalError("Expected data type after \(str).")
                    }
                    let dataType = DataType(name: type)
                    nextTokenWithoutWhitespace()
                    guard currentToken == .rightBracket else {
                        fatalError("Expected ']' after type: \(type).")
                    }
                    while currentToken == .rightBracket {
                        bracketCount -= 1
                        nextTokenWithoutWhitespace()
                    }
                    guard bracketCount == 0 else {
                        fatalError("Expected ']' after type: \(type).")
                    }
                    expr = ArrayDecl(type: dataType, value: str)
                } else {
                    guard case let .identifier(type) = currentToken else {
                        fatalError("Expected data type after \(str).")
                    }
                    let dataType = DataType(name: type)
                    nextTokenWithoutWhitespace()
                    identifierSet.insert(str)
                    expr = ValDecl(type: dataType, value: str)
                }
            } else {
                guard identifierSet.contains(str) else {
                    fatalError("\(str) must be declared before use!")
                }
                expr = ValExpr(value: str)
            }
            skipWhitespace()
            return parseBinary(0, lhs: &expr)
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
