//
//  DataType.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation

public enum FloatType {
    case float
    case double
}

public enum DataType {
    
    //这么写方便拓展其他Int类型
    case int(width: Int, signed: Bool)
    case float(type: FloatType)
    case bool
    case void
    case string
    case variable
    case null
    
    case `default`
    
    public static let int64 = DataType.int(width: 64, signed: true)
    public static let float = DataType.float(type: .float)
    public static let double = DataType.float(type: .double)
    
    public init(name: String) {
        switch name {
        case "int": self = .int64
        case "bool": self = .bool
        case "void": self = .void
        case "float": self = .float
        case "double": self = .double
        case "null": self = .null
        default: self = .string
        }
    }
    
}
