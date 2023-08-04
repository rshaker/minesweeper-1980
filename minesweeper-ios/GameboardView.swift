//
//  GameboardView.swift
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

import UIKit

class GameboardView: UIView, UIScrollViewDelegate {

    var tileButtons: [[TileButton?]]!
    var board: Board!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    convenience init(_ board: Board) {
        self.init(frame: CGRect.zero)
        
        self.board = board
        initViews()
    }
    
    func initViews() {
        tileButtons = Array(repeating: Array(repeating: nil, count: board.rows), count: board.cols)
        for col in 0 ..< board.cols {
            for row in 0 ..< board.rows {
                let buttonFrame = CGRect(x: col * Constants.boardButtonCellWidth, y: row * Constants.boardButtonCellHeight, width: Constants.boardButtonCellWidth, height: Constants.boardButtonCellHeight)
                let button = TileButton(frame: buttonFrame)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.row = row
                button.col = col
                button.identifier = board.tile(button.row, button.col).identifier
                tileButtons[col][row] = button
                addSubview(button)
                
                button.leadingAnchor.constraint(equalTo: (col == 0 ? leadingAnchor : tileButtons[col - 1][row]!.trailingAnchor), constant: 0).isActive = true
                button.topAnchor.constraint(equalTo: (row == 0 ? topAnchor : tileButtons[col][row - 1]!.bottomAnchor), constant: 0).isActive = true
            }
        }
        
        bottomAnchor.constraint(equalTo: tileButtons[board.cols - 1][board.rows - 1]!.bottomAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: tileButtons[board.cols - 1][board.rows - 1]!.trailingAnchor, constant: 0).isActive = true
    }
 }
