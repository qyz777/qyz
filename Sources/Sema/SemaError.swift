//
//  SemaError.swift
//  Sema
//
//  Created by Q YiZhong on 2019/9/3.
//

import Foundation
import AST

public enum SemaError: Error {
    
    case unknowFunction(name: String)
    case unknowVariableName(name: String)
    case notDeclareVariable(name: String)
    case unknowDataType(type: DataType)
    case breakNotAllowed
    case continueNotAllowed
    
}

extension SemaError: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .unknowFunction(let name):
            return "unknow function name: '\(name)'"
        case .unknowVariableName(let name):
            return "unknow variable name: '\(name)'"
        case .notDeclareVariable(let name):
            return "variable '\(name)' must be declared before use"
        case .unknowDataType(let type):
            return "unknow data type: '\(type)'"
        case .breakNotAllowed:
            return "'break' not allowed outside of loop"
        case .continueNotAllowed:
            return "'continue' not allowed outside of loop"
        }
    }
    
}
