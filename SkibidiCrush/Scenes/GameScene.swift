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
    
    var pointsLabel = SKLabelNode()
    var points = 0
    
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
        
        createPointsBG()
        createPointsLabel()
        
        addSkibidiToilets()
        var isValidBoard = checkForValidBoardState()
        while !isValidBoard {
            print("Regenerated board")
            for row in 0..<skibidiToilets.count {
                for column in 0..<skibidiToilets[row].count {
                    skibidiToilets[row][column]!.node.removeFromParent()
                }
            }
            skibidiToilets = [[SkibidiToilet?]](repeating: [SkibidiToilet?](repeating: nil, count: 7), count: 7)
            addSkibidiToilets()
            isValidBoard = checkForValidBoardState()
        }
    }
    
    private func createPointsBG() {
        let pointsBG = SKSpriteNode(texture: SKTexture(imageNamed: "PointsArea"))
        pointsBG.position = CGPoint(x: frame.width/2, y: frame.height/8*7)
        pointsBG.size = CGSize(width: frame.size.width/2.5, height: frame.size.height/12)
        addChild(pointsBG)
    }
    
    private func createPointsLabel() {
        pointsLabel.text = "\(points)"
        pointsLabel.position = CGPoint(x: frame.width/2, y: frame.height/100*85.5)
        pointsLabel.fontSize = 50
        pointsLabel.fontColor = .black
        pointsLabel.zPosition = 5
        addChild(pointsLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            guard let targetNode = atPoint(touchLocation) as? SKSpriteNode else { return }
            for row in 0..<skibidiToilets.count {
                for column in 0..<skibidiToilets[row].count {
                    //print("Color inside touches began: \(row), \(column): \(skibidiToilets[row][column]!.colorImageName)")
                    if targetNode == skibidiToilets[row][column]!.node {
                        // swap two toilets
                        if firstToiletTapped == nil {
                            skibidiToilets[row][column]!.node.drawBorder(color: .green, width: 1.0)
                            //print("added border for first toilet at \(row), \(column), \(skibidiToilets[row][column]!.colorImageName)")
                            firstToiletTapped = skibidiToilets[row][column]!
                        } else if secondToiletTapped == nil {
                            secondToiletTapped = skibidiToilets[row][column]!
                            //print("first toilet tapped at top: \(firstToiletTapped!.row), \(firstToiletTapped!.column), \(firstToiletTapped!.colorImageName)")
                            //print("second toilet tapped at top: \(secondToiletTapped!.row), \(secondToiletTapped!.column), \(secondToiletTapped!.colorImageName)")
                            //print("row distance: \(abs(secondToiletTapped!.row-firstToiletTapped!.row)), column distance: \(abs(secondToiletTapped!.column-firstToiletTapped!.column))")
                            if abs(secondToiletTapped!.row-firstToiletTapped!.row) <= 1 && abs(secondToiletTapped!.column-firstToiletTapped!.column) <= 1 {
                                skibidiToilets[row][column]!.node.drawBorder(color: .green, width: 1.0)
                                //print("added border for second toilet at \(row), \(column), \(skibidiToilets[row][column]!.colorImageName)")
                                let moveFirstToiletAction = SKAction.move(to: CGPoint(x: secondToiletTapped!.node.position.x, y: secondToiletTapped!.node.position.y), duration: 0.3)
                                let moveSecondToiletAction = SKAction.move(to: CGPoint(x: firstToiletTapped!.node.position.x, y: firstToiletTapped!.node.position.y), duration: 0.3)
                                //print("first toilet before swap: \(firstToiletTapped!.row), \(firstToiletTapped!.column), \(firstToiletTapped!.colorImageName)")
                                //print("second toilet before swap: \(secondToiletTapped!.row), \(secondToiletTapped!.column), \(secondToiletTapped!.colorImageName)")
                                
                                skibidiToilets[firstToiletTapped!.row][firstToiletTapped!.column]! = secondToiletTapped!//skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]!
                                skibidiToilets[firstToiletTapped!.row][firstToiletTapped!.column]!.row = firstToiletTapped!.row
                                skibidiToilets[firstToiletTapped!.row][firstToiletTapped!.column]!.column = firstToiletTapped!.column
                                
                                skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]! = firstToiletTapped!
                                skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]!.row = secondToiletTapped!.row
                                skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]!.column = secondToiletTapped!.column
                                //print("firstToiletTapped: \(firstToiletTapped!.row), \(firstToiletTapped!.column), \(firstToiletTapped!.colorImageName)")
                                //print("secondToiletTapped: \(secondToiletTapped!.row), \(secondToiletTapped!.column), \(secondToiletTapped!.colorImageName)")
                                firstToiletTapped!.node.run(moveFirstToiletAction, completion: {
                                    self.skibidiToilets[self.firstToiletTapped!.row][self.firstToiletTapped!.column]!.node.removeBorder()
                                    //print("Removed border for first toilet at: \(self.firstToiletTapped!.row), \(self.firstToiletTapped!.column), \(self.firstToiletTapped!.colorImageName)")
                                    self.firstToiletTapped = nil
                                })
                                secondToiletTapped!.node.run(moveSecondToiletAction, completion: {
                                    self.skibidiToilets[self.secondToiletTapped!.row][self.secondToiletTapped!.column]!.node.removeBorder()
                                    //print("Removed border for second toilet at:  \(self.secondToiletTapped!.row), \(self.secondToiletTapped!.column), \(self.secondToiletTapped!.colorImageName)")
                                    self.secondToiletTapped = nil
                                    self.evaluateBoardForMatches()
                                    //print("after swap board:")
                                    //self.printBoard()
                                })
                            } else {
                                firstToiletTapped!.node.removeBorder()
                                secondToiletTapped!.node.removeBorder()
                                firstToiletTapped = nil
                                secondToiletTapped = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func printBoard() {
        for row in 0..<skibidiToilets.count {
            for column in 0..<skibidiToilets[row].count {
                print("\(skibidiToilets[row][column]!.colorImageName)")
            }
            print()
        }
        print("Finished printing")
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
                let skibidiToilet = SkibidiToilet(imageName: skibidiToiletImageName, row: row, column: column)
                skibidiToilet.node.position = CGPoint(x: xOffset + squareWidth*CGFloat(column), y: yOffset + squareHeight*CGFloat(6-row))
                skibidiToilet.node.size = CGSize(width: skibidiToiletWidth, height: skibidiToiletHeight)
                addChild(skibidiToilet.node)
                skibidiToilets[row][column] = skibidiToilet
                //print("add skibidi toilets \(skibidiToilet.colorImageName), \(row), \(column)")
            }
        }
    }
    
    private func evaluateBoardForMatches() {
        print("starting evaluation for matches")
        for row in 0..<skibidiToilets.count {
            for column in 0..<skibidiToilets[row].count {
                let skibidiToilet = skibidiToilets[row][column]
                // o o o
                // x x x
                // o o o
                if column > 0 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row][column-1]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row][column+1]!.colorImageName == skibidiToilet!.colorImageName {
                    print()
                    print("left toilet: \(skibidiToilets[row][column-1]!.colorImageName) row: \(skibidiToilets[row][column-1]!.row) column: \(skibidiToilets[row][column-1]!.column)")
                    print("right toilet: \(skibidiToilets[row][column+1]!.colorImageName) row: \(skibidiToilets[row][column+1]!.row) column: \(skibidiToilets[row][column+1]!.column)")
                    print("matched horizontally")
                }
                
                // o x o
                // o x o
                // o x o
                if row > 0 &&
                    row < skibidiToilets.count-1 &&
                    skibidiToilets[row-1][column]!.colorImageName == skibidiToilet!.colorImageName &&
                    skibidiToilets[row+1][column]!.colorImageName == skibidiToilet!.colorImageName {
                    print()
                    print("bottom toilet: \(skibidiToilets[row-1][column]!.colorImageName) row: \(skibidiToilets[row-1][column]!.row) column: \(skibidiToilets[row-1][column]!.column)")
                    print("top toilet: \(skibidiToilets[row+1][column]!.colorImageName) row: \(skibidiToilets[row+1][column]!.row) column: \(skibidiToilets[row+1][column]!.column)")
                    print("matched vertically")
                }
            }
        }
        print("finished evaluation for matches")
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
                    print("valid board case 1, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 2, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 3, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 4, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 5, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 6, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 7, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 8, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 9, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 10, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 11, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
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
                    print("valid board case 12, \(skibidiToilets[row][column]!.row),\(skibidiToilets[row][column]!.column), color: \(skibidiToilets[row][column]!.colorImageName)")
                    return true
                }
            }
        }
        return false
    }
}
