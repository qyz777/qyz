//
//  Type.swift
//  AST
//
//  Created by Q YiZhong on 2019/8/17.
//

import Foundation

public enum FloatType {
    case float
    case double
}

public enum DataType: Hashable {
    
    //这么写方便拓展其他Int类型
    case int(width: Int, signed: Bool)
    case float(type: FloatType)
    case bool
    case string
    case hotpot(name: String)
    case null
    indirect case array(type: DataType)
    indirect case def(args: [DataType], returnType: DataType)
    case `default`
    
    public static let int64 = DataType.int(width: 64, signed: true)
    public static let float = DataType.float(type: .float)
    public static let double = DataType.float(type: .double)
    
    public init(name: String) {
        switch name {
        case "int": self = .int64
        case "bool": self = .bool
        case "float": self = .float
        case "double": self = .double
        case "string": self = .string
        case "null": self = .null
        default: self = .default
        }
    }
    
}

extension DataType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .int(let w, _):
            return "int\(w)"
        case .float(let t):
            return t == .double ? "double" : "float"
        case .bool:
            return "bool"
        case .string:
            return "string"
        case .hotpot(let name):
            return name
        case .null:
            return "null"
        case .array(let t):
            return "[\(t.description)]"
        case .def(_, _):
            return "function"
        default:
            return "Unknow"
        }
    }
    
}

//暂时这两者与父类还无区别
//public class PropertyDecl: VarDecl {}
//
//public class MethodDecl: FuncDecl {}

/// 🍲 ::= hotpot <hotpot-name> : <data-type> [<var-decl>, <func-decl>]
//TODO: 初始化方法还没做
public class HotpotDecl: Decl {
    
    private(set) public var properties: [VarDecl] = []
    
    private(set) public var methods: [FuncDecl] = []
    
    private var parent: HotpotDecl?
    
    public let parentName: String?
    
    public let name: String
    
    public init(name: String, parentName: String? = nil) {
        self.name = name
        self.parentName = parentName
        super.init(type: .hotpot(name: name))
    }
    
    public func addMethod(_ method: FuncDecl) {
        methods.append(method)
    }
    
    public func addProperty(_ property: VarDecl) {
        properties.append(property)
    }
    
    public override func description() {
        debugPrint("\(self), properties: \(properties), methods: \(methods)")
    }
    
}
