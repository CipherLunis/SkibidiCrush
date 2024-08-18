//
//  GameView.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/20/24.
//

import Foundation
import SpriteKit
import SwiftUI

struct GameView: View {
    
    @ObservedObject var game: GameScene
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                SpriteView(scene: game)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Image("SkibidiToilet")
                            .resizable()
                            .frame(width: geo.size.height/11, height: geo.size.height/9)
                            .padding(.leading, 15)
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Spacer()
                        HighlightableButton(backgroundImageURL: "HomeButton", backgroundImageSize: CGSize(width: geo.size.height/11, height: geo.size.height/11), action: {
                            // go to start view
                        })
                        .frame(width: geo.size.height/11, height: geo.size.height/11)
                        .padding(.trailing, 15)
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    Image("CandyRectangle")
                        .resizable()
                        .clipShape(Capsule())
                        .frame(width: geo.size.width/1.2, height: geo.size.height/14)
                }
                // shadow opacity
               Rectangle()
                   .fill(.black)
                   .ignoresSafeArea()
                   .frame(width: geo.size.width, height: geo.size.height)
                   .opacity(game.isGameOver ? 0.5 : 0.0)
               GameOverView(points: game.points)
                   .offset(y: game.isGameOver ? 0.0 : geo.size.height)
                   .animation(.interpolatingSpring(mass: 0.01, stiffness: 1, damping: 0.5, initialVelocity: 5.0), value: game.isGameOver)
            }
        }
    }
}

#Preview {
    GameView(game: GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
}
