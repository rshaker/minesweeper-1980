//
//  SettingsViewController.swift
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

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // TODO: Add link to system settings from app's help page
    // navigate to app's system settings page
//    func systemSettings(_ sender: UIButton) {
//        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//    }
    
    // Current implementation saves changes from outlets to UserDefaults plist by way of a singleton (settings).
    // Updates the view content after making changes to underlying data in model (SettingsService).

    let settings = SettingsService.shared
    
    @IBOutlet weak var rowsOutlet: UIPickerView!
    @IBOutlet weak var colsOutlet: UIPickerView!
    @IBOutlet weak var minesOutlet: UIPickerView!
    @IBOutlet weak var levelOutlet: UIPickerView!
    @IBOutlet weak var soundOnOutlet: UISwitch!
    @IBOutlet weak var musicOnOutlet: UISwitch!
    @IBOutlet weak var safeFirstOutlet: UISwitch!
    @IBOutlet weak var undoEnabledOutlet: UISwitch!
    @IBOutlet weak var doubleTapZoomOutlet: UISwitch!
    
    @IBAction func soundOn(_ sender: UISwitch) {
        settings.soundOn = sender.isOn
    }
    
    @IBAction func musicOn(_ sender: UISwitch) {
        settings.musicOn = sender.isOn
    }
    
    @IBAction func safeFirst(_ sender: UISwitch) {
        settings.safeFirst = sender.isOn
    }
    
    @IBAction func undoEnabled(_ sender: UISwitch) {
        settings.undoEnabled = sender.isOn
    }
        
    @IBAction func doubleTapZoom(_ sender: UISwitch) {
        settings.doubleTapZoom = sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerPickers()
        updateViews()
    }

    // Sets level picker when rows, cols or mines change. Conversely, sets rows, cols and mines
    // pickers when level changes.
    func registerPickers() {
        for outlet in [ levelOutlet, rowsOutlet, colsOutlet, minesOutlet ] {
            outlet!.dataSource = self
            outlet!.delegate = self
//            outlet!.backgroundColor = UIColor.black
        }
    }
    
    private func updateViews() {
        
        // We take the blanket approach of updating all picker selections regardless of change.
        rowsOutlet.selectRow(settings.rows - SettingsService.ROWS_MIN, inComponent: 0, animated: true)
        colsOutlet.selectRow(settings.cols - SettingsService.COLS_MIN, inComponent: 0, animated: true)
        minesOutlet.selectRow(settings.mines - SettingsService.MINES_MIN, inComponent: 0, animated: true)
        if let index = SettingsService.levels.firstIndex(where: { $0.level == settings.level }) {
            levelOutlet.selectRow(index, inComponent: 0, animated: true)
        }
        soundOnOutlet.setOn(settings.soundOn, animated: true)
        musicOnOutlet.setOn(settings.musicOn, animated: true)
        safeFirstOutlet.setOn(settings.safeFirst, animated: true)
        undoEnabledOutlet.setOn(settings.undoEnabled, animated: true)
        doubleTapZoomOutlet.setOn(settings.doubleTapZoom, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case rowsOutlet:
            return SettingsService.ROWS_MAX - SettingsService.ROWS_MIN + 1
        case colsOutlet:
            return SettingsService.COLS_MAX - SettingsService.COLS_MIN + 1
        case minesOutlet:
            return settings.rows * settings.cols - SettingsService.MINES_MIN
        case levelOutlet:
            return SettingsService.levels.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent col: Int) -> NSAttributedString? {
        
        switch pickerView {
        case rowsOutlet:
            return NSAttributedString(string: String(SettingsService.COLS_MIN + row), attributes: [NSAttributedString.Key : Any]())
        case colsOutlet:
            return NSAttributedString(string: String(SettingsService.COLS_MIN + row), attributes: [NSAttributedString.Key : Any]())
        case minesOutlet:
            return NSAttributedString(string: String(SettingsService.MINES_MIN + row), attributes: [NSAttributedString.Key : Any]())
        case levelOutlet:
            return NSAttributedString(string: SettingsService.levels[row].level, attributes: [NSAttributedString.Key : Any]())
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // Changes settings.level name depending on current values of rows, cols and mines.
        // If a preset level matching the current set of values is not located, level will be set to CUSTOM_LEVEL
        // and current values for settings.rows (.cols, .mines) will be saved to that CUSTOM_LEVEL.
        // CUSTOM_LEVEL is the only level that can be written to by this controller, all others are restricted access.
        func updateLevels() {
            if SettingsService.levels.firstIndex(where: {
                $0.rows == settings.rows
                    && $0.cols == settings.cols
                    && $0.mines == settings.mines
            }) == nil {
                settings.level = SettingsService.levels[SettingsService.CUSTOM_LEVEL].level
                SettingsService.levels[SettingsService.CUSTOM_LEVEL].rows = settings.rows
                SettingsService.levels[SettingsService.CUSTOM_LEVEL].cols = settings.cols
                SettingsService.levels[SettingsService.CUSTOM_LEVEL].mines = settings.mines
            }
        }
        
        switch pickerView {
        case rowsOutlet:
            settings.rows = SettingsService.ROWS_MIN + row
            if settings.mines > settings.rows * settings.cols - 1 {
                settings.mines = settings.rows * settings.cols - 1
            }
            minesOutlet.reloadAllComponents()
        case colsOutlet:
            settings.cols = SettingsService.COLS_MIN + row
            if settings.mines > settings.rows * settings.cols - 1 {
                settings.mines = settings.rows * settings.cols - 1
            }
            minesOutlet.reloadAllComponents()
        case minesOutlet:
            settings.mines = SettingsService.MINES_MIN + row
        case levelOutlet:
            // We trust level properties to be valid
            settings.level = SettingsService.levels[row].level
            settings.rows = SettingsService.levels[row].rows
            settings.cols = SettingsService.levels[row].cols
            settings.mines = SettingsService.levels[row].mines
        default:
            () // noop
        }
        updateLevels()

        updateViews()
    }
}
