//
//  BoardViewController.swift
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

class BoardViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var flagsLabelOutlet: UILabel!
    @IBOutlet weak var emojiButtonOutlet: UIButton!
    @IBOutlet weak var clockLabelOutlet: UILabel!
    @IBOutlet weak var gameboardViewOutlet: UIView!
    @IBOutlet weak var modeButtonOutlet: UIButton!
    @IBOutlet weak var undoButtonOutlet: UIButton!
    @IBOutlet weak var layerOutlet: LayerSKView!
    
    private var board: Board!
    
    private var gameboardView: GameboardView!
    private var cScrollView: CenteringUIScrollView!
    
    private var gameInPlay = false
    
    private var clockStopped = true
    private var clockAccum = 0
    private var timer: Timer?
    
    /// Provides an undo history.
    private var boardStack: Stack<Board>!
    
    /// Plant flags or sweep mines.
    private var mode = "🧹"
        
    @IBAction func emojiButtonAction(_ sender: UIButton) {
        SoundService.shared.playSound(of: .ModeToggle)
        
        let alertController = UIAlertController(title: nil, message: "Restart game?", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: { _ in self.resetGame() })
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func modeButtonAction(_ sender: UIButton) {
        SoundService.shared.playSound(of: .ModeToggle)
        toggleMode()
    }
    
    @IBAction func undoButtonAction(_ sender: UIButton) {
        SoundService.shared.playSound(of: .ModeToggle)
        undoMove()
    }
    
    var scene: CloudLayerSKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scene = CloudLayerSKScene(size: layerOutlet.bounds.size)
//        layerOutlet.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        layerOutlet.presentScene(scene)
        resetGame()
    }
    
    private func resetGame() {
        resetGameboardView()
        addDoubleTapGestureRecognizer()
        addSingleTapAndLongPressGestureRecognizers()
        updateViews()
        stopClock()
        resetClock()
        
        // Okay to check board state, but never set it directly...might need some privacy refactoring in Board
        // board.state = .Active
        gameInPlay = false
        
        // TODO: REMOVE DEBUGGING
//        board.renderMapAsCharacters()
    }
    
    private func resetGameboardView() {
        boardStack = Stack<Board>()
        
        if gameboardView != nil {
            gameboardView.removeFromSuperview()
        }
        
        cScrollView = CenteringUIScrollView()
        cScrollView.contentInsetAdjustmentBehavior = .always
        cScrollView.backgroundColor = UIColor.init(hex: "#005599")
        cScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        gameboardViewOutlet.addSubview(cScrollView)
        
        NSLayoutConstraint.activate([
            cScrollView.topAnchor.constraint(equalTo:gameboardViewOutlet.topAnchor),
            cScrollView.bottomAnchor.constraint(equalTo:gameboardViewOutlet.bottomAnchor),
            cScrollView.leadingAnchor.constraint(equalTo:gameboardViewOutlet.leadingAnchor),
            cScrollView.trailingAnchor.constraint(equalTo:gameboardViewOutlet.trailingAnchor),
        ])

        board = Board(rows: SettingsService.shared.rows, cols: SettingsService.shared.cols, flags: SettingsService.shared.mines)
        gameboardView = GameboardView(board)
        gameboardView.translatesAutoresizingMaskIntoConstraints = false
        
        cScrollView.minimumZoomScale = 0.5;
        cScrollView.maximumZoomScale = 2.0
        cScrollView.zoomScale = 1.0
        cScrollView.addSubview(gameboardView)
        let svclg = cScrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            svclg.topAnchor.constraint(equalTo:gameboardView.topAnchor),
            svclg.bottomAnchor.constraint(equalTo:gameboardView.bottomAnchor),
            svclg.leadingAnchor.constraint(equalTo:gameboardView.leadingAnchor),
            svclg.trailingAnchor.constraint(equalTo:gameboardView.trailingAnchor),
        ])
        cScrollView.delegate = self
    }
    
    /// This function is the backward counterpart to singletap and longpress.
    func undoMove() {
        if let top = boardStack.pop() {
            board = top
            updateViews()
            startClock()
            gameInPlay = true
        }
    }
    
    func toggleMode() {
        mode = mode != "🚩" ? "🚩" : "🧹"
        modeButtonOutlet.setTitle(mode, for: UIControl.State.normal)
    }
        
    private func updateViews() {
        switch board.state {
        case .Reset:
            emojiButtonOutlet.setTitle("😴", for: UIControl.State.normal)
            break
        case .Active:
            emojiButtonOutlet.setTitle("🙂", for: UIControl.State.normal)
            break
        case .Lost:
            emojiButtonOutlet.setTitle("🤬", for: UIControl.State.normal)
            break
        case .Won:
            emojiButtonOutlet.setTitle("🤪", for: UIControl.State.normal)
            break
        }
        
        // Determine state of undo and enable accordingly.
        updateUndoButton()

        // Update flags remaining count.
        flagsLabelOutlet.text = String(board.flags)
        
        // Update all buttons.
        let tileButtons = Array(gameboardView.tileButtons.joined())
        for i in board.tiles.indices {
            
            // Find the button based on identifier.
            let tile = board.tiles[i]
            let matchedTileOutletIndex = tileButtons.firstIndex(where: { ($0!.identifier == tile.identifier )})!
            let tileButton = tileButtons[matchedTileOutletIndex]

            // Change physical attributes of the button.
            tileButton!.layer.borderWidth = 0.5
            tileButton!.layer.borderColor = UIColor.black.cgColor
            
            if tile.current_exposure == .Hidden {
                tileButton!.backgroundColor = UIColor.init(hex: "#89CFF0")
                tileButton!.setTitle("", for: UIControl.State.normal)
            } else if tile.current_exposure == .Flagged {
                tileButton!.backgroundColor = UIColor.init(hex: "#CA929E")
                tileButton!.setTitle("🚩", for: UIControl.State.normal)
            } else { // tile.exposure == .Exposed
                tileButton!.backgroundColor = UIColor.init(hex: "#053952")
                if (tile.content == .Mined) {
                    tileButton!.setTitle("💣", for: UIControl.State.normal)
                } else if tile.neighborTouches > 0 {
                    tileButton!.setTitle(String(tile.neighborTouches), for: UIControl.State.normal)
                } else { // tile is empty and has no neighboring mines
                    tileButton!.setTitle("", for: UIControl.State.normal)
                }
            }
        }
    }

    private func resetClock() {
        clockAccum = 0
        clockLabelOutlet.text = "00:00"
    }
    
    private func stopClock() {
        clockStopped = true
        timer?.invalidate()
    }
    
    private func startClock() {
        if clockStopped {
            clockStopped = false
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        }
    }
    
    private let clockMax = 99 * 60 + 59

    @objc private func timerHandler() {
        if clockAccum < clockMax {
            clockAccum += 1
            let remainderSeconds = clockAccum % 60
            let minutes = clockAccum / 60
            let clockString = String(format: "%02d:%02d", minutes, remainderSeconds)
            clockLabelOutlet.text = clockString
        }
        
        // ...The timer could do more, it's meant to be a general task thread.
        // For now, this function only updates the visible game clock.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameboardView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh controller's state and views before use.
        if SettingsService.shared.musicOn {
            SoundService.shared.startBackgroundMusic()
        }
        doubleTapGesture.isEnabled = SettingsService.shared.doubleTapZoom
        updateUndoButton()
        scene.isPaused = false
        if gameInPlay {
            startClock()
        }
    }
 
    private func updateUndoButton() {
        undoButtonOutlet.isEnabled = boardStack.items.isEmpty ? false : SettingsService.shared.undoEnabled
        undoButtonOutlet.alpha = undoButtonOutlet.isEnabled ? 1.0 : 0.3
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Turn-off services not needed while we're off screen.
        SoundService.shared.stopBackgroundMusic()
        scene.isPaused = true
        if gameInPlay {
            stopClock()
        }
    }
    
    // Taps on each gameboard tile are monitored for 3 cases: exposure, flag planting, and zooming.
    // The doubletap gesture toggles the min/max zoom of the board and can be disabled or enabled by the user via app settings.
    // The longpress gesture plants or removes flags from tiles.
    // Single tap gestures expose hidden tiles or plant flags depending on the mode.
    var doubleTapGesture: ShortTapGestureRecognizer!
    
    func addSingleTapAndLongPressGestureRecognizers() {
        let tileButtons = Array(gameboardView.tileButtons.joined())
        for tileButton in tileButtons {
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler))
            singleTapGesture.numberOfTapsRequired = 1
            singleTapGesture.require(toFail: doubleTapGesture)
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
            tileButton?.addGestureRecognizer(singleTapGesture)
            tileButton?.addGestureRecognizer(longPressGesture)
        }
    }
    
    func addDoubleTapGestureRecognizer() {
        doubleTapGesture = ShortTapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.isEnabled = SettingsService.shared.doubleTapZoom
        cScrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func doubleTapHandler(gesture: UITapGestureRecognizer) {
        if (cScrollView.zoomScale > cScrollView.minimumZoomScale) {
            cScrollView.setZoomScale(cScrollView.minimumZoomScale, animated: true)
            SoundService.shared.playSound(of: .ModeToggle)
        } else {
            cScrollView.setZoomScale(cScrollView.maximumZoomScale, animated: true)
            SoundService.shared.playSound(of: .ModeToggle)
        }
    }
    
    @objc func longPressHandler(gesture: UILongPressGestureRecognizer!) {
        if gesture.state == .began {
            if board.state != .Lost && board.state != .Won {
                if let tileButton = gesture.view as? TileButton {
                    let tile = board.tile(tileButton.identifier)

                    // Game is in-play below this point.
                    if tile.current_exposure == .Hidden || tile.current_exposure == .Flagged {
                        
                        // Record state before move.
                        boardStack.push(board)
                        
                        // Execute move, manage clock, update views, and play sound.
                        board.toggleFlag(tileButton.identifier)
                        if board.state == .Lost || board.state == .Won {
                            stopClock()
                            gameInPlay = false
                        } else {
                            startClock()
                            gameInPlay = true
                        }
                        updateViews()
                        SoundService.shared.playSound(of: .ModeToggle)
                    }
                }
            }
        }
    }
    
    @objc func singleTapHandler(gesture: UITapGestureRecognizer!) {
        if board.state != .Lost && board.state != .Won {
            if let tileButton = gesture.view as? TileButton {
                let tile = board.tile(tileButton.identifier)
                
                // Game is in-play below this point.
                if tile.current_exposure == .Hidden || tile.current_exposure == .Flagged {
                    
                    // Record state before move.
                    boardStack.push(board)
                    
                    // Execute move, manage clock, update views, and play sound.
                    if mode == "🚩" {
                        board.toggleFlag(tileButton.identifier)
                    } else {
                        board.exposeTile(tileButton.identifier)
                    }
                    if board.state == .Lost || board.state == .Won {
                        stopClock()
                        gameInPlay = false
                    } else {
                        startClock()
                        gameInPlay = true
                    }
                    updateViews()
                    SoundService.shared.playSound(of: .ModeToggle)
                }
            }
        }
    }
}

