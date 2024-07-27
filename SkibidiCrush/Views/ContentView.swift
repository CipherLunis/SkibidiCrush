//
//  ContentView.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    
    @StateObject private var game = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    @State var showStartView = true
    @State var showGameView = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                if showStartView {
                    StartView(geo: geo, playButtonAction: {
                        showStartView = false
                        showGameView = true
                    })
                } else if showGameView {
                    GameView(game: game)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
