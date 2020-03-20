//
//  GameUIView.swift
//  SwiftUIAndSpriteKit
//
//  Created by Kyle Wilson on 2020-03-19.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import SwiftUI
import SpriteKit
import GameplayKit

struct SpriteKitContainer : UIViewRepresentable {
    let sceneName: String
    class Coordinator: NSObject {var scene: SKScene?
    }
    
    func makeCoordinator() -> Coordinator {
        // add bindings here
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true

       //load SpriteKit Scene
       let aScene = GameScene()
       aScene.scaleMode = .resizeFill
       context.coordinator.scene = aScene
       return view
    }
 
    func updateUIView(_ view: SKView, context: Context) {
       view.presentScene(context.coordinator.scene)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
   static var previews: some View {
      // Replace "MainScene" with your SpriteKit scene file
      SpriteKitContainer(sceneName: "MainScene")
         .edgesIgnoringSafeArea(.all)
         .previewLayout(.sizeThatFits)
      }
}
#endif

class GameViewController: UIViewController {
    
    /*
     In order for
     your game scene
     to show in simulator.
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.presentScene(scene)
        }
    }
}

class GameScene: SKScene {

    var sonic = SKSpriteNode()
    var sonicFrames: [SKTexture] = []
    
    override func didMove(to view: SKView) {
        makeSonic()
    }
    
    func makeSonic() {
        let marioAnimated = SKTextureAtlas(named: "sonic-run")
        var walkFrames: [SKTexture] = []
        
        let numImages = marioAnimated.textureNames.count
        for i in 1...numImages {
            let marioTextureName = "sonic-run\(i)"
            walkFrames.append(marioAnimated.textureNamed(marioTextureName))
            print(i)
        }
        sonicFrames = walkFrames
        
        let firstFrameTexture = sonicFrames[0]
        sonic = SKSpriteNode(texture: firstFrameTexture)
        sonic.position = CGPoint(x: frame.midX + 100, y: frame.midY + 100)
        sonic.scale(to: CGSize(width: 200, height: 200))
        addChild(sonic)
    }
    
    func animateSonic() {
        sonic.run(SKAction.repeatForever(SKAction.animate(with: sonicFrames, timePerFrame: 0.05)), withKey: "walking")
    }
    
    func moveSonic(location: CGPoint) {
        var multiplerForDirection: CGFloat
        
        let marioSpeed = frame.size.width / 1.5
        
        let moveDifference = CGPoint(x: location.x - sonic.position.x, y: location.y - sonic.position.y)
        let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
        
        let moveDuration = distanceToMove / marioSpeed
        
        if moveDifference.x > 0 {
            multiplerForDirection = 1.0
        } else {
            multiplerForDirection = -1.0
        }
        sonic.xScale = abs(sonic.xScale) * multiplerForDirection
        
        if sonic.action(forKey: "walking") == nil {
            animateSonic()
        }
        
        let moveAction = SKAction.move(to: location, duration: TimeInterval(moveDuration))
        
        let doneAction = SKAction.run({ [weak self] in
            self?.sonicMoveEnded()
        })
        
        let moveActionWithDone = SKAction.sequence([moveAction, doneAction])
        sonic.run(moveActionWithDone, withKey: "moving")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        moveSonic(location: location)
    }
    
    func sonicMoveEnded() {
        sonic.removeAllActions()
    }
}
