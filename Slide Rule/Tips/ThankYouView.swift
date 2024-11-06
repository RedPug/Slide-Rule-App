//
//  ThankYouView.swift
//  Slide Rule
//
//  Created by Rowan on 11/5/24.
//

import SwiftUI
import SpriteKit

struct ThankYouView: View {
    var body: some View {
        ZStack{
            GeometryReader { geo in
                SpriteView(scene: ParticleScene(size: geo.size), options: [.allowsTransparency])
            }
            

            Text("Thank you!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .foregroundStyle(Color.theme.text)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .ignoresSafeArea()
    }
}



class ParticleScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = .clear
        
        let colors: [UIColor] = [.red, .green, .blue, .yellow]
        let emitters = colors.map { createConfettiEmitter(with: $0) } // Add all emitter nodes to the scene
        for emitter in emitters {
            addChild(emitter)
        }
        
    }
    
    private func createConfettiEmitter(with color: UIColor) -> SKEmitterNode{
        let confetti = SKEmitterNode()
        
        confetti.particleBirthRate = 20
        confetti.particleLifetime = 5
        confetti.particleScale = 2
        confetti.particleScaleRange = 1
        
        confetti.position.y = size.height
        confetti.position.x = size.width/2
        confetti.particlePositionRange = CGVector(dx: size.width*0.9, dy: 0)
        
        confetti.particleRotationRange = .pi * 2
        confetti.particleRotationSpeed = .pi / 4
        confetti.yAcceleration = -200
        
        confetti.emissionAngleRange = .pi/4
        confetti.emissionAngle = .pi*3/2
        
        confetti.particleSpeed = 200
        confetti.particleSpeedRange = 50
        
        let rect = SKShapeNode(rectOf: CGSize(width: 10, height: 5))
        rect.fillColor = .white
        confetti.particleTexture = SKView().texture(from: rect)
        
        confetti.particleColorBlendFactor = 1
        confetti.particleColorSequence = nil
        confetti.particleColor = color
        confetti.alpha = 1
        
        return confetti
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.red, .green, .blue, .yellow]
        let color = colors.randomElement() ?? .white
        print("made it!")
        return color
    }
}
