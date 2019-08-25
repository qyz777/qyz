//
//  FunctionParser.swift
//  Parse
//
//  Created by Q YiZhong on 2019/8/24.
//

import Foundation
import AST

extension Parser {
    
    /// 解析函数声明
    ///
    /// - Returns: FuncNode
    func parseDefinition() -> FuncNode {
        nextToken()
        let p = parsePrototype()
        let body = parseBlockStmt()
        return FuncNode(prototype: p, body: body)
    }
    
    /// 解析函数调用
    ///
    /// - Returns: FuncCallExpr
    func parseFuncCallExpr() -> FuncCallExpr {
        guard case .identifier(let name) = currentToken else {
            fatalError("Excepted available funcion name but current is '\(currentToken)'.")
        }
        nextTokenWithoutWhitespace()
        guard currentToken == .leftParen else {
            fatalError("Excepted '(' after \(name).")
        }
        nextTokenWithoutWhitespace()
        let args = parseArguments()
        return FuncCallExpr(name: name, args: args)
    }
    
    private func parsePrototype() -> FuncPrototype {
        skipWhitespace()
        let funcName: String
        if case let Token.identifier(value) = currentToken {
            funcName = value
        } else {
            fatalError("Expected function name.")
        }
        nextToken()
        guard currentToken == .leftParen else {
            fatalError("Expected '(' in decl.")
        }
        nextTokenWithoutWhitespace()
        let params: [ParamDecl] = parseParams()
        nextToken()
        guard currentToken == .colon else {
            fatalError("Expected ':' in decl.")
        }
        nextTokenWithoutWhitespace()
        if currentToken == .newLine {
            //跳过\n
            nextToken()
            return FuncPrototype(name: funcName, params: params, returnType: .void)
        } else {
            if case let Token.identifier(type) = currentToken {
                //判断下一个是不是\n
                nextToken()
                guard currentToken == .newLine else {
                    fatalError("Invalid decl.")
                }
                nextToken()
                let type = DataType(name: type)
                return FuncPrototype(name: funcName, params: params, returnType: type)
            } else {
                fatalError("Invalid return type in decl.")
            }
        }
    }
    
    private func parseParams() -> [ParamDecl] {
        var params: [ParamDecl] = []
        while currentToken != .eof  {
            params.append(parseParamDecl())
            nextTokenWithoutWhitespace()
            if currentToken == .comma {
                nextTokenWithoutWhitespace()
            } else if currentToken == .rightParen {
                break
            } else {
                fatalError("Expected ')' in decl.")
            }
        }
        return params
    }
    
    private func parseArguments() -> [Argument] {
        var args: [Argument] = []
        while currentToken != .eof  {
            guard case let Token.identifier(label) = currentToken else {
                fatalError("Invalid argument's label.")
            }
            nextTokenWithoutWhitespace()
            guard currentToken == .colon else {
                fatalError("Expected ':' after \(label).")
            }
            nextTokenWithoutWhitespace()
            let val = parseExpr()
            let arg = Argument(label: label, val: val)
            args.append(arg)
            if currentToken == .comma {
                nextTokenWithoutWhitespace()
            } else if currentToken == .rightParen {
                break
            } else {
                fatalError("Expected ')' in decl.")
            }
        }
        return args
    }
    
}
