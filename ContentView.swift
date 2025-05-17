//
//  CharacterSelectScene.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//
import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var currentScene: GameSceneType = .mainMenu
    @State private var skView: SKView?
    
    var body: some View {
        GeometryReader { geometry in
            let sceneSize = CGSize(
                width: max(geometry.size.width, geometry.size.height),
                height: min(geometry.size.width, geometry.size.height)
            )
            
            SpriteViewRepresentable(sceneType: currentScene, size: sceneSize)
                .ignoresSafeArea()
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("ChangeGameScene"),
                        object: nil,
                        queue: .main
                    ) { notification in
                        if let sceneType = notification.userInfo?["sceneType"] as? GameSceneType {
                            print("Changing scene to: \(sceneType)")
                            self.currentScene = sceneType
                        }
                    }
                }
        }
    }
}


struct SpriteViewRepresentable: UIViewRepresentable {
    let sceneType: GameSceneType
    let size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        
        let view = SKView(frame: CGRect(origin: .zero, size: size))
        view.preferredFramesPerSecond = 60
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        print("SpriteViewRepresentable updating with scene type: \(sceneType)")

        let scene = createScene(for: sceneType, size: size)
        
        let transition = SKTransition.crossFade(withDuration: 0.5)
        uiView.presentScene(scene, transition: transition)
    }
    
    private func createScene(for sceneType: GameSceneType, size: CGSize) -> SKScene {
        let scene: SKScene
        
        switch sceneType {
        case .mainMenu:
            scene = MainMenuScene()
            
        case .gameLevel1:
            scene = Level1Scene()
            
        case .gameLevel2:
            scene = Level2Scene()
            
        case .gameLevel3:
            scene = Level3Scene()
            
        case .characterSelect:
            scene = CharacterSelectScene()
        }
        
        scene.size = size
        scene.scaleMode = .aspectFill
        
        print("Created scene of type: \(scene.classForCoder), size: \(size)")
        return scene
    }
}

enum GameSceneType {
    case mainMenu
    case characterSelect
    case gameLevel1
    case gameLevel2
    case gameLevel3
}


class SceneTransitionManager {
    static func transition(to sceneType: GameSceneType) {
        print("Transition requested to: \(sceneType)")
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ChangeGameScene"),
            object: nil,
            userInfo: ["sceneType": sceneType]
        )
    }
}
