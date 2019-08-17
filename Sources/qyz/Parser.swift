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
    
    private var currentToken: Token? {
        guard currentIndex < tokens.count else {
            return nil
        }
        return tokens[currentIndex]
    }
    
}

extension Parser {
    
    func parse(input: String) {
        tokens = lexer.analyze(input: input)
        guard !tokens.isEmpty else {
            return
        }
        debugPrint(tokens)
        parseTokens()
    }
    
}

extension Parser {
    
    func nextToken() {
        currentIndex += 1
    }
    
    func nextTokenWithoutWhitespace() {
        nextToken()
        skipWhitespace()
    }
    
    func skipWhitespace() {
        while currentToken != nil && (currentToken! == .whitespace || currentToken! == .tab) {
            nextToken()
        }
    }
    
    func parseTokens() {
        guard currentToken != nil else {
            return
        }
        while currentToken != nil && currentToken != .eof {
            if currentToken! == .def {
                parseDefinition()
            }
        }
    }
    
    func parseDefinition() {
        nextToken()
        let p = parsePrototype()
        debugPrint(p)
    }
    
    func parsePrototype() -> PrototypeNode {
        skipWhitespace()
        guard currentToken != nil else {
            fatalError("Expected function name.")
        }
        let funcName: String
        if case let Token.identifier(value) = currentToken! {
            funcName = value
        } else {
            fatalError("Expected function name.")
        }
        nextToken()
        guard currentToken != nil && currentToken! == .leftParen else {
            fatalError("Expected '(' in prototype.")
        }
        nextTokenWithoutWhitespace()
        var args: [Argument] = []
        while currentToken != nil  {
            guard case let Token.identifier(label) = currentToken! else {
                fatalError("Invalid arg name in prototype.")
            }
            nextToken()
            guard currentToken != nil && currentToken! == .colon else {
                fatalError("Invalid arg in prototype.")
            }
            nextTokenWithoutWhitespace()
            guard currentToken != nil, case let Token.identifier(type) = currentToken! else {
                fatalError("Invalid arg type in prototype.")
            }
            let arg = Argument(label: label, type: DataType(name: type))
            args.append(arg)
            nextTokenWithoutWhitespace()
            if currentToken != nil && currentToken! == .comma {
                nextTokenWithoutWhitespace()
            } else if currentToken != nil && currentToken! == .rightParen {
                break
            } else {
                fatalError("Expected ')' in prototype.")
            }
        }
        nextToken()
        guard currentToken != nil && currentToken! == .colon else {
            fatalError("Expected ':' in prototype.")
        }
        nextTokenWithoutWhitespace()
        guard currentToken != nil else {
            fatalError("Invalid prototype.")
        }
        if currentToken! == .newLine {
            //跳过\n
            nextToken()
            return PrototypeNode(name: funcName, args: args, returnType: .void)
        } else {
            if case let Token.identifier(type) = currentToken! {
                //判断下一个是不是\n
                nextToken()
                guard currentToken != nil && currentToken! == .newLine else {
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
