//
//  GameOverView.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/26/24.
//

import SwiftUI

struct GameOverView: View {
    
    @State var points = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    Spacer()
                    Text("Game Over!")
                        .font(.system(size: 50.0))
                        .fontWeight(.semibold)
                        .foregroundStyle(.pink)
                    Image("SkibidiEndBG")
                        .resizable()
                        .frame(width: geo.size.width/1.7, height: geo.size.height/5)
                    Spacer()
                }
                VStack {
                    Spacer()
                        .frame(height: geo.size.height/1.85)
                    HStack {
                        Text("Points: ")
                            .font(.system(size: 30.0))
                            .fontWeight(.semibold)
                        Text("\(points)")
                            .font(.system(size: 25.0))
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    GameOverView()
}
