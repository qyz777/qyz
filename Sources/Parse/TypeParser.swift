//
//  TypeParser.swift
//  Parse
//
//  Created by Q YiZhong on 2019/9/3.
//

import Foundation
import AST

extension Parser {
    
    /// 解析hotpot
    ///
    /// - Returns: Hotpot
    func parseHotpot() -> HotpotDecl {
        nextTokenWithoutWhitespace()
        guard case .identifier(let name) = currentToken else {
            fatalError("Excepted hotpot name.")
        }
        nextTokenWithoutWhitespace()
        guard currentToken == .colon else {
            fatalError("Excepted ':' after hotpot.")
        }
        nextTokenWithoutWhitespace()
        var parentHotpotName: String? = nil
        if case .identifier(let parentName) = currentToken {
            parentHotpotName = parentName
            nextTokenWithoutWhitespace()
        }
        guard currentToken == .newLine else {
            fatalError("The code format does not conform to the specification!")
        }
        nextToken()
        let hotpot = HotpotDecl(name: name, parentName: parentHotpotName)
        enterBlock()
        while true {
            skipNewLine()
            var whitespaceCount = 0
            while currentToken == .whitespace {
                whitespaceCount += 1
                nextToken()
            }
            if currentToken == .newLine || whitespaceCount == 0 {
                break
            }
            guard whitespaceCount == currentColumnStart else {
                fatalError("The code format does not conform to the specification!")
            }
            if currentToken == .def {
                hotpot.addMethod(parseFuncDecl())
            } else {
                hotpot.addProperty(parseVarDecl())
            }
        }
        leaveBlock()
        return hotpot
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
    
//    private func parseProperty() -> PropertyDecl {
//
//    }
//
//    private func parseMethod() -> MethodDecl {
//
//    }
    
}
