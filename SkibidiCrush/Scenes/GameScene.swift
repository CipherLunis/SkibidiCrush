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
    
    var pointsLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
    
    var xOffset = 0.0
    var yOffset = 0.0
    var squareWidth = 0.0
    var squareHeight = 0.0
    var skibidiToiletWidth = 0.0
    var skibidiToiletHeight = 0.0
    
    @Published var isGameOver = false
    @Published var points = 0
    
    private let soundQueue = DispatchQueue(label: "com.cipherlunis.skibidicrush.soundqueue")
    
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
        
        xOffset = frame.width/8
        yOffset = frame.height/4
        squareWidth = frame.width/8
        squareHeight = frame.width/6
        skibidiToiletWidth = frame.width/8
        skibidiToiletHeight = frame.height/13.3
        
        createPointsBG()
        createPointsLabel()
        
        addSkibidiToilets()
        var isValidBoard = checkForValidBoardState()
        // keep regenerating board at the start of the game if it is unsolvable
        while !isValidBoard {
            for row in 0..<skibidiToilets.count {
                for column in 0..<skibidiToilets[row].count {
                    skibidiToilets[row][column]!.node.removeFromParent()
                }
            }
            skibidiToilets = [[SkibidiToilet?]](repeating: [SkibidiToilet?](repeating: nil, count: 7), count: 7)
            addSkibidiToilets()
            isValidBoard = checkForValidBoardState()
        }
        evaluateBoardForMatches()
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
        pointsLabel.fontSize = 40
        pointsLabel.fontColor = .black
        pointsLabel.zPosition = 5
        addChild(pointsLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                guard let targetNode = atPoint(touchLocation) as? SKSpriteNode else { return }
                for row in 0..<skibidiToilets.count {
                    for column in 0..<skibidiToilets[row].count {
                        if targetNode == skibidiToilets[row][column]!.node {
                            // swap two toilets
                            if firstToiletTapped == nil {
                                skibidiToilets[row][column]!.node.drawBorder(color: .green, width: 1.0)
                                firstToiletTapped = skibidiToilets[row][column]!
                            } else if secondToiletTapped == nil {
                                secondToiletTapped = skibidiToilets[row][column]!
                                if abs(secondToiletTapped!.row-firstToiletTapped!.row) <= 1 && abs(secondToiletTapped!.column-firstToiletTapped!.column) <= 1 {
                                    skibidiToilets[row][column]!.node.drawBorder(color: .green, width: 1.0)
                                    let moveFirstToiletAction = SKAction.move(to: CGPoint(x: secondToiletTapped!.node.position.x, y: secondToiletTapped!.node.position.y), duration: 0.3)
                                    let moveSecondToiletAction = SKAction.move(to: CGPoint(x: firstToiletTapped!.node.position.x, y: firstToiletTapped!.node.position.y), duration: 0.3)
                                    
                                    skibidiToilets[firstToiletTapped!.row][firstToiletTapped!.column]! = secondToiletTapped!
                                    skibidiToilets[firstToiletTapped!.row][firstToiletTapped!.column]!.row = firstToiletTapped!.row
                                    skibidiToilets[firstToiletTapped!.row][firstToiletTapped!.column]!.column = firstToiletTapped!.column
                                    
                                    skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]! = firstToiletTapped!
                                    skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]!.row = secondToiletTapped!.row
                                    skibidiToilets[secondToiletTapped!.row][secondToiletTapped!.column]!.column = secondToiletTapped!.column
                                    firstToiletTapped!.node.run(moveFirstToiletAction, completion: {
                                        self.skibidiToilets[self.firstToiletTapped!.row][self.firstToiletTapped!.column]!.node.removeBorder()
                                        self.firstToiletTapped = nil
                                    })
                                    secondToiletTapped!.node.run(moveSecondToiletAction, completion: {
                                        self.skibidiToilets[self.secondToiletTapped!.row][self.secondToiletTapped!.column]!.node.removeBorder()
                                        self.secondToiletTapped = nil
                                        self.evaluateBoardForMatches()
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
    }
    
    private func addSkibidiToilets() {
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
            }
        }
    }
    
    private func evaluateBoardForMatches() {
        var foundMatch = false
        
        for row in 0..<skibidiToilets.count {
            for column in 0..<skibidiToilets[row].count {
                let currSkibidiToilet = skibidiToilets[row][column]!
                // o o o
                // x x x
                // o o o
                if column > 0 &&
                    column < skibidiToilets[row].count-1 &&
                    skibidiToilets[row][column-1]!.colorImageName == currSkibidiToilet.colorImageName &&
                    skibidiToilets[row][column+1]!.colorImageName == currSkibidiToilet.colorImageName {
                    if !skibidiToilets[row][column]!.isMatched {
                        points += 10
                        foundMatch = true
                    }
                    skibidiToilets[row][column-1]!.isMatched = true
                    skibidiToilets[row][column]!.isMatched = true
                    skibidiToilets[row][column+1]!.isMatched = true
                    soundQueue.async {
                        SoundManager.sharedInstance.playSound(fileName: "Skibidi")
                    }
                }
                
                // o x o
                // o x o
                // o x o
                if row > 0 &&
                    row < skibidiToilets.count-1 &&
                    skibidiToilets[row-1][column]!.colorImageName == currSkibidiToilet.colorImageName &&
                    skibidiToilets[row+1][column]!.colorImageName == currSkibidiToilet.colorImageName {
                    if !skibidiToilets[row][column]!.isMatched {
                        points += 10
                        foundMatch = true
                    }
                    skibidiToilets[row-1][column]!.isMatched = true
                    skibidiToilets[row][column]!.isMatched = true
                    skibidiToilets[row+1][column]!.isMatched = true
                    soundQueue.async {
                        SoundManager.sharedInstance.playSound(fileName: "Skibidi")
                    }
                }
            }
            
            pointsLabel.text = "\(points)"
        }
            
        // Remove toilets from screen when they're matched
        for row in 0..<skibidiToilets.count {
            for column in 0..<skibidiToilets[row].count {
                if skibidiToilets[row][column]!.isMatched && !skibidiToilets[row][column]!.didRemoveMatchedToilet {
                    skibidiToilets[row][column]!.didRemoveMatchedToilet = true
                    skibidiToilets[row][column]!.isMatched = false
                    let growAction = SKAction.scale(to: 1.2, duration: 0.1)
                    let shrinkAction = SKAction.scale(to: 0.0, duration: 0.3)
                    let removeAction = SKAction.removeFromParent()
                    var removeParticleColor = "RemoveParticlePink"
                    switch(skibidiToilets[row][column]!.colorImageName) {
                    case "SkibidiOrange":
                        removeParticleColor = "RemoveParticleOrange"
                    case "SkibidiBlue":
                        removeParticleColor = "RemoveParticleBlue"
                    case "SkibidiRed":
                        removeParticleColor = "RemoveParticleRed"
                    case "SkibidiYellow":
                        removeParticleColor = "RemoveParticleYellow"
                    case "SkibidiGreen":
                        removeParticleColor = "RemoveParticleGreen"
                    default:
                        break
                    }
                    let removeParticles = SKEmitterNode(fileNamed: "\(removeParticleColor).sks")!
                    removeParticles.position = skibidiToilets[row][column]!.node.position
                    removeParticles.zPosition = 4
                    addChild(removeParticles)
                    skibidiToilets[row][column]!.node.run(SKAction.sequence([growAction, shrinkAction, removeAction])) {
                        removeParticles.removeFromParent()
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
                        skibidiToilet.node.position = CGPoint(x: self.xOffset + self.squareWidth*CGFloat(column), y: self.yOffset + self.squareHeight*CGFloat(6-row))
                        skibidiToilet.node.size = CGSize(width: self.skibidiToiletWidth, height: self.skibidiToiletHeight)
                        self.addChild(skibidiToilet.node)
                        self.skibidiToilets[row][column] = skibidiToilet
                        var isReadyToCheckForValidBoardState = true
                        for row in 0..<self.skibidiToilets.count {
                            for column in 0..<self.skibidiToilets[row].count {
                                if self.skibidiToilets[row][column]!.didRemoveMatchedToilet {
                                    isReadyToCheckForValidBoardState = false
                                }
                            }
                        }
                        var isBoardValid = self.checkForValidBoardState()
                        if isReadyToCheckForValidBoardState && foundMatch && isBoardValid {
                            self.evaluateBoardForMatches()
                        } else if !isBoardValid {
                            self.isGameOver = true
                        }
                    }
                }
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
                    return true
                }
            }
        }
        return false
    }
}
