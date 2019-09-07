//
//  main.swift
//  LLVM
//
//  Created by Q YiZhong on 2019/8/11.
//

import Foundation
import Parse

let input = """
a: [int] = [1, 2, 3, 4]
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
a = abc(a: 10, b: 1, c: 1.1)
"""
let input3 = """
a: int = 0
for i: int = 0, i < 10, i += 1:
    a += i
    a -= 1
j: int = 0
while j < 10:
    a += i
    j += 1
    if a > 5:
        break
    else:
        continue
"""
let input4 = """
a: string = '123'
"""
let input5 = """
hotpot abc:

    a: int = 1
    b: int

    def abc(a: int, b: int, c: float): double
        if a > 1:
            a += 1
        elif a > 2:
            a -= 1
        else:
            a += 1
        a = abc(a: 10, b: 1, c: 1.1)
        return a

a: int = 0
for i: int = 0, i < 10, i += 1:
    a += i
    a -= 1
    j: int = 0
while j < 10:
    a += i
    j += 1
    if a > 5:
        break
    else:
        continue

h = abc()
c = h.abc(a: 1, b: 2, c: 3)
d = h.a
"""

let p = Parser()
p.parse(input: input)
p.parse(input: input1)
p.parse(input: input2)
p.parse(input: input3)
p.parse(input: input4)
p.parse(input: input5)

