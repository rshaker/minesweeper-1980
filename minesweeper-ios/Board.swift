//
//  Board.swift
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

struct Board {
    enum State {
        case Reset
        case Active
        case Lost
        case Won
    }
    
    var state: State
    var rows, cols, flags: Int
    var tiles = [Tile]()
    
    init(rows: Int, cols: Int, flags: Int) {
        self.rows = rows
        self.cols = cols
        self.flags = flags
                
        for row in 0..<rows {
            for col in 0..<cols {
                var tile = Tile()
                tile.row = row
                tile.col = col
                tiles += [tile]
            }
        }
        
        state = .Reset
        self.reset()
    }
    
    private mutating func reset() {
        // 1st pass to clear the board...
        for var tile in tiles {
            tile.content = .Empty
            tile.current_exposure = .Hidden
        }
        
        // ... and deploy the mines
        var hatOfTiles = tiles
        var minesLeft = flags
        while minesLeft > 0 {
            let tile = hatOfTiles.remove(at: Int.random(in: 0..<hatOfTiles.count))
            let indexMatched = tiles.firstIndex(where: { $0.identifier == tile.identifier })!
            tiles[indexMatched].content = Tile.Content.Mined
            minesLeft -= 1
        }
        
        // 2nd pass to tally each tile's mined neighbor count
        tallyNeighbors()
    }
    
    private mutating func tallyNeighbors() {
        for row in 0..<rows {
            for col in 0..<cols {
                let index = indexOf(row: row, col: col)
                if tiles[index].content != .Mined {
                    tiles[index].neighborTouches = 0
                    for (rowOffset, colOffset) in [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)] {
                        let neighborRow = row + rowOffset
                        let neighborCol = col + colOffset
                        if isOnBoard(row: neighborRow, col: neighborCol) {
                            if tiles[indexOf(row: neighborRow, col: neighborCol)].content == .Mined {
                                tiles[index].neighborTouches += 1
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isOnBoard(row: Int, col: Int) -> Bool {
        return (row >= 0 && row < rows) && (col >= 0 && col < cols)
    }
    
    func indexOf(row: Int, col: Int) -> Int {
        return row * cols + col
    }
    
    func coordsOf(_ index: Int) -> (row: Int, col: Int) {
        let row = index / cols
        let col = index % cols
        return (row, col)
    }
    
    func tile(_ row: Int, _ col: Int) -> Tile {
        return tiles[indexOf(row: row, col: col)]
    }
    
    func tile(_ identifier: Int) -> Tile {
        return tiles[tiles.firstIndex(where: { $0.identifier == identifier })!]
    }
    
    mutating func exposeTile(_ identifier: Int) {
        // Use flood-fill algorithm to expose all empty, un-neighbored tiles starting with a seed tile.
        let seedIndex = tiles.firstIndex(where: { $0.identifier == identifier })!
        if tiles[seedIndex].current_exposure == .Hidden {
            var unprocessed: [Int] = []
            unprocessed.append(seedIndex)
            while !unprocessed.isEmpty {
                let exposeIndex = unprocessed.removeFirst()
                
                // Handle case of safe-first-move.
                if SettingsService.shared.safeFirst, state == .Reset, tiles[exposeIndex].content == .Mined {
                    if addMine() {
                        tiles[exposeIndex].content = .Empty
                        tallyNeighbors()
                    }
                }
                tiles[exposeIndex].current_exposure = .Exposed
                
                // Don't activate board until after safe-first check.
                state = .Active
                
                // A mined tile ends the game and immediately exposes all other mined tiles.
                if tiles[exposeIndex].content == .Mined {
                    state = .Lost
                    for index in tiles.indices {
                        if (tiles[index].content == .Mined) {
                            tiles[index].current_exposure = .Exposed
                        }
                    }
                    return
                }
                
                // Use the "Forest Fire", eight-way, queue-based implementation of flood-fill.
                if tiles[exposeIndex].content == .Empty && tiles[exposeIndex].neighborTouches == 0 {
                    let (row, col) = coordsOf(exposeIndex)
                    for (rowOffset, colOffset) in [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)] {
                        let neighborRow = row + rowOffset
                        let neighborCol = col + colOffset
                        if isOnBoard(row: neighborRow, col: neighborCol) {
                            let neighborIndex = indexOf(row: neighborRow, col: neighborCol)
                            if tiles[neighborIndex].current_exposure == .Hidden && !unprocessed.contains(neighborIndex) {
                                unprocessed.append(neighborIndex)
                            }
                        }
                    }
                }
            }
        }
        
        // Check for winning board.
        if isWinner() {
            state = .Won
        }
    }
    
    mutating func addMine() -> Bool {
        if let index = tiles.firstIndex(where: { $0.content == .Empty && $0.current_exposure == .Hidden }) {
            tiles[index].content = .Mined
            return true
        } else {
            return false
        }
    }
    
    mutating func toggleFlag(_ identifier: Int) {
        let index = tiles.firstIndex(where: { $0.identifier == identifier })!
        if tiles[index].current_exposure == .Hidden && flags > 0 {
            flags -= 1
            tiles[index].current_exposure = .Flagged
        } else if tiles[index].current_exposure == .Flagged {
            flags += 1
            tiles[index].current_exposure = .Hidden
        }
        
        // Check for winning board configuration.
        if isWinner() {
            state = .Won
        } else {
            state = .Active
        }
    }
    
    func isWinner() -> Bool {
// should this block be reverted?
//        if let _ = tiles.firstIndex(where: { $0.exposure == .Hidden }) {
//            return false
//        }
        for tile in tiles {
            if tile.current_exposure == .Hidden {
                return false
            }
        }
        return true
    }
    
    enum RenderMode {
        case Items
        case State
    }
    
    func renderMapAsCharacters(mode: RenderMode? = .Items) {
        // print top line
        print("┌", terminator:"")
        for _ in 1..<cols {
            print("───┬", terminator:"")
        }
        print("───┐")
        
        // print rows and lines
        for row in 1...rows {
            for col in 1...cols {
                
                // print beginning of line
                var value = " "
                let index = (row - 1) * cols + col - 1
                switch mode {
                case .Items:
                    if tiles[index].content == .Mined {
                        value = "*"
                    } else if tiles[index].neighborTouches > 0 {
                        value = String(tiles[index].neighborTouches)
                    }
                case .State:
                    if tiles[index].current_exposure == .Hidden {
                        value = "H"
                    } else if tiles[index].current_exposure == .Exposed {
                        value = "E"
                    }
                case .none:
                    break
                }
                print("│ \(value) ", terminator:"")
            }
            print("│")
            
            // print bottom line(s)
            if (row < rows) {
                print("├───", terminator:"")
                for _ in 1..<cols {
                    print("┼───", terminator:"")
                }
                print("┤")
            } else {
                print("┕───", terminator:"")
                for _ in 1..<cols {
                    print("┴───", terminator:"")
                }
                print("┘")
            }
        }
    }
}
