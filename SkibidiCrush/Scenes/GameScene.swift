//
//  GameScene.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene, ObservableObject {
    
    var skibidiToilets = [[SkibidiToilet?]](repeating: [SkibidiToilet?](repeating: nil, count: 7), count: 7)
    var firstToiletTapped: SkibidiToilet?
    var secondToiletTapped: SkibidiToilet?
    
    override init(size: CGSize) {
        super.init(size: size)
        self.size = size
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        scene?.scaleMode = .fill
        anchorPoint = .zero
        
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "GameBG"))
        background.anchorPoint = .zero
        background.position = .zero
        background.size = view.frame.size
        addChild(background)
        
        addSkibidiToilets()
        var isValidBoard = checkForValidBoardState()
        while !isValidBoard {
            print("Regenerated board")
            addSkibidiToilets()
            isValidBoard = checkForValidBoardState()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            guard let targetNode = atPoint(touchLocation) as? SKSpriteNode else { return }
            for row in 0..<skibidiToilets.count {
                for column in 0..<skibidiToilets[row].count {
                    if targetNode == skibidiToilets[row][column]!.node {
                        print("Skibidi toilet \(skibidiToilets[row][column]!.row), \(skibidiToilets[row][column]!.column)")
                        //skibidiToilets[row][column]!.node.drawBorder(color: .green, width: 10.0)
                        // swap two toilets
                        if firstToiletTapped == nil {
                            firstToiletTapped = skibidiToilets[row][column]
                        } else if secondToiletTapped == nil {
                            print("\(abs(skibidiToilets[row][column]!.row-firstToiletTapped!.row))")
                            print("\(abs(skibidiToilets[row][column]!.column-firstToiletTapped!.column))")
                            if abs(skibidiToilets[row][column]!.row-firstToiletTapped!.row) <= 1 && abs(skibidiToilets[row][column]!.column-firstToiletTapped!.column) <= 1 {
                                secondToiletTapped = skibidiToilets[row][column]
                                // play animation
                                // animation complete --> set below nodes to nil
                                let moveFirstToiletAction = SKAction.move(to: CGPoint(x: secondToiletTapped!.node.position.x, y: secondToiletTapped!.node.position.y), duration: 0.3)
                                let moveSecondToiletAction = SKAction.move(to: CGPoint(x: firstToiletTapped!.node.position.x, y: firstToiletTapped!.node.position.y), duration: 0.3)
                                let firstToiletRow = firstToiletTapped!.row
                                let firstToiletColumn = firstToiletTapped!.column
                                skibidiToilets[firstToiletTapped!.arrayRow][firstToiletTapped!.arrayColumn]!.row = secondToiletTapped!.row
                                skibidiToilets[firstToiletTapped!.arrayRow][firstToiletTapped!.arrayColumn]!.column = secondToiletTapped!.column
                                skibidiToilets[secondToiletTapped!.arrayRow][secondToiletTapped!.arrayColumn]!.row = firstToiletRow
                                skibidiToilets[secondToiletTapped!.arrayRow][secondToiletTapped!.arrayColumn]!.column = firstToiletColumn
                                firstToiletTapped!.node.run(moveFirstToiletAction)
                                secondToiletTapped!.node.run(moveSecondToiletAction, completion: {
                                    self.firstToiletTapped = nil
                                    self.secondToiletTapped = nil
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addSkibidiToilets() {
        let xOffset = frame.width/8
        let yOffset = frame.height/4
        let squareWidth = frame.width/8
        let squareHeight = frame.width/6
        let skibidiToiletWidth = frame.width/8
        let skibidiToiletHeight = frame.height/13.3
        for row in 0..<7 {
            for column in 0..<7 {
                let colorOfToilet = Int.random(in: 0...5)
                var skibidiToiletImageName = "SkibidiPurple"
                switch colorOfToilet {
                case 0:
                    skibidiToiletImageName = "SkibidiRed"
                case 1:
                    skibidiToiletImageName = "SkibidiBlue"
                case 2:
                    skibidiToiletImageName = "SkibidiYellow"
                case 3:
                    skibidiToiletImageName = "SkibidiOrange"
                case 4:
                    skibidiToiletImageName = "SkibidiGreen"
                default:
                    break
                }
                let skibidiToilet = SkibidiToilet(imageName: skibidiToiletImageName)
                skibidiToilet.node.position = CGPoint(x: xOffset + squareWidth*CGFloat(row), y: yOffset + squareHeight*CGFloat(column))
                skibidiToilet.node.size = CGSize(width: skibidiToiletWidth, height: skibidiToiletHeight)
                skibidiToilet.row = 7-column
                skibidiToilet.column = row+1
                skibidiToilet.arrayRow = row
                skibidiToilet.arrayColumn = column
                addChild(skibidiToilet.node)
                skibidiToilets[column][row] = skibidiToilet
                print("color: \(skibidiToiletImageName), row: \(skibidiToilet.row), column: \(skibidiToilet.column)")
            }
        }
    }
    
    // Checks if a move can be made to match 3 in a row
    private func checkForValidBoardState() -> Bool {
        for row in 0..<skibidiToilets.count {
            for column in 0..<skibidiToilets[row].count {
                let skibidiToilet = skibidiToilets[row][column]
                // scenario checking middle toilet
                // o o o
                // o x o
                // x o x
                if row > 0 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row+1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+1][column+1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 1, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // x o o
                // o x o
                // x o o
                if row > 0 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row-1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+1][column-1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 2, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o x
                // o x o
                // o o x
                if row > 0 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row-1][column+1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+1][column+1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 3, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // x o x
                // o x o
                // o o o
                if row > 0 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row-1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row-1][column+1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 4, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // scenario checking outer toilet
                // o o o o o
                // o o o x x
                // o o x o o
                // o o o o o
                // o o o o o
                if row > 0 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-2 &&
                    skibidiToilets[row+1][column+1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+1][column+2]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 5, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o o o o
                // o o o o o
                // o o x o o
                // o o o x x
                // o o o o o
                if row > 0 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-2 &&
                    skibidiToilets[row-1][column+1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row-1][column+2]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 6, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o o o o
                // x x o o o
                // o o x o o
                // o o o o o
                // o o o o o
                if row > 0 &&
                    column > 1 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row+1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+1][column-2]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 7, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o o o o
                // o o o o o
                // o o x o o
                // x x o o o
                // o o o o o
                if row > 0 &&
                    column > 1 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row-1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row-1][column-2]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 8, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o x o o o
                // o x o o o
                // o o x o o
                // o o o o o
                // o o o o o
                if row > 1 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row-1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row-2][column-1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 9, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o o x o
                // o o o x o
                // o o x o o
                // o o o o o
                // o o o o o
                if row > 1 &&
                    column > 0 &&
                    row < skibidiToilets.count-1 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row-1][column+1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row-2][column+1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 10, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o o o o
                // o o o o o
                // o o x o o
                // o o o x o
                // o o o x o
                if row > 0 &&
                    column > 1 &&
                    row < skibidiToilets.count-2 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row+1][column+1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+2][column+1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 11, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
                // o o o o o
                // o o o o o
                // o o x o o
                // o x o o o
                // o x o o o
                if row > 0 &&
                    column > 1 &&
                    row < skibidiToilets.count-2 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row+1][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+2][column-1]!.colorImageName == skibidiToilet!.colorImageName {
                    print("case 12, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
            }
        }
        return false
    }
}
