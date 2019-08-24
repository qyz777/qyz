//
//  FunctionParser.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/24.
//

import Foundation
import AST

extension Parser {
    
    func parseDefinition() -> FunctionNode {
        nextToken()
        let p = parsePrototype()
        let body = parseBlockStmt()
        return FunctionNode(prototype: p, body: body)
    }
    
    func parsePrototype() -> FuncDeclNode {
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
        var args: [Argument] = []
        while currentToken != .eof  {
            guard case let Token.identifier(label) = currentToken else {
                fatalError("Invalid arg name in decl.")
            }
            nextToken()
            guard currentToken == .colon else {
                fatalError("Invalid arg in decl.")
            }
            nextTokenWithoutWhitespace()
            guard case let Token.identifier(type) = currentToken else {
                fatalError("Invalid arg type in decl.")
            }
            let arg = Argument(label: label, type: DataType(name: type))
            args.append(arg)
            nextTokenWithoutWhitespace()
            if currentToken == .comma {
                nextTokenWithoutWhitespace()
            } else if currentToken == .rightParen {
                break
            } else {
                fatalError("Expected ')' in decl.")
            }
        }
        nextToken()
        guard currentToken == .colon else {
            fatalError("Expected ':' in decl.")
        }
        nextTokenWithoutWhitespace()
        if currentToken == .newLine {
            //跳过\n
            nextToken()
            return FuncDeclNode(name: funcName, args: args, returnType: .void)
        } else {
            if case let Token.identifier(type) = currentToken {
                //判断下一个是不是\n
                nextToken()
                guard currentToken == .newLine else {
                    fatalError("Invalid decl.")
                }
                nextToken()
                let type = DataType(name: type)
                return FuncDeclNode(name: funcName, args: args, returnType: type)
            } else {
                fatalError("Invalid return type in decl.")
            }
        }
    }
    
}
