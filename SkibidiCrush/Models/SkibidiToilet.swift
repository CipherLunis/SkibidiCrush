//
//  SkibidiToilet.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import Foundation
import SpriteKit

class SkibidiToilet {
    var node = SKSpriteNode()
    var row = 0
    var column = 0
    var arrayRow = 0
    var arrayColumn = 0
    var colorImageName = ""
    
    init(imageName: String) {
        self.colorImageName = imageName
        node.texture = SKTexture(imageNamed: imageName)
    }
}
