//
//  Tile.swift
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

import Foundation

struct Tile {
    
    enum Content {
        case Empty
        case Mined
    }
    
    enum Exposure {
        case Hidden
        case Flagged
        case Exposed
    }
   
    var content: Content = .Empty
    var current_exposure: Exposure = .Hidden
    var neighborTouches: Int = 0

    static var identifierFactory: Int = 0
    let identifier: Int = Tile.getUniqueIdentifier()
    
    // Row and col get set externally if required by the consumer
    var row: Int?
    var col: Int?
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
}
