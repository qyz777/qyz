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
    private var currentColumnStart = 0
    
    /// 进入block前的开始列
    private var lastColumnStart: Int {
        guard currentColumnStart - 4 >= 0 else {
            return 0
        }
        return currentColumnStart - 4
    }
    
    private var currentToken: Token {
        guard currentIndex < tokens.count else {
            return Token.eof
        }
        return tokens[currentIndex]
    }
    
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
    }
    
}

// MARK: - 私有便捷方法
private extension Parser {
    
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

//MARK: Function
private extension Parser {
    
    func parseDefinition() -> FunctionNode {
        nextToken()
        let p = parsePrototype()
        let body = parseBlockStmt()
        return FunctionNode(prototype: p, body: body)
    }
    
    func parsePrototype() -> FuncDeclNode {
        skipWhitespace()
        let funcName: String
        if case let Token.identifier(value) = currentToken {
            funcName = value
        } else {
            fatalError("Expected function name.")
        }
        nextToken()
        guard currentToken == .leftParen else {
            fatalError("Expected '(' in decl.")
        }
        nextTokenWithoutWhitespace()
        var args: [Argument] = []
        while currentToken != .eof  {
            guard case let Token.identifier(label) = currentToken else {
                fatalError("Invalid arg name in decl.")
            }
            nextToken()
            guard currentToken == .colon else {
                fatalError("Invalid arg in decl.")
            }
            nextTokenWithoutWhitespace()
            guard case let Token.identifier(type) = currentToken else {
                fatalError("Invalid arg type in decl.")
            }
            let arg = Argument(label: label, type: DataType(name: type))
            args.append(arg)
            nextTokenWithoutWhitespace()
            if currentToken == .comma {
                nextTokenWithoutWhitespace()
            } else if currentToken == .rightParen {
                break
            } else {
                fatalError("Expected ')' in decl.")
            }
        }
        nextToken()
        guard currentToken == .colon else {
            fatalError("Expected ':' in decl.")
        }
        nextTokenWithoutWhitespace()
        if currentToken == .newLine {
            //跳过\n
            nextToken()
            return FuncDeclNode(name: funcName, args: args, returnType: .void)
        } else {
            if case let Token.identifier(type) = currentToken {
                //判断下一个是不是\n
                nextToken()
                guard currentToken == .newLine else {
                    fatalError("Invalid decl.")
                }
                nextToken()
                let type = DataType(name: type)
                return FuncDeclNode(name: funcName, args: args, returnType: type)
            } else {
                fatalError("Invalid return type in decl.")
            }
        }
    }
    
}

//MARK: Stmt
private extension Parser {
    
    func parseStmt() -> Stmt {
        //todo:支持其他Stmt解析
        let stmt: Stmt
        switch currentToken {
        case .if:
            stmt = parseIfStmt()
        case .for:
            stmt = parseForStmt()
        case .while:
            stmt = parseWhileStmt()
        case .break:
            stmt = parseBreakStmt()
        case .continue:
            stmt = parseContinueStmt()
        default:
            stmt = ExprStmt(expr: parseExpr())
        }
        return stmt
    }
    
    /// 解析IfStmt
    ///
    /// - Returns: IfStmt
    func parseIfStmt() -> IfStmt {
        nextTokenWithoutWhitespace()
        let expr = parseExpr()
        checkoutBlock()
        var conditions = [(expr, parseBlockStmt())]
        var elseCondition: BlockStmt? = nil
        //循环解析elif
        while case .elif = currentToken {
            nextTokenWithoutWhitespace()
            let elifExpr = parseExpr()
            checkoutBlock()
            conditions += [(elifExpr, parseBlockStmt())]
        }
        //如果有else则解析else
        if case .else = currentToken {
            nextToken()
            checkoutBlock()
            //else是最后一行，让整个if的stmt去检查newLine
            elseCondition = parseBlockStmt(check: false)
        }
        return IfStmt(conditions: conditions, elseCondition: elseCondition)
    }
    
    /// 解析For循环
    ///
    /// - Returns: ForStmt
    func parseForStmt() -> ForStmt {
        nextTokenWithoutWhitespace()
        let initialzer = parseExpr()
        guard currentToken == .comma else {
            fatalError("Excepted ',' after initialzer in for loop.")
        }
        nextTokenWithoutWhitespace()
        let condition = parseExpr()
        guard currentToken == .comma else {
            fatalError("Excepted ',' after condition in for loop.")
        }
        nextTokenWithoutWhitespace()
        let step = parseExpr()
        checkoutBlock()
        let body = parseBlockStmt()
        return ForStmt(initializer: initialzer, condition: condition, step: step, body: body)
    }
    
