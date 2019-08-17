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
let p = Parser()
p.parse(input: input1)

