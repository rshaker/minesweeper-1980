//
//  CenteringUIScrollView.swift
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

class CenteringUIScrollView: UIScrollView {

    override var bounds: CGRect {
        didSet {
            updateContentInset()
        }
    }

    override var contentSize: CGSize {
        didSet {
            updateContentInset()
        }
    }

    func updateContentInset() {
        if (contentSize.width > 0 && contentSize.height > 0 && bounds.width > 0 && bounds.height > 0) {
            var top = CGFloat(0)
            var left = CGFloat(0)
            if contentSize.width < bounds.width {
                left = (bounds.width - contentSize.width) / 2
            }
            if contentSize.height < bounds.height {
                top = (bounds.height - contentSize.height) / 2
            }
            contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        }
    }
}
