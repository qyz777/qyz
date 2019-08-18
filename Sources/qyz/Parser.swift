//
//  Parser.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation
import AST

public class Parser {
    
    private let lexer = Lexer()
    
    private var currentIndex = 0
    
    private var tokens: [Token] = []
    
    private var currentToken: Token {
        guard currentIndex < tokens.count else {
            return Token.eof
        }
        return tokens[currentIndex]
    }
    
}

public extension Parser {
    
    func parse(input: String) {
        tokens = lexer.analyze(input: input)
        guard !tokens.isEmpty else {
            return
        }
        debugPrint(tokens)
        while currentToken != .eof {
            if currentToken == .def {
                parseDefinition()
            } else if case .identifier(_) = currentToken {
                let v = parseValueExpr()
                v.description()
            } else {
                nextToken()
            }
        }
    }
    
}

private extension Parser {
    
    func nextToken() {
        currentIndex += 1
    }
    
    func nextTokenWithoutWhitespace() {
        nextToken()
        skipWhitespace()
    }
    
    func skipWhitespace() {
        while currentToken == .whitespace || currentToken == .tab {
            nextToken()
        }
    }
    
    func parseDefinition() {
        nextToken()
        let p = parsePrototype()
        debugPrint(p)
    }
    
    func parsePrototype() -> PrototypeNode {
        skipWhitespace()
        let funcName: String
        if case let Token.identifier(value) = currentToken {
            funcName = value
        } else {
            fatalError("Expected function name.")
        }
        nextToken()
        guard currentToken == .leftParen else {
            fatalError("Expected '(' in prototype.")
        }
        nextTokenWithoutWhitespace()
        var args: [Argument] = []
        while currentToken != .eof  {
            guard case let Token.identifier(label) = currentToken else {
                fatalError("Invalid arg name in prototype.")
            }
            nextToken()
            guard currentToken == .colon else {
                fatalError("Invalid arg in prototype.")
            }
            nextTokenWithoutWhitespace()
            guard case let Token.identifier(type) = currentToken else {
                fatalError("Invalid arg type in prototype.")
            }
            let arg = Argument(label: label, type: DataType(name: type))
            args.append(arg)
            nextTokenWithoutWhitespace()
            if currentToken == .comma {
                nextTokenWithoutWhitespace()
            } else if currentToken == .rightParen {
                break
            } else {
                fatalError("Expected ')' in prototype.")
            }
        }
        nextToken()
        guard currentToken == .colon else {
            fatalError("Expected ':' in prototype.")
        }
        nextTokenWithoutWhitespace()
        if currentToken == .newLine {
            //跳过\n
            nextToken()
            return PrototypeNode(name: funcName, args: args, returnType: .void)
        } else {
            if case let Token.identifier(type) = currentToken {
                //判断下一个是不是\n
                nextToken()
                guard currentToken == .newLine else {
                    fatalError("Invalid prototype.")
                }
                nextToken()
                let type = DataType(name: type)
                return PrototypeNode(name: funcName, args: args, returnType: type)
            } else {
                fatalError("Invalid return type in prototype.")
            }
        }
    }
    
}

//MARK: Value
private extension Parser {
    
    func parseValueExpr() -> Expr {
        var expr: Expr!
        switch currentToken {
        case .operator(let op) where op.isUnary:
            nextTokenWithoutWhitespace()
            let val = parseValueExpr()
            if let num = val as? IntExpr, op == .minus {
                return IntExpr(type: .int64, value: -num.value)
            } else if let num = val as? FloatExpr, op == .minus {
                return FloatExpr(type: .float, value: -num.value)
            } else {
                return UnaryExpr(op: op, rhs: val)
            }
        case .leftParen:
            nextTokenWithoutWhitespace()
            let val = parseValueExpr()
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
        case .identifier(let str):
            expr = ValExpr(value: str)
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
            var rhs = parseValueExpr()
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
