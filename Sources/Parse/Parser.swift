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
    
    /// 进入一个block后+4，当前代码必须从此列开始，否则不符合规范
    var currentColumnStart = 0
    
    /// 进入block前的开始列
    var lastColumnStart: Int {
        guard currentColumnStart - 4 >= 0 else {
            return 0
        }
        return currentColumnStart - 4
    }
    
    var currentToken: Token {
        guard currentIndex < tokens.count else {
            return Token.eof
        }
        return tokens[currentIndex]
    }
    
    /// 记录标识符是否声明过
    var identifierSet: Set<String> = []
    
    public init() {}
    
}

public extension Parser {
    
    func parse(input: String) {
        tokens = lexer.analyze(input: input)
        guard !tokens.isEmpty else {
            return
        }
        while currentToken != .eof {
            if currentToken == .def {
                let def = parseDefinition()
                def.description()
            } else if currentToken.isWhitespace {
                nextToken()
            } else {
                let s = parseStmt()
                s.description()
            }
        }
        identifierSet.removeAll()
    }
    
}

// MARK: - 私有便捷方法
extension Parser {
    
    /// 下一个token
    func nextToken() {
        currentIndex += 1
    }
    
    /// 下一个token，中间是whitespace的忽略
    func nextTokenWithoutWhitespace() {
        nextToken()
        skipWhitespace()
    }
    
    /// 跳过whitespace
    func skipWhitespace() {
        while currentToken == .whitespace || currentToken == .tab {
            nextToken()
        }
    }
    
    /// 跳过newLine
    func skipNewLine() {
        while currentToken == .newLine {
            nextToken()
        }
    }
    
    /// 进入一个block，起始列+4
    func enterBlock() {
        currentColumnStart += 4
    }
    
    /// 离开一个block，起始列-4
    func leaveBlock() {
        currentColumnStart -= 4
    }
    
    /// 检测进入block前有没有`:\n`
    func checkoutBlock() {
        guard currentToken == .colon else {
            fatalError("Expected ':'.")
        }
        nextToken()
        guard currentToken == .newLine || currentToken == .eof else {
            fatalError("The code format does not conform to the specification!")
        }
        nextToken()
    }
    
}
