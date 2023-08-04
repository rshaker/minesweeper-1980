//
//  SoundService.swift
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

import AVFoundation

class SoundService {
    static let shared = SoundService()
    
    private static let bundlePath = "sounds"
    
    private var bgMusicPlayer: AVAudioPlayer?
    private var modeToggleSfxPlayer: AVAudioPlayer?
    private var gameRestartSfxPlayer: AVAudioPlayer?
    private var gameLoseSfxPlayer: AVAudioPlayer?
    private var gameWinSfxPlayer: AVAudioPlayer?
    private var moveUndoSfxPlayer: AVAudioPlayer?
    private var tileUncoverSfxPlayer: AVAudioPlayer?
    private var mineUncoverSfxPlayer: AVAudioPlayer?
    private var zoomInSfxPlayer: AVAudioPlayer?
    private var zoomOutSfxPlayer: AVAudioPlayer?
    
    enum SoundType {
        case ModeToggle
        case GameRestart
        case GameLose
        case GameWin
        case MoveUndo
        case TileUncover
        case MineUncover
        case ZoomIn
        case ZoomOut
    }

    private init() {
        loadSounds()
//        updateSoundOutputs()
    }
    
    func playSound(of: SoundType) {
        if SettingsService.shared.soundOn {
            switch of {
            case .GameLose,
                 .GameRestart,
                 .GameWin,
                 .MineUncover,
                 .ModeToggle,
                 .MoveUndo,
                 .TileUncover,
                 .ZoomIn,
                 .ZoomOut:
                playModeToggleSound()
            }
        }
    }
    
    private func loadSounds() {
        if self.bgMusicPlayer == nil, let bgMusicFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/bg_music", ofType: "mp3") {
            let bgMusicURL = URL(fileURLWithPath: bgMusicFilePath)
            do {
                var avPlayer = AVAudioPlayer()
                avPlayer = try AVAudioPlayer(contentsOf: bgMusicURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                // https://stackoverflow.com/questions/6804160/how-do-i-repeat-a-avaudioplayer
                // https://developer.apple.com/documentation/avfoundation/avaudioplayer/1386071-numberofloops
                avPlayer.numberOfLoops = -1
                avPlayer.volume = 0.0
                self.bgMusicPlayer = avPlayer
            } catch {
                print("\(error)")
                // no-op
            }
        }
        
        if self.modeToggleSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.modeToggleSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.gameRestartSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.gameRestartSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.gameLoseSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.gameLoseSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.gameWinSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.gameWinSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.moveUndoSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.moveUndoSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.tileUncoverSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.tileUncoverSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.mineUncoverSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.mineUncoverSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.zoomInSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.zoomInSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.zoomOutSfxPlayer == nil, let sfxFilePath = Bundle.main.path(forResource: SoundService.bundlePath + "/tap_sound", ofType: "mp3") {
            let sfxURL = URL(fileURLWithPath: sfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 1.0
                self.zoomOutSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
    }
    
    func startBackgroundMusic() {
        if bgMusicPlayer?.isPlaying == false {
            bgMusicPlayer?.play()
            bgMusicPlayer?.setVolume(1.0, fadeDuration: 0.3)
        }
    }
    
    func stopBackgroundMusic() {
        if bgMusicPlayer?.isPlaying == true {
            bgMusicPlayer?.setVolume(0, fadeDuration: 0.3)
            bgMusicPlayer?.pause()
        }
    }
    
    func playModeToggleSound() {
        guard let modeToggleSfxPlayer = self.modeToggleSfxPlayer else {
            return
        }
        modeToggleSfxPlayer.pause()
        modeToggleSfxPlayer.currentTime = 0
        modeToggleSfxPlayer.play()
    }
    
//
//    func updateSoundOutputs() {
//        if SettingsService.shared.musicOn {
//            if bgMusicPlayer?.isPlaying == false {
//                bgMusicPlayer?.play()
//                bgMusicPlayer?.setVolume(1.0, fadeDuration: 0.3)
//            }
//        } else {
//            if bgMusicPlayer?.isPlaying == true {
//                bgMusicPlayer?.setVolume(0, fadeDuration: 0.3)
//                bgMusicPlayer?.pause()
//            }
//        }
//    }
}
