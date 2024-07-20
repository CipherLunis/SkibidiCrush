//
//  StartView.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import Foundation
import SwiftUI

struct StartView: View {
    
    var geo: GeometryProxy
    var playButtonAction: () -> Void
    
    var body: some View {
        Image("StartScreenBG")
            .resizable()
            .ignoresSafeArea()
        VStack {
            Spacer()
                .frame(height: geo.size.height/2.36)
            HStack {
                Spacer()
                    .frame(width: geo.size.width/3.6)
                HighlightableButton(backgroundImageURL: "PlayButton", backgroundImageSize: CGSize(width: geo.size.width/4.6, height: geo.size.height/11), action: {
                    playButtonAction()
                })
                .frame(width: geo.size.height/4.6, height: geo.size.height/11)
                Spacer()
            }
            Spacer()
        }
    }
}
