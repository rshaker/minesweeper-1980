//
//  InfoView.swift
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

import SwiftUI

struct InfoView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    Text("Instructions").font(.title)
                    Text("The object of minesweeper is to clear the board of all mines 💣 in the shortest amount of time, without blowing yourself up. To clear the board, you must expose 🧹 all empty tiles and plant flags 🚩 over all hidden mines.")
                    Text("Starting game").font(.title)
                    Text("To start a new game, tap the smiley emoji in the center of the scoreboard. The smiley's facial expression indicates the game's current state:")
                }
                VStack {
                    HStack(spacing: 15) {
                        Text("😴")
                        Text("Game is ready to start")
                        Spacer()
                    }
                    .padding(.top, 3)
                    HStack(spacing: 15) {
                        Text("🙂")
                        Text("Game is in-progress")
                        Spacer()
                    }
                    .padding(.top, 3)
                    HStack(spacing: 15) {
                        Text("🤬")
                        Text("A mine exploded, you're dead!")
                        Spacer()
                    }
                    .padding(.top, 3)
                    HStack(spacing: 15) {
                        Text("🤪")
                        Text("You won! marvel at your victory")
                        Spacer()
                    }
                    .padding(.top, 3)
                }
                .padding(.all, 5)
                Group {
                    Text("Mode toggle").font(.title)
                    Text("The mode-toggle button switches gameplay between sweeping mines 🧹 and planting flags 🚩.  You can also plant flags using a long-press gesture ≥ 2 seconds regardless of mode.")
                    Text("Adjacent tiles").font(.title)
                    Text("Exposed tiles that display a number (1-8) indicate the number of adjacent tiles containing mines.")
                    Text("Zooming in/out").font(.title)
                    Text("Pinch fingers 👌 to zoom-out. Spread fingers ✌️ to zoom-in. When enabled, double-tap game board to zoom max in/out.")
                    Text("Settings changes").font(.title)
                    Text("Most settings ⚙️ changes take effect on game reset or application restart.")
                    Text("There is no pause, but there is an undo. Safe first-move makes sure don't blow yourself up right away 😱 You'll be lucky to survive, just be happy with that 🌸")
                }
                Group {
                    Text("Support").font(.title)
                    Text("Source code and issue reporting available at https://github.com/rshaker/minesweeper-1980")
                }
                Spacer()
            }
            .padding()
        }
        .padding()
        .background(colorScheme == .light ? Color(UIColor.init(hex: "#89CFF0")) : Color(UIColor.init(hex: "#053952")))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
