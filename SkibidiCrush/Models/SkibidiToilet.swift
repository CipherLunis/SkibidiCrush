//
//  SkibidiToilet.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import Foundation
import SpriteKit

struct SkibidiToilet {
    var node = SKSpriteNode()
    var row = 0
    var column = 0
    var isMatched = false
    var didRemoveMatchedToilet = false
    var colorImageName = ""
    
    init(imageName: String, row: Int, column: Int) {
        self.colorImageName = imageName
        self.row = row
        self.column = column
        node.texture = SKTexture(imageNamed: imageName)
    }
}
