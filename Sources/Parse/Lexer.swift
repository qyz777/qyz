//
//  Lexer.swift
//  Parse
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation
import AST

class Lexer {
    
    public var currentToken: Token?
    
    private var index = 0
    
    private var inputSource: [Character] = []
    
    private var currentChar: Character? {
        guard index < inputSource.count else {
            return nil
        }
        return inputSource[index]
    }
    
}

extension Lexer {
    
    func analyze(input: String) -> [Token] {
        inputSource = Array(input)
        var res: [Token] = []
        while true {
            let tok = advanceToNextToken()
            res.append(tok)
            if tok == .eof {
                break
            }
        }
        return res
    }
    
    func clear() {
        index = 0
        inputSource.removeAll()
    }
    
}

private extension Lexer {
    
    /// 前进到下一个Token
    ///
    /// - Returns: Token
    func advanceToNextToken() -> Token {
        guard currentChar != nil else {
            return .eof
        }
        //跳过注释
        if currentChar! == "#" {
            while currentChar != nil && !currentChar!.isNewline {
                advance()
            }
            return advanceToNextToken()
        }
        if currentChar!.isWhitespace || currentChar!.isNewline {
            let token = Token(symbol: String(currentChar!))
            advance()
            return token
        }
        if currentChar!.isLetter {
            var identifier = String(currentChar!)
            advance()
            while currentChar != nil && (currentChar!.isLetter || currentChar!.isNumber) {
                identifier.append(currentChar!)
                advance()
            }
            return Token(identifier: identifier)
        } else if currentChar!.isNumber {
            var num = String(currentChar!)
            advance()
            var isDouble = false
            if currentChar != nil && currentChar! == "." {
                num.append(currentChar!)
                advance()
                isDouble = true
            }
            while currentChar != nil && currentChar!.isNumber {
                num.append(currentChar!)
                advance()
            }
            return isDouble ? .float(Double(num)!) : .int(Int(num)!)
        } else if currentChar!.isOperator {
            var op = String(currentChar!)
            advance()
            if currentChar != nil && currentChar!.isOperator {
                op.append(currentChar!)
                advance()
            }
            return Token.operator(Operator(rawValue: op)!)
        } else if currentChar!.isDoubleQuote {
            var s = ""
            repeat {
                advance()
                s.append(currentChar!)
            } while currentChar != nil && !currentChar!.isDoubleQuote
            advance()
            return Token.string(s)
        } else if currentChar!.isQuote {
            var s = ""
            repeat {
                advance()
                s.append(currentChar!)
            } while currentChar != nil && !currentChar!.isQuote
            advance()
            return Token.string(s)
        }
        let symbol = Token.init(symbol: String(currentChar!))
        advance()
        return symbol
    }
    
    /// 字符前进
    func advance() {
        index += 1
    }
    
}

extension Character {
    
    static let operatorChars: Set<Character> = Set("~*+-/<>=%^|&!")
    
    var isOperator: Bool {
        return Character.operatorChars.contains(self)
    }
    
    var isDoubleQuote: Bool {
        return self == "\""
    }
    
    var isQuote: Bool {
        return self == "'"
    }
    
}