    /// 解析While循环
    ///
    /// - Returns: WhileStmt
    func parseWhileStmt() -> WhileStmt {
        nextTokenWithoutWhitespace()
        let condition = parseExpr()
        checkoutBlock()
        let body = parseBlockStmt()
        return WhileStmt(condition: condition, body: body)
    }
    
    /// 解析return <expr>
    ///
    /// - Returns: ReturnStmt
    func parseReturnStmt() -> ReturnStmt {
        nextTokenWithoutWhitespace()
        let value = parseExpr()
        return ReturnStmt(value: value)
    }
    
    /// 解析Break
    ///
    /// - Returns: BreakStmt
    func parseBreakStmt() -> BreakStmt {
        nextTokenWithoutWhitespace()
        return BreakStmt()
    }
    
    /// 解析Continue
    ///
    /// - Returns: ContinueStmt
    func parseContinueStmt() -> ContinueStmt {
        nextTokenWithoutWhitespace()
        return ContinueStmt()
    }
    
    /// 解析BlockStmt
    /// 用来解析一块混合的Stmt
    ///
    /// - Parameter check: 是否检查newLine。block后必须跟一个newLine，否则违反语法
    /// - Returns: BlockStmt
    func parseBlockStmt(check: Bool = true) -> BlockStmt {
        enterBlock()
        var stmts: [Stmt] = []
        while true {
            var whitespaceCount = 0
            while currentToken == .whitespace {
                whitespaceCount += 1
                nextToken()
            }
            //缩进往前了，该结束这个block了，暂时写成0也可以出去
            //todo: 假如会支持class的话这里需要支持类的缩进
            if whitespaceCount == lastColumnStart || whitespaceCount == 0 {
                break
            }
            //缩进有错误
            guard whitespaceCount == currentColumnStart else {
                fatalError("Invalid indentation!")
            }
            stmts.append(parseStmt())
            if check {
                //检查newLine，一个block后必须有newLine，否则违反语法
                guard currentToken == .newLine || currentToken == .eof else {
                    fatalError("The code format does not conform to the specification!")
                }
                skipNewLine()
            }
        }
        leaveBlock()
        return BlockStmt(stmts: stmts)
    }
    
}

//MARK: Expr
private extension Parser {
    
    func parseExpr() -> Expr {
        var expr: Expr!
        switch currentToken {
        case .operator(let op) where op.isUnary:
            nextTokenWithoutWhitespace()
            let val = parseExpr()
            if let num = val as? IntExpr, op == .minus {
                return IntExpr(type: .int64, value: -num.value)
            } else if let num = val as? FloatExpr, op == .minus {
                return FloatExpr(type: .float, value: -num.value)
            } else {
                return UnaryExpr(op: op, rhs: val)
            }
        case .leftParen:
            nextTokenWithoutWhitespace()
            let val = parseExpr()
            guard currentToken == .rightParen else {
                fatalError("Expected ')' after \(val).")
            }
            expr = val
        case .int(let num):
            expr = IntExpr(type: .int64, value: num)
        case .float(let num):
            expr = FloatExpr(type: .float, value: num)
        case .true:
            expr = BoolExpr(value: true)
        case .false:
            expr = BoolExpr(value: false)
        case .null:
            expr = NullExpr(type: .null)
        case .string(let str):
            expr = StringExpr(value: str)
        case .identifier(let str):
            expr = ValExpr(value: str)
        default:
            fatalError("Unknow value in when parsing val expr.")
        }
        nextTokenWithoutWhitespace()
        return parseBinary(0, lhs: &expr)
    }
    
    func parseBinary(_ exprPrec: Int, lhs: inout Expr) -> Expr {
        while true {
            guard case let .operator(op) = currentToken else {
                return lhs
            }
            let tokPrec = getTokenPrecedence()
            if tokPrec < exprPrec {
                return lhs
            }
            nextTokenWithoutWhitespace()
            var rhs = parseExpr()
            let nextPrec = getTokenPrecedence()
            if tokPrec < nextPrec {
                rhs = parseBinary(tokPrec + 1, lhs: &rhs)
            }
            lhs = BinaryExpr(op: op, lhs: lhs, rhs: rhs)
        }
    }
    
    func getTokenPrecedence() -> Int {
        if case let .operator(op) = currentToken {
            return op.precedence
        } else {
            return -1
        }
    }
    
}
