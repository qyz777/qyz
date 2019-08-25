//
//  DeclarationParser.swift
//  Parse
//
//  Created by Q YiZhong on 2019/8/25.
//

import Foundation
import AST

extension Parser {
    
    /// 解析<var-decl>
    ///
    /// - Returns: VarDecl
    func parseVarDecl() -> VarDecl {
        guard case .identifier(let name) = currentToken else {
            fatalError("Expected identifier but current is '\(currentToken)'.")
        }
        //跳过identifier
        nextTokenWithoutWhitespace()
        guard currentToken == .colon else {
            fatalError("Expected ':' after identifier: \(name).")
        }
        let dataType = parseDataType()
        nextTokenWithoutWhitespace()
        if case .operator(let o) = currentToken {
            guard o == .assign else {
                fatalError("Expected operator assign after ':'.")
            }
            nextTokenWithoutWhitespace()
            let rhs = parseExpr()
            return VarDecl(type: dataType, name: name, rhs: rhs)
        } else {
            return VarDecl(type: dataType, name: name)
        }
    }
    
    /// 解析<param-decl>
    ///
    /// - Returns: ParamDecl
    func parseParamDecl() -> ParamDecl {
        guard case .identifier(let name) = currentToken else {
            fatalError("Expected identifier but current is '\(currentToken)'.")
        }
        nextTokenWithoutWhitespace()
        let dataType = parseDataType()
        return ParamDecl(type: dataType, name: name)
    }
    
    /// 解析 : <data-type>
    ///
    /// - Returns: DataType
    func parseDataType() -> DataType {
        guard currentToken == .colon else {
            fatalError("Expected ':' after identifier.")
        }
        //跳过colon
        nextTokenWithoutWhitespace()
        //解析decl的dataType
        let dataType: DataType
        if currentToken == .leftBracket {
            //解析数组声明类型
            var bracketCount = 0
            while currentToken == .leftBracket {
                bracketCount += 1
                nextTokenWithoutWhitespace()
            }
            guard case let .identifier(type) = currentToken else {
                fatalError("Expected data type after identifier.")
            }
            nextTokenWithoutWhitespace()
            guard currentToken == .rightBracket else {
                fatalError("Expected ']' after type: \(type).")
            }
            while currentToken == .rightBracket {
                bracketCount -= 1
                nextTokenWithoutWhitespace()
            }
            guard bracketCount == 0 else {
                fatalError("Expected ']' after type: \(type).")
            }
            dataType = DataType.array(type: DataType(name: type))
        } else {
            guard case let .identifier(type) = currentToken else {
                fatalError("Expected data type after identifier.")
            }
            dataType = DataType(name: type)
        }
        return dataType
    }
    
}
