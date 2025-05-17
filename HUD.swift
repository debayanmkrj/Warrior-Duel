//
//  HUD.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class HUD: SKNode {
    
    private var playerHealthBar: SKSpriteNode!
    private var playerHealthBackground: SKSpriteNode!
    private var playerSpecialBar: SKSpriteNode!
    private var playerSpecialBackground: SKSpriteNode!
    
    private var enemyHealthBar: SKSpriteNode!
    private var enemyHealthBackground: SKSpriteNode!
    private var enemySpecialBar: SKSpriteNode!
    private var enemySpecialBackground: SKSpriteNode!
    private var enemyNameLabel: SKLabelNode!
    
    private var levelLabel: SKLabelNode!
    private var pauseButton: SKSpriteNode!
    
    
    private let barWidth: CGFloat = 200.0
    private let barHeight: CGFloat = 20.0
    private let specialBarHeight: CGFloat = 10.0
    private var timerLabel: SKLabelNode!
    
    init(sceneSize: CGSize) {
        super.init()
        setupPlayerBars(sceneSize: sceneSize)
        setupEnemyBars(sceneSize: sceneSize)
        setupTimerLabel(sceneSize: sceneSize)
        setupLevelLabel(sceneSize: sceneSize)
        setupPauseButton(sceneSize: sceneSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupPlayerBars(sceneSize: CGSize) {
        playerHealthBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth, height: barHeight))
        playerHealthBackground.position = CGPoint(x: sceneSize.width * 0.25, y: sceneSize.height - 50)
        playerHealthBackground.zPosition = ZPosition.hud
        addChild(playerHealthBackground)
        
        playerHealthBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: barHeight))
        playerHealthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        playerHealthBar.position = CGPoint(x: playerHealthBackground.position.x - barWidth/2, y: playerHealthBackground.position.y)
        playerHealthBar.zPosition = ZPosition.hud + 1
        addChild(playerHealthBar)
        let specialBarWidth = barWidth * 0.4
        playerSpecialBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: specialBarWidth, height: specialBarHeight))
        let centerOffset = (barWidth - specialBarWidth) / 2
        playerSpecialBackground.position = CGPoint(x: sceneSize.width * 0.25 - centerOffset, y: sceneSize.height - 75)
        playerSpecialBackground.zPosition = ZPosition.hud
        addChild(playerSpecialBackground)
        playerSpecialBar = SKSpriteNode(color: .blue, size: CGSize(width: 0, height: specialBarHeight))
        playerSpecialBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        playerSpecialBar.position = CGPoint(x: playerSpecialBackground.position.x - specialBarWidth/2, y: playerSpecialBackground.position.y)
        playerSpecialBar.zPosition = ZPosition.hud + 1
        addChild(playerSpecialBar)
        
        let playerLabel = SKLabelNode(fontNamed: "Futura-Bold")
        playerLabel.text = "PLAYER"
        playerLabel.fontSize = 12
        playerLabel.fontColor = .green
        playerLabel.position = CGPoint(x: sceneSize.width * 0.25, y: sceneSize.height - 30)
        playerLabel.zPosition = ZPosition.hud
        addChild(playerLabel)
    }
    
    
    private func setupEnemyBars(sceneSize: CGSize) {
        
        enemyHealthBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth, height: barHeight))
        enemyHealthBackground.position = CGPoint(x: sceneSize.width * 0.75, y: sceneSize.height - 50)
        enemyHealthBackground.zPosition = ZPosition.hud
        addChild(enemyHealthBackground)
        
        enemyHealthBar = SKSpriteNode(color: .red, size: CGSize(width: barWidth, height: barHeight))
        enemyHealthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        enemyHealthBar.position = CGPoint(x: enemyHealthBackground.position.x - barWidth/2, y: enemyHealthBackground.position.y)
        enemyHealthBar.zPosition = ZPosition.hud + 1
        addChild(enemyHealthBar)
        let specialBarWidth = barWidth * 0.4
        enemySpecialBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: specialBarWidth, height: specialBarHeight))
        let centerOffset = (barWidth - specialBarWidth) / 2
        enemySpecialBackground.position = CGPoint(x: sceneSize.width * 0.75 - centerOffset, y: sceneSize.height - 75)
        enemySpecialBackground.zPosition = ZPosition.hud
        addChild(enemySpecialBackground)
        
        enemySpecialBar = SKSpriteNode(color: .purple, size: CGSize(width: 0, height: specialBarHeight))
        enemySpecialBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        enemySpecialBar.position = CGPoint(x: enemySpecialBackground.position.x - specialBarWidth/2, y: enemySpecialBackground.position.y)
        enemySpecialBar.zPosition = ZPosition.hud + 1
        addChild(enemySpecialBar)
        
        enemyNameLabel = SKLabelNode(fontNamed: "Futura-Bold")
        enemyNameLabel.fontSize = 12
        enemyNameLabel.fontColor = .red
        enemyNameLabel.position = CGPoint(x: sceneSize.width * 0.75, y: sceneSize.height - 30)
        enemyNameLabel.zPosition = ZPosition.hud
        addChild(enemyNameLabel)
    }
    
    private func setupLevelLabel(sceneSize: CGSize) {
        levelLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        levelLabel.text = "LEVEL 1"
        levelLabel.fontSize = 20
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 45)
        levelLabel.zPosition = ZPosition.hud
        addChild(levelLabel)
    }
    
    private func setupTimerLabel(sceneSize: CGSize) {
        timerLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        timerLabel.text = "100"
        timerLabel.fontSize = 40
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 80)
        timerLabel.zPosition = ZPosition.hud
        addChild(timerLabel)
    }
    
    func updateTimer(_ seconds: Int) {
        timerLabel.text = "\(seconds)"
        
        if seconds <= 10 {
            timerLabel.fontColor = .red
        } else if seconds <= 30 {
            timerLabel.fontColor = .yellow
        } else {
            timerLabel.fontColor = .white
        }
    }
    
    private func setupPauseButton(sceneSize: CGSize) {
        
        pauseButton = SKSpriteNode(color: .darkGray, size: CGSize(width: 40, height: 40))
        pauseButton.position = CGPoint(x: sceneSize.width - 30, y: sceneSize.height - 30)
        pauseButton.zPosition = ZPosition.hud
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
        
        let pauseIcon = SKShapeNode()
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: -5, y: -8))
        pathToDraw.addLine(to: CGPoint(x: -5, y: 8))
        pathToDraw.move(to: CGPoint(x: 5, y: -8))
        pathToDraw.addLine(to: CGPoint(x: 5, y: 8))
        pauseIcon.path = pathToDraw
        pauseIcon.strokeColor = .white
        pauseIcon.lineWidth = 3
        pauseButton.addChild(pauseIcon)
    }
    
    func updatePlayerHealth(_ percentage: CGFloat) {
        let clampedPercentage = max(0, min(percentage, 1.0))
        let newWidth = barWidth * clampedPercentage
        playerHealthBar.size.width = newWidth
        
        if clampedPercentage > 0.6 {
            playerHealthBar.color = .green
        } else if clampedPercentage > 0.3 {
            playerHealthBar.color = .yellow
        } else {
            playerHealthBar.color = .red
        }
    }
    
    func updatePlayerSpecial(_ percentage: CGFloat) {
        let clampedPercentage = max(0, min(percentage, 1.0))
        let specialBarWidth = barWidth * 0.4
        let newWidth = specialBarWidth * clampedPercentage
        playerSpecialBar.size.width = newWidth
        
        if clampedPercentage >= 1.0 {
            playerSpecialBar.color = .cyan
        } else {
            playerSpecialBar.color = .blue
        }
    }
    
    func updateEnemyHealth(_ percentage: CGFloat) {
        let clampedPercentage = max(0, min(percentage, 1.0))
        let newWidth = barWidth * clampedPercentage
        enemyHealthBar.size.width = newWidth
    }
    
    func updateEnemySpecial(_ percentage: CGFloat) {
        let clampedPercentage = max(0, min(percentage, 1.0))
        let specialBarWidth = barWidth * 0.4
        let newWidth = specialBarWidth * clampedPercentage
        enemySpecialBar.size.width = newWidth
        
        if clampedPercentage >= 1.0 {
            enemySpecialBar.color = .magenta
        } else {
            enemySpecialBar.color = .purple
        }
    }
    
    func updateLevel(_ level: Int) {
        levelLabel.text = "LEVEL \(level)"
    }
    
    func updateEnemyName(forLevel level: Int) {
        switch level {
        case 1:
            enemyNameLabel.text = "CONVERTED VAMPIRE"
        case 2:
            enemyNameLabel.text = "VAMPIRE GIRL"
        case 3:
            enemyNameLabel.text = "COUNTESS VAMPIRE"
        default:
            enemyNameLabel.text = "VAMPIRE"
        }
    }
}
