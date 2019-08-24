//
//  main.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation
import Parse

let input = """
def abc(a: int, b: int, c: float):
    #   测试
    c = a += b
    return
"""
let input1 = """
def abc(a: int, b: int, c: float): double
    if a > 1:
        a += 1
    elif a > 2:
        a -= 1
    elif a > 3:
        a -= 3
    else:
        a += 1
a = 100
"""
let input2 = """
def abc(a: int, b: int, c: float): double
    if a > 1:
        a += 1
    elif a > 2:
        a -= 1
    else:
        a += 1
a = 100
"""
let input3 = """
a = 0
for i = 0, i < 10, i += 1:
    a += i
    a -= 1
j = 0
while j < 10:
    a += i
    j += 1
    if a > 5:
        break
    else:
        continue
"""
let p = Parser()
p.parse(input: input3)

