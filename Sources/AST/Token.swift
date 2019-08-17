//
//  Token.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation

public enum Token: Equatable {
    case int(Int)
    case float(Double)
    case identifier(String)
    case char(UInt8) // 字符
    case `operator`(Operator)
    case string(String) // 字符串
    case `for`
    case `if`
    case `else`
    case elif
    case `in`
    case `where`
    case `return`
    case `break`
    case `continue`
    case colon // ":"
    case comma // ","
    case ellipsis // "..."
    case ellipsisLess // "..<"
    case leftParen
    case rightParen
    case `true`
    case `false`
    case def
    case newLine
    case whitespace // " "
    case tab // "   "
    case eof
    case unknow(String)
    
    public init(symbol: String) {
        switch symbol {
        case ":":
            self = .colon
        case ",":
            self = .comma
        case "...":
            self = .ellipsis
        case "..<":
            self = .ellipsisLess
        case "(":
            self = .leftParen
        case ")":
            self = .rightParen
        case "\n", "\r":
            self = .newLine
        case " ":
            self = .whitespace
        case "\t":
            self = .tab
        default:
            self = .unknow(symbol)
        }
    }
    
    public init(identifier: String) {
        switch identifier {
        case "def":
            self = .def
        case "for":
            self = .for
        case "if":
            self = .if
        case "else":
            self = .else
        case "elif":
            self = .elif
        case "in":
            self = .in
        case "where":
            self = .where
        case "break":
            self = .break
        case "continue":
            self = .continue
        case "true":
            self = .true
        case "false":
            self = .false
        default:
            self = .identifier(identifier)
        }
    }
    
    public var isNum: Bool {
        switch self {
        case .float(_):
            return true
        case .int(_):
            return true
        default:
            return false
        }
    }
    
}
