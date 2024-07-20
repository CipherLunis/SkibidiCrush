//
//  HighlightableButton.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import UIKit
import SwiftUI

struct HighlightableButton: UIViewRepresentable {
   
    private var backgroundImageURL: String
    private var foregroundImageURL: String?
    private var foregroundImageSize: CGSize?
    private var backgroundImageSize: CGSize
    private var buttonTitle: String?
    private var isEnabled: Bool
    private var action: () -> Void
   
    init(backgroundImageURL: String, foregroundImageURL: String? = nil, foregroundImageSize: CGSize? = nil, backgroundImageSize: CGSize, buttonTitle: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.backgroundImageURL = backgroundImageURL
        self.foregroundImageURL = foregroundImageURL
        self.foregroundImageSize = foregroundImageSize
        self.backgroundImageSize = backgroundImageSize
        self.buttonTitle = buttonTitle
        self.isEnabled = isEnabled
        self.action = action
    }
   
    func makeUIView(context: Context) -> UIButton {
        let resizedBGImage = UIImage(named: backgroundImageURL)?.resizeImageTo(size: backgroundImageSize)
       
        let button = UIButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.setBackgroundImage(resizedBGImage, for: .normal)
        button.clipsToBounds = true
       
        if let foregroundImageURL = foregroundImageURL, let foregroundImageSize = foregroundImageSize, let buttonTitle = buttonTitle  {
            let resizedFGImage = UIImage(named: foregroundImageURL)?.resizeImageTo(size: foregroundImageSize)
            button.setImage(resizedFGImage, for: .normal)
            button.semanticContentAttribute = .forceLeftToRight
            button.contentHorizontalAlignment = .left
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: UIDevice.current.userInterfaceIdiom == .pad ? 27 : 16, bottom: 0, right: 0)
           
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.gray, for: .highlighted)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: UIDevice.current.userInterfaceIdiom == .pad ? 45 : 25, bottom: 0, right: 0)
        }
       
        return button
    }
   
    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.isUserInteractionEnabled = isEnabled
       
        let backgroundImage = UIImage(named: backgroundImageURL)!
        if !isEnabled {
            uiView.setBackgroundImage(backgroundImage.applyBlackAndWhiteFilter()!.resizeImageTo(size: backgroundImageSize), for: .normal)
        } else {
            uiView.setBackgroundImage(backgroundImage.resizeImageTo(size: backgroundImageSize), for: .normal)
        }
        if let foregroundImageURL = foregroundImageURL, let foregroundImageSize = foregroundImageSize {
            let foregroundImage = UIImage(named: foregroundImageURL)!
            if !isEnabled {
                uiView.setImage(foregroundImage.applyBlackAndWhiteFilter()!.resizeImageTo(size: foregroundImageSize), for: .normal)
            } else {
                uiView.setImage(foregroundImage.resizeImageTo(size: foregroundImageSize), for: .normal)
            }
        }
        uiView.clipsToBounds = true
    }
   
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
   
    class Coordinator: NSObject {
       
        var parent: HighlightableButton
       
        init(_ button: HighlightableButton) {
            self.parent = button
        }
       
        @objc func buttonTapped() {
            self.parent.action()
        }
    }
}
