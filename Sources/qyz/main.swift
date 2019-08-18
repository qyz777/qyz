//
//  main.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation

let input = """
def abc(a: int, b: int, c: float):
    #   测试
    c = a += b
    return
"""
let input1 = """
def abc(a: int, b: int, c: float): double

"""
let input2 = """
a = 3 + 1
b = 7 + a
c = (10 + (a + b))
"""
let p = Parser()
p.parse(input: input2)

