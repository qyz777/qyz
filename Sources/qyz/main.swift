//
//  main.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation

let input = """
def abc(a, b, c):
    #   测试
    c = a += b
    return
"""
let lexer = Lexer(input: input)
print(lexer.analyze())

