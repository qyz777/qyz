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
    case null
    case `for`
    case `if`
    case `else`
    case elif
    case `in`
    case `while`
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
    case tab // "\t"
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
        case "while":
            self = .while
        case "break":
            self = .break
        case "continue":
            self = .continue
        case "true":
            self = .true
        case "false":
            self = .false
        case "null":
            self = .null
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
    
    public var isWhitespace: Bool {
        switch self {
        case .whitespace, .newLine, .tab:
            return true
        default:
            return false
        }
    }
    
    public var count: Int {
        switch self {
        case .int(let i):
            return "\(i)".count
        case .float(let f):
            return "\(f)".count
        case .identifier(let id):
            return id.count
        case .char(let u):
            return "\(u)".count
        case .operator(let o):
            return o.rawValue.count
        case .string(let s):
            return s.count
        case .null, .else, .elif, .true:
            return 4
        case .for, .def:
            return 3
        case .if, .in, .tab:
            return 2
        case .while, .break, .false:
            return 5
        case .return:
            return 6
        case .continue:
            return 8
        case .colon, .comma, .whitespace:
            return 1
        case .ellipsis, .ellipsisLess:
            return 3
        case .leftParen, .rightParen:
            return 1
        case .newLine:
            return 7
        case .eof:
            return 0
        case .unknow(let s):
            return s.count
        }
    }
    
}
