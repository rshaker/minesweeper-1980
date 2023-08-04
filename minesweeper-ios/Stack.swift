//
//  Stack.swift
//
//  Created by Ronald Shaker on 4/11/20.
//  Copyright © 2020 Ronald Shaker.
//
//  This file is part of minesweeper-ios.
//
//  minesweeper-ios is free software: you can redistribute it and/or modify
//  it under the terms of the MIT License as published by
//  the Free Software Foundation.
//
//  You should have received a copy of the MIT License along with this program.
//  If not, see <https://opensource.org/licenses/MIT>.
//

struct Stack<Element> {
    
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element? {
        return items.isEmpty ? nil : items.removeLast()
    }
}
