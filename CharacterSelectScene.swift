//
//  CharacterSelectScene.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class CharacterSelectScene: SKScene {
    
    private var fighterOption: SKNode!
    private var samuraiOption: SKNode!
    private var shinobiOption: SKNode!
    private var backButton: SKShapeNode!
    private var selectedCharacterData: CharacterType?
    private var selectedCharacter: CharacterType = .fighter
    
    override func didMove(to view: SKView) {
        print("Character Select Scene loaded")
        
        setupBackground()
        setupTitle()
        setupCharacterOptions()
        setupStartButton()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "menu_background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = ZPosition.background
        addChild(background)
    }
    
    private func setupTitle() {
        let titleLabel = SKLabelNode(fontNamed: "Futura-Bold")
        titleLabel.text = "SELECT YOUR WARRIOR"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        titleLabel.zPosition = ZPosition.hud
        addChild(titleLabel)
    }
    
    private func setupCharacterOptions() {
        
        let characterSpacing: CGFloat = size.width / 4
        let characterY = size.height * 0.60
        fighterOption = createCharacterOption(
            type: .fighter,
            position: CGPoint(x: characterSpacing, y: characterY)
        )
        addChild(fighterOption)
        
        samuraiOption = createCharacterOption(
            type: .samurai,
            position: CGPoint(x: characterSpacing * 2, y: characterY)
        )
        addChild(samuraiOption)
        
        shinobiOption = createCharacterOption(
            type: .shinobi,
            position: CGPoint(x: characterSpacing * 3, y: characterY)
        )
        addChild(shinobiOption)
        
        let labelY = size.height * 0.3
        
        // Fighter label
        let fighterLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        fighterLabel.text = "FIGHTER"
        fighterLabel.fontSize = 20
        fighterLabel.fontColor = .yellow // Default selected
        fighterLabel.position = CGPoint(x: characterSpacing, y: labelY)
        fighterLabel.name = "fighterLabel"
        addChild(fighterLabel)
        
        // Samurai label
        let samuraiLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        samuraiLabel.text = "SAMURAI"
        samuraiLabel.fontSize = 20
        samuraiLabel.fontColor = .white
        samuraiLabel.position = CGPoint(x: characterSpacing * 2, y: labelY)
        samuraiLabel.name = "samuraiLabel"
        addChild(samuraiLabel)
        
        // Shinobi label
        let shinobiLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        shinobiLabel.text = "SHINOBI"
        shinobiLabel.fontSize = 20
        shinobiLabel.fontColor = .white
        shinobiLabel.position = CGPoint(x: characterSpacing * 3, y: labelY)
        shinobiLabel.name = "shinobiLabel"
        addChild(shinobiLabel)
        
        highlightCharacter(type: .fighter)
    }
    
    private func createCharacterOption(type: CharacterType, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = type.rawValue
        
        let frames = SpriteAnimation.createAnimationFrames(
            for: type.rawValue,
            action: "Idle",
            frameCount: 6
        )
        
        // sprite with the first frame
        let sprite: SKSpriteNode
        if !frames.isEmpty {
            sprite = SKSpriteNode(texture: frames[0])
            print("Created sprite for \(type.rawValue) using first frame of idle animation")
        } else {
            sprite = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 120))
            print("WARNING: Could not load frames for \(type.rawValue), using placeholder")
        }
        
        sprite.setScale(2.0)
        sprite.zPosition = ZPosition.character
        container.addChild(sprite)
        
        return container
    }
    
    private func setupStartButton() {
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 40
        
        // start button
        let startButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        startButton.fillColor = .red
        startButton.strokeColor = .white
        startButton.lineWidth = 2
        startButton.position = CGPoint(x: size.width / 2 + buttonWidth/2 + 20, y: size.height * 0.2)
        startButton.zPosition = ZPosition.hud
        startButton.name = "startButton"
        
        // Button text
        let buttonLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        buttonLabel.text = "START BATTLE"
        buttonLabel.fontSize = 22
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        startButton.addChild(buttonLabel)
        
        addChild(startButton)
        
        backButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        backButton.fillColor = .darkGray
        backButton.strokeColor = .white
        backButton.lineWidth = 2
        backButton.position = CGPoint(x: size.width / 2 - buttonWidth/2 - 20, y: size.height * 0.2)
        backButton.zPosition = ZPosition.hud
        backButton.name = "backButton"
        
        // Back button text
        let backLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        backLabel.text = "MAIN MENU"
        backLabel.fontSize = 22
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backButton.addChild(backLabel)
        
        addChild(backButton)
    }
    
    private func highlightCharacter(type: CharacterType) {
        
        AudioManager.shared.playButtonSelectSound()
        
        if let label = childNode(withName: "fighterLabel") as? SKLabelNode {
            label.fontColor = .white
        }
        if let label = childNode(withName: "samuraiLabel") as? SKLabelNode {
            label.fontColor = .white
        }
        if let label = childNode(withName: "shinobiLabel") as? SKLabelNode {
            label.fontColor = .white
        }
        fighterOption.setScale(1.0)
        samuraiOption.setScale(1.0)
        shinobiOption.setScale(1.0)
        
        let selectedOption: SKNode?
        let selectedLabel: String
        
        switch type {
        case .fighter:
            selectedOption = fighterOption
            selectedLabel = "fighterLabel"
        case .samurai:
            selectedOption = samuraiOption
            selectedLabel = "samuraiLabel"
        case .shinobi:
            selectedOption = shinobiOption
            selectedLabel = "shinobiLabel"
        }
        
        selectedOption?.setScale(1.2)
        
        if let label = childNode(withName: selectedLabel) as? SKLabelNode {
            label.fontColor = .yellow
        }
        selectedCharacter = type
        
        UserDefaults.standard.set(type.rawValue, forKey: "selectedCharacter")
        
        print("Selected character: \(type.rawValue)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let nodeName = node.name {
                print("Touched node: \(nodeName)")
                
                
                if nodeName == CharacterType.fighter.rawValue || node.parent?.name == CharacterType.fighter.rawValue {
                    highlightCharacter(type: .fighter)
                } else if nodeName == CharacterType.samurai.rawValue || node.parent?.name == CharacterType.samurai.rawValue {
                    highlightCharacter(type: .samurai)
                } else if nodeName == CharacterType.shinobi.rawValue || node.parent?.name == CharacterType.shinobi.rawValue {
                    highlightCharacter(type: .shinobi)
                } else if nodeName == "startButton" || node.parent?.name == "startButton" {
                    print("Start button pressed with character: \(selectedCharacter.rawValue)")
                    startGame()
                    return
                } else if nodeName == "backButton" || node.parent?.name == "backButton" {
                    returnToMainMenu()
                    return
                }
            }
        }
    }
    private func returnToMainMenu() {
        AudioManager.shared.playButtonSelectSound()
        print("Returning to main menu")
        SceneTransitionManager.transition(to: .mainMenu)
    }
    
    
    private func startGame() {
        
        AudioManager.shared.playButtonSelectSound()
        
        print("Starting game with character: \(selectedCharacter.rawValue)")
        
        UserDefaults.standard.set(selectedCharacter.rawValue, forKey: "selectedCharacter")
        UserDefaults.standard.synchronize() // Force save immediately
        
        if let startButton = childNode(withName: "startButton") as? SKShapeNode {
            startButton.run(SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1),
                SKAction.wait(forDuration: 0.1),
                SKAction.run {
                    
                    AudioManager.shared.playLevelChangeSound()
                    
                    
                    SceneTransitionManager.transition(to: .gameLevel1)
                }
            ]))
        } else {
            
            AudioManager.shared.playLevelChangeSound()
            SceneTransitionManager.transition(to: .gameLevel1)
        }
    }
}
