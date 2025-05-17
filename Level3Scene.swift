//
//  Level3Scene.swift
//  WarriorDuel
//
//  Created by Student on 4/26/25.
//

import SpriteKit

class Level3Scene: GameScene {
    
    private var castleBackground: SKSpriteNode!
    
    init() {
        super.init(level: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        print("Level 3 scene loaded")
        
        setupCastleBackground()
        
        super.didMove(to: view)
        
        
        setupLevel3Elements()
        
        introduceCountessVampire()
        
    }
    
    private func showLevelInfo() {
        
        let infoNode = SKNode()
        infoNode.zPosition = ZPosition.popup
        infoNode.alpha = 0
        
        let background = SKShapeNode(rect: CGRect(x: size.width/2 - 200, y: size.height/2 - 150, width: 400, height: 300), cornerRadius: 10)
        background.fillColor = UIColor.black.withAlphaComponent(0.8)
        background.strokeColor = .white
        infoNode.addChild(background)
        
        let titleLabel = SKLabelNode(fontNamed: "Arial-Bold")
        titleLabel.text = "LEVEL 3"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        infoNode.addChild(titleLabel)
        
        let enemyLabel = SKLabelNode(fontNamed: "Arial")
        enemyLabel.text = "Defeat the Countess Vampire"
        enemyLabel.fontSize = 24
        enemyLabel.fontColor = .white
        enemyLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        infoNode.addChild(enemyLabel)
        
        let controlsLabel = SKLabelNode(fontNamed: "Arial")
        controlsLabel.text = "Use shield to block attacks (30% damage)"
        controlsLabel.fontSize = 20
        controlsLabel.fontColor = .yellow
        controlsLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        infoNode.addChild(controlsLabel)
        
        let timeLabel = SKLabelNode(fontNamed: "Arial")
        timeLabel.text = "Defeat enemy within 100 seconds"
        timeLabel.fontSize = 20
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 40)
        infoNode.addChild(timeLabel)
        
        let startButton = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 10)
        startButton.fillColor = .red
        startButton.strokeColor = .white
        startButton.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        startButton.name = "startLevelButton"
        
        let startLabel = SKLabelNode(fontNamed: "Arial-Bold")
        startLabel.text = "START"
        startLabel.fontSize = 24
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startButton.addChild(startLabel)
        
        infoNode.addChild(startButton)
        
        addChild(infoNode)
        infoNode.run(SKAction.fadeIn(withDuration: 0.5))
        
        isPaused = true
        controls.isUserInteractionEnabled = false
        scene?.physicsWorld.speed = 0
    }
    
    
    private func setupCastleBackground() {
        
        castleBackground = SKSpriteNode(imageNamed: "throne_room")
        castleBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        castleBackground.size = self.size
        castleBackground.zPosition = ZPosition.background
        addChild(castleBackground)
        
        print("Throne Room background added")
    }
    
    private func setupLevel3Elements() {
        addTorch(at: CGPoint(x: size.width * 0.2, y: size.height * 0.7))
        addTorch(at: CGPoint(x: size.width * 0.8, y: size.height * 0.7))
        
        
        print("Level 3 specific elements added")
    }
    
    private func addTorch(at position: CGPoint) {
        
        let torch = SKSpriteNode(color: .orange, size: CGSize(width: 20, height: 40))
        torch.position = position
        torch.zPosition = ZPosition.background + 1
        
        let flame = SKEmitterNode()
        flame.particleTexture = SKTexture(imageNamed: "spark") // Fallback to system texture
        flame.particleBirthRate = 15
        flame.particleLifetime = 0.8
        flame.particlePositionRange = CGVector(dx: 10, dy: 10)
        flame.particleSpeed = 10
        flame.particleSpeedRange = 5
        flame.particleAlpha = 0.7
        flame.particleAlphaRange = 0.3
        flame.particleAlphaSpeed = -0.5
        flame.particleScale = 0.2
        flame.particleScaleRange = 0.1
        flame.particleScaleSpeed = -0.1
        flame.position = CGPoint(x: 0, y: 15)
        flame.particleColor = .orange
        flame.particleColorBlendFactor = 1.0
        flame.particleColorBlendFactorRange = 0.3
        flame.particleBlendMode = .add
        
        torch.addChild(flame)
        addChild(torch)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isPaused {
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "startLevelButton" {
                    
                    node.parent?.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ]))
                    
                    isPaused = false
                    controls.isUserInteractionEnabled = true
                    scene?.physicsWorld.speed = 1
                    return
                }
            }
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    private func introduceCountessVampire() {
        
        guard let enemy = self.enemy else { return }
        
        enemy.alpha = 0
        
        let entranceSequence = SKAction.sequence([
            
            SKAction.wait(forDuration: 1.0),
            
            SKAction.fadeIn(withDuration: 0.5),
            
            SKAction.moveBy(x: -50, y: 0, duration: 0.3),
            SKAction.moveBy(x: 50, y: 0, duration: 0.2),
            
            SKAction.run {
                
                enemy.run(SKAction.sequence([
                    SKAction.colorize(with: .red, colorBlendFactor: 0.7, duration: 0.2),
                    SKAction.colorize(withColorBlendFactor: 0, duration: 0.3)
                ]))
            }
        ])
        
        enemy.run(entranceSequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
}
