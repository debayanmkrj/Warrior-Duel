//
//  MainMenuScene.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit
import UIKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        print("MainMenuScene initialized with size: \(self.size)")
        
        setupBackground()
        setupTitle()
        setupPlayButton()
        
        setupAudio()
    }
    
    private func setupBackground() {
        
        let background = SKSpriteNode(imageNamed: "menu_background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = ZPosition.background
        addChild(background)
        print("Background added with size: \(background.size)")
    }
    
    private func setupTitle() {
        
        let titleLabel = SKLabelNode(fontNamed: "Futura-Bold")
        titleLabel.text = "WARRIOR DUEL"
        titleLabel.fontSize = 50
        titleLabel.fontColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        titleLabel.zPosition = ZPosition.hud
        addChild(titleLabel)
        
        let subtitleLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        subtitleLabel.text = "Battle Against Vampires"
        subtitleLabel.fontSize = 20
        subtitleLabel.fontColor = .white
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        subtitleLabel.zPosition = ZPosition.hud
        addChild(subtitleLabel)
        
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        titleLabel.run(SKAction.repeatForever(pulseAction))
    }
    
    private func setupPlayButton() {
        
        let playButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        playButton.fillColor = .red
        playButton.strokeColor = .white
        playButton.lineWidth = 2
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        playButton.zPosition = ZPosition.hud
        playButton.name = "playButton"
        
        let playLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        playLabel.text = "SELECT CHARACTER"
        playLabel.fontSize = 16
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playLabel.horizontalAlignmentMode = .center
        playLabel.zPosition = ZPosition.hud + 1
        playButton.addChild(playLabel)
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        playButton.run(SKAction.repeatForever(pulseAction))
        
        addChild(playButton)
        
        let quitButton = SKShapeNode(rectOf: CGSize(width: 75, height: 20), cornerRadius: 10)
        quitButton.fillColor = .darkGray
        quitButton.strokeColor = .white
        quitButton.lineWidth = 2
        quitButton.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        quitButton.zPosition = ZPosition.hud
        quitButton.name = "quitButton"
        
        let quitLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        quitLabel.text = "QUIT GAME"
        quitLabel.fontSize = 10
        quitLabel.fontColor = .white
        quitLabel.verticalAlignmentMode = .center
        quitLabel.horizontalAlignmentMode = .center
        quitLabel.zPosition = ZPosition.hud + 1
        quitButton.addChild(quitLabel)
        
        addChild(quitButton)
    }
    
    private func setupAudio() {
        AudioManager.shared.playMainMenuMusic()
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print("Touch detected at: \(location)")
        
        if let posLabel = childNode(withName: "positionLabel") as? SKLabelNode {
            posLabel.text = "Touch: (\(Int(location.x)), \(Int(location.y)))"
        }
        
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if node.name == "playButton" || (node.parent?.name == "playButton") {
                print("Play button tapped!")
                handlePlayButtonTap()
                return
            } else if node.name == "quitButton" || (node.parent?.name == "quitButton") {
                print("Quit button tapped!")
                handleQuitButtonTap()
                return
            }
        }
    }
    
    private func handlePlayButtonTap() {
        
        guard let playButton = childNode(withName: "playButton") else {
            print("Error: Play button not found")
            return
        }
        
        AudioManager.shared.playButtonSelectSound()
        isUserInteractionEnabled = false
        playButton.run(SKAction.sequence([
            SKAction.scale(to: 0.8, duration: 0.1),
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak self] in
                print("Transitioning to character select")
                if let scene = self {
                    let flash = SKSpriteNode(color: .white, size: scene.size)
                    flash.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
                    flash.zPosition = 1000
                    flash.alpha = 0
                    scene.addChild(flash)
                    
                    flash.run(SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.8, duration: 0.2),
                        SKAction.fadeAlpha(to: 0, duration: 0.2),
                        SKAction.removeFromParent()
                    ]))
                }
                self?.transitionToCharacterSelect()
            }
        ]))
    }
    private func transitionToCharacterSelect() {
        SceneTransitionManager.transition(to: .characterSelect)
        print("Transition to Character Select triggered")
    }
    
    private func handleQuitButtonTap() {
        
        guard let quitButton = childNode(withName: "quitButton") else {
            print("Error: Quit button not found")
            return
        }
        
        
        AudioManager.shared.playButtonSelectSound()
        
        
        quitButton.run(SKAction.sequence([
            SKAction.scale(to: 0.8, duration: 0.1),
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.1),
            SKAction.run {
                
                exit(0)
            }
        ]))
    }
    
    private func transitionToGame() {
        SceneTransitionManager.transition(to: .gameLevel1)
        print("Transition to Level 1 triggered")
    }
}
