//
//  CloudLayerSKView.swift
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

import SpriteKit

class CloudLayerSKScene: SKScene {
    
    public override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        createClouds()
    }
    
    // Less a kludge and more a placeholder for future cloud layer functionality.
    func createClouds() {
        
        let image = UIImage(named: "clouds")!
        let flipped10 = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImage.Orientation.upMirrored)
        let flipped01 = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImage.Orientation.downMirrored)
        let flipped11 = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImage.Orientation.down)

        let compositeSize = CGSize(width: image.size.width * 2, height: image.size.height * 2)
        let renderer = UIGraphicsImageRenderer(size: compositeSize)
        let renderedImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
            flipped10.draw(in: CGRect(origin: CGPoint(x: image.size.width, y: 0), size: image.size))
            flipped01.draw(in: CGRect(origin: CGPoint(x: 0, y: image.size.height), size: image.size))
            flipped11.draw(in: CGRect(origin: CGPoint(x: image.size.width, y: image.size.height), size: image.size))
        }
        let texture = SKTexture(image: renderedImage)
        
        // Texture is a PNG of rendered clouds from Photoshop.
//        let texture = SKTexture(imageNamed: "clouds")
        let timeUnit = 40.0
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: texture)

            // First image starts on-screen, the second off-screen. Second image is a mirror of first.
            background.position = CGPoint(x: background.size.width * CGFloat(i) + background.size.width/2, y: background.size.height/2)
            background.xScale = i % 2 == 0 ? 1 : -1;
            background.zPosition = -30
            
            addChild(background)

            let moveLeftOnce = SKAction.moveBy(x: -background.size.width * CGFloat(i) - background.size.width, y: 0.0, duration: timeUnit + timeUnit * Double(i))
            let moveReset = SKAction.move(to: CGPoint(x: background.size.width + background.size.width/2.0, y: background.size.height/2), duration: 0.0)
            let moveLeft = SKAction.moveBy(x: -background.size.width * 2.0, y: 0.0, duration: timeUnit * 2.0)
            let moveLoop = SKAction.repeatForever(SKAction.sequence([moveReset, moveLeft]))
            let moveForever = SKAction.sequence([moveLeftOnce, moveLoop])

            background.run(moveForever)
        }
    }
}
