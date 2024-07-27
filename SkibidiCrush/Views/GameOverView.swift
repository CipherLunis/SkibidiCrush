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
            Image("SkibidiEndBG")
                .resizable()
                .frame(width: geo.size.width/1.5, height: geo.size.height/3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                        .frame(width: geo.size.width/4)
                    Text("Points: ")
                        .font(.system(size: 30.0))
                        .fontWeight(.semibold)
                    Text("\(points)")
                        .font(.system(size: 25.0))
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    GameOverView()
}
