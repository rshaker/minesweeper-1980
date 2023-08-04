//
//  SettingsService.swift
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

// This class controls the at-rest state of the application.
class SettingsService {
    static let shared = SettingsService()
    
    static let resetSettingsIdentifier = "reset"
    
    static let COLS_MIN = 8
    static let COLS_MAX = 30
    static let ROWS_MIN = 8
    static let ROWS_MAX = 30
    static let MINES_MIN = 1
    static let MINES_MAX = COLS_MAX * ROWS_MAX - 1
    
    static let beginnerIdentifier = "beginner"
    static let intermediateIdentifier = "intermediate"
    static let advancedIdentifier = "advanced"
    static let customIdentifier = "custom"
    
    struct Options {
        var level: String
        var rows: Int
        var cols: Int
        var mines: Int
    }

    static let CUSTOM_LEVEL = levels.count - 1

    static var levels: [Options] = [
        Options(level: beginnerIdentifier, rows: 8, cols: 8, mines: 10),
        Options(level: intermediateIdentifier, rows: 16, cols: 16, mines: 40),
        Options(level: advancedIdentifier, rows: 24, cols: 16, mines: 80),
        // This is just a default set of values that won't trigger auto-level selection immediately in the UI.
        Options(level: customIdentifier, rows: ROWS_MAX, cols: COLS_MAX, mines: MINES_MAX),
    ]
    
    static let rowsIdentifier = "rows"
    static let colsIdentifier = "cols"
    static let minesIdentifier = "mines"
    static let levelIdentifier = "level"
    static let soundOnIdentifier = "soundOn"
    static let musicOnIdentifier = "musicOn"
    static let safeFirstIdentifier = "safeFirst"
    static let undoEnabledIdentifier = "undoEnabled"
    static let doubleTapZoomIdentifier = "doubleTapZoom"

    // Default to beginner level.
    static let rowsDefault = levels[0].rows
    static let colsDefault = levels[0].cols
    static let minesDefault = levels[0].mines
    static let levelDefault = levels[0].level
    
    // Default to most features enabled.
    static let soundOnDefault = true
    static let musicOnDefault = true
    static let safeFirstDefault = true
    static let undoEnabledDefault = true
    static let doubleTapZoomDefault = false

    var rows: Int! {
        didSet {
            UserDefaults.standard.set(rows, forKey: SettingsService.rowsIdentifier)
        }
    }
    var cols: Int! {
        didSet {
            UserDefaults.standard.set(cols, forKey: SettingsService.colsIdentifier)
        }
    }
    var mines: Int! {
        didSet {
            UserDefaults.standard.set(mines, forKey: SettingsService.minesIdentifier)
        }
    }
    var level: String! {
        didSet {
            UserDefaults.standard.set(level, forKey: SettingsService.levelIdentifier)
        }
    }
    var soundOn: Bool! {
        didSet {
            UserDefaults.standard.set(soundOn, forKey: SettingsService.soundOnIdentifier)
        }
    }
    var musicOn: Bool! {
        didSet {
            UserDefaults.standard.set(musicOn, forKey: SettingsService.musicOnIdentifier)
        }
    }
    var safeFirst: Bool! {
        didSet {
            UserDefaults.standard.set(safeFirst, forKey: SettingsService.safeFirstIdentifier)
        }
    }
    var undoEnabled: Bool! {
        didSet {
            UserDefaults.standard.set(undoEnabled, forKey: SettingsService.undoEnabledIdentifier)
        }
    }
    var doubleTapZoom: Bool! {
        didSet {
            UserDefaults.standard.set(doubleTapZoom, forKey: SettingsService.doubleTapZoomIdentifier)
        }
    }

    private init() {
        conditionallyResetSettings()
        registerAppSettings()
        registerSettingsBundle()
        loadAppSettings()
    }
    
    // Checks system settings to see if user has requested a reset of app settings to installation defaults.
    // This function should be called once at singleton instantiation.
    private func conditionallyResetSettings() {
        guard let settingsReset = UserDefaults.standard.string(forKey: SettingsService.resetSettingsIdentifier) else {
            return
        }
        if settingsReset == "1" {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            // "Waits for any pending asynchronous updates to the defaults database and returns; this method is unnecessary and shouldn't be used."
            //UserDefaults.standard.synchronize()
        }
    }
    
    // Registers a default value for any app setting that does not already exist (or is nil) in UserDefaults.
    private func registerAppSettings() {
        if UserDefaults.standard.object(forKey: SettingsService.rowsIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.rowsDefault, forKey: SettingsService.rowsIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.colsIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.colsDefault, forKey: SettingsService.colsIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.minesIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.minesDefault, forKey: SettingsService.minesIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.levelIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.levelDefault, forKey: SettingsService.levelIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.soundOnIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.soundOnDefault, forKey: SettingsService.soundOnIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.musicOnIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.musicOnDefault, forKey: SettingsService.musicOnIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.safeFirstIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.safeFirstDefault, forKey: SettingsService.safeFirstIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.undoEnabledIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.undoEnabledDefault, forKey: SettingsService.undoEnabledIdentifier)
        }
        if UserDefaults.standard.object(forKey: SettingsService.doubleTapZoomIdentifier) == nil {
           UserDefaults.standard.set(SettingsService.doubleTapZoomDefault, forKey: SettingsService.doubleTapZoomIdentifier)
        }
    }
    
    private func registerSettingsBundle() {
        // Determine path to Root.plist of settings bundle.
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") else {
            return
        }
        guard let settings = NSDictionary(contentsOfFile: settingsBundle+"/Root.plist") else {
            return
        }
        
        // Read all default values from plist dictionary.
        let preferences = settings["PreferenceSpecifiers"] as! NSArray
        var defaultsToRegister = [String: AnyObject]()
        for preference in preferences {
            if let defaultKeyValue = preference as? [String: AnyObject] {
                guard let key = defaultKeyValue["Key"] as? String,
                    let value = defaultKeyValue["DefaultValue"] else {
                        continue
                }
                defaultsToRegister[key] = value
            }
        }
        
        // Write all un-set defaults from bundle plist to persistent UserDefaults object.
        for (key, value) in defaultsToRegister {
            if UserDefaults.standard.object(forKey: key) == nil {
                UserDefaults.standard.set(value, forKey: key)
            }
        }
    }
    
    private func loadAppSettings() {
        // TODO: throw exception if stored values violate the settings model's state rules
        rows = UserDefaults.standard.integer(forKey: SettingsService.rowsIdentifier)
        cols = UserDefaults.standard.integer(forKey: SettingsService.colsIdentifier)
        mines = UserDefaults.standard.integer(forKey: SettingsService.minesIdentifier)
        level = UserDefaults.standard.string(forKey: SettingsService.levelIdentifier)
        musicOn = UserDefaults.standard.bool(forKey: SettingsService.musicOnIdentifier)
        soundOn = UserDefaults.standard.bool(forKey: SettingsService.soundOnIdentifier)
        safeFirst = UserDefaults.standard.bool(forKey: SettingsService.safeFirstIdentifier)
        undoEnabled = UserDefaults.standard.bool(forKey: SettingsService.undoEnabledIdentifier)
        doubleTapZoom = UserDefaults.standard.bool(forKey: SettingsService.doubleTapZoomIdentifier)
    }
    
//    class func dumpUserDefaults() {
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("key = \(key), value = \(value)")
//        }
//    }
}
