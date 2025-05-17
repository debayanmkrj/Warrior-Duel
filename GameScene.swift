//
//  GameScene.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    internal var player: Player!
    internal var enemy: Enemy!
    internal var hud: HUD!
    internal var controls: VirtualController!
    
    internal var currentLevel: Int
    internal var gameState: GameState = .playing
    
    internal var background: SKSpriteNode!
    internal var floor: SKNode!
    
    private var gameTimer: TimeInterval = 100.0
    private var lastUpdateTime: TimeInterval = 0.0
    private var isGamePaused = false
    private var pauseNode: SKNode?
    
    init(level: Int) {
        self.currentLevel = level
        super.init(size: CGSize(width: 1024, height: 768))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        print("Level \(currentLevel) starting")
        setupPhysics()
        setupBackground()
        setupFloor()
        setupLevel()
        setupHUD()
        setupControls()
        playBackgroundMusic()
    }
    
    internal func setupPhysics() {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        let boundary = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = boundary
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = CollisionCategory.boundary
        
        enumerateChildNodes(withName: "debugBoundary") { node, _ in
            node.removeFromParent()
        }
    }
    
    internal func setupBackground() {
        
        var backgroundName = "castle"
        
        switch currentLevel {
        case 1:
            backgroundName = "castle"
        case 2:
            backgroundName = "terrace"
        case 3:
            backgroundName = "throne_room"
        default:
            backgroundName = "castle"
        }
        
        //  background sprite
        background = SKSpriteNode(imageNamed: backgroundName)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = self.size
        background.zPosition = ZPosition.background
        addChild(background)
    }
    
    //  floor for characters to stand on
    internal func setupFloor() {
        floor = SKNode()
        floor.position = CGPoint(x: size.width/2, y: 80)
        let floorSize = CGSize(width: size.width, height: 10)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floorSize)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = CollisionCategory.boundary
        floor.physicsBody?.friction = 0.2
        
        
        addChild(floor)
    }
    
    //  level-specific elements
    internal func setupLevel() {
        
        let characterTypeName = UserDefaults.standard.string(forKey: "selectedCharacter") ?? CharacterType.fighter.rawValue
        let characterType = CharacterType(rawValue: characterTypeName) ?? .fighter
        player = Player(characterType: characterType)
        player.position = CGPoint(x: size.width * 0.25, y: 100)
        addChild(player)
        var enemyType: EnemyType
        
        switch currentLevel {
        case 1:
            enemyType = .convertedVampire
        case 2:
            enemyType = .vampireGirl
        case 3:
            enemyType = .countessVampire
        default:
            enemyType = .convertedVampire
        }
        
        enemy = Enemy(enemyType: enemyType, level: currentLevel)
        enemy.position = CGPoint(x: size.width * 0.75, y: 100)
        addChild(enemy)
        
        addShadowEffect()
    }
    
    //  HUD
    internal func setupHUD() {
        hud = HUD(sceneSize: size)
        hud.updateLevel(currentLevel)
        hud.updateTimer(Int(gameTimer))
        hud.updateEnemyName(forLevel: currentLevel)
        addChild(hud)
    }
    
    //  virtual controls
    internal func setupControls() {
        controls = VirtualController(sceneSize: size)
        
        controls.setJoystickHandler { [weak self] direction in
            self?.player.move(direction: direction)
        }
        
        controls.setPunchHandler { [weak self] in
            self?.player.attack(type: .punch)
        }
        
        controls.setKickHandler { [weak self] in
            self?.player.attack(type: .kick)
        }
        
        controls.setSpecialHandler { [weak self] in
            self?.player.attack(type: .special)
        }
        
        controls.setShieldHandler { [weak self] in
            self?.player.shieldPressed()
        }
        
        addChild(controls)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isGamePaused {
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "resumeButton" || node.parent?.name == "resumeButton" {
                    resumeGame()
                    return
                } else if node.name == "mainMenuButton" || node.parent?.name == "mainMenuButton" {
                    returnToMainMenu()
                    return
                }
            }
            return
        }
        
        if let pauseButton = hud.childNode(withName: "//pauseButton"), pauseButton.contains(location) {
            showPauseMenu()
            return
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    internal func addShadowEffect() {
        
        let playerShadow = SKShapeNode(ellipseOf: CGSize(width: 80, height: 20))
        playerShadow.fillColor = .black
        playerShadow.strokeColor = .clear
        playerShadow.alpha = 0.5
        playerShadow.zPosition = ZPosition.floor + 1
        playerShadow.position = CGPoint(x: 0, y: -player.size.height/2 + 5)
        player.addChild(playerShadow)
        
        let enemyShadow = SKShapeNode(ellipseOf: CGSize(width: 80, height: 20))
        enemyShadow.fillColor = .black
        enemyShadow.strokeColor = .clear
        enemyShadow.alpha = 0.5
        enemyShadow.zPosition = ZPosition.floor + 1
        enemyShadow.position = CGPoint(x: 0, y: -enemy.size.height/2 + 5)
        enemy.addChild(enemyShadow)
    }
    
    internal func playBackgroundMusic() {
        AudioManager.shared.playGameLevelMusic()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if gameState != .playing || isGamePaused {
            return
        }
        
        gameTimer -= dt
        hud.updateTimer(Int(max(0, gameTimer)))
        if gameTimer <= 0 {
            
            let playerHealth = player.getHealthPercentage()
            let enemyHealth = enemy.getHealthPercentage()
            
            if playerHealth > enemyHealth {
                gameState = .victory
                handleGameOver(playerWon: true)
            } else if enemyHealth > playerHealth {
                gameState = .defeat
                handleGameOver(playerWon: false)
            } else {
                
                showDrawMessage()
            }
            return
        }
        
        enemy.update(currentTime: currentTime, playerPosition: player.position)
        
        hud.updatePlayerHealth(player.getHealthPercentage())
        hud.updatePlayerSpecial(player.getSpecialMeterPercentage())
        hud.updateEnemyHealth(enemy.getHealthPercentage())
        hud.updateEnemySpecial(enemy.getSpecialMeterPercentage())
        
        checkGameEndConditions()
    }
    
    private func showDrawMessage() {
        
        controls.isUserInteractionEnabled = false
        AudioManager.shared.playTimeOverSound()
        
        
        let drawLabel = SKLabelNode(fontNamed: "Arial-Bold")
        drawLabel.text = "DRAW!"
        drawLabel.fontSize = 60
        drawLabel.fontColor = .yellow
        drawLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        drawLabel.setScale(0)
        drawLabel.zPosition = ZPosition.popup
        addChild(drawLabel)
        
        drawLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                // Restart level after delay
                self?.restartLevel()
            }
        ]))
    }
    
    private func restartLevel() {
        
        let currentSceneType: GameSceneType
        switch currentLevel {
        case 1:
            currentSceneType = .gameLevel1
        case 2:
            currentSceneType = .gameLevel2
        case 3:
            currentSceneType = .gameLevel3
        default:
            currentSceneType = .gameLevel1
        }
        
        SceneTransitionManager.transition(to: currentSceneType)
    }
    
    func showPauseMenu() {
        if isGamePaused {
            return
        }
        AudioManager.shared.playButtonSelectSound()
        isGamePaused = true
        
        pauseNode = SKNode()
        pauseNode?.zPosition = ZPosition.popup
        
        let overlay = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: size))
        overlay.fillColor = UIColor.black.withAlphaComponent(0.2)
        overlay.strokeColor = .clear
        overlay.zPosition = ZPosition.popup
        pauseNode?.addChild(overlay)
        
        let pauseTitle = SKLabelNode(fontNamed: "Arial-Bold")
        pauseTitle.text = "PAUSED"
        pauseTitle.fontSize = 20
        pauseTitle.fontColor = .white
        pauseTitle.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        pauseNode?.addChild(pauseTitle)
        
        let resumeButton = createMenuButton(text: "RESUME", position: CGPoint(x: size.width/2, y: size.height * 0.6))
        resumeButton.name = "resumeButton"
        pauseNode?.addChild(resumeButton)
        
        let mainMenuButton = createMenuButton(text: "MAIN MENU", position: CGPoint(x: size.width/2, y: size.height * 0.4))
        mainMenuButton.name = "mainMenuButton"
        pauseNode?.addChild(mainMenuButton)
        
        addChild(pauseNode!)
        
        controls.isUserInteractionEnabled = false
        
        scene?.physicsWorld.speed = 0
    }
    
    private func createMenuButton(text: String, position: CGPoint) -> SKNode {
        let button = SKNode()
        button.position = position
        
        let buttonBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        buttonBackground.fillColor = .red
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 2
        button.addChild(buttonBackground)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-Bold")
        buttonLabel.text = text
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        button.addChild(buttonLabel)
        
        return button
    }
    
    func resumeGame() {
        if !isGamePaused {
            return
        }
        
        AudioManager.shared.playButtonSelectSound()
        
        AudioManager.shared.resumeBackgroundMusic()
        pauseNode?.removeFromParent()
        pauseNode = nil
        scene?.physicsWorld.speed = 1
        
        controls.isUserInteractionEnabled = true
        
        isGamePaused = false
    }
    
    internal func checkGameEndConditions() {
        if player.getHealth() <= 0 {
            
            gameState = .defeat
            controls.isUserInteractionEnabled = false
            AudioManager.shared.playPlayerDefeatSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.handleGameOver(playerWon: false)
            }
        } else if enemy.getHealth() <= 0 {
            
            gameState = .victory
            controls.isUserInteractionEnabled = false
            AudioManager.shared.playPlayerVictorySound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.handleGameOver(playerWon: true)
            }
        }
    }
    
    internal func handleGameOver(playerWon: Bool) {
        
        controls.isUserInteractionEnabled = false
        
        if playerWon {
            
            print("Player won level \(currentLevel)!")
            
            let victoryDelay = 2.0
            
            let victoryLabel = SKLabelNode(fontNamed: "Futura-Bold")
            victoryLabel.text = "You won!"
            victoryLabel.fontSize = 40
            victoryLabel.fontColor = .green
            victoryLabel.position = CGPoint(x: size.width/2, y: size.height/2)
            victoryLabel.setScale(0)
            victoryLabel.zPosition = ZPosition.popup
            addChild(victoryLabel)
            
            victoryLabel.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.2)
            ]))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + victoryDelay) {
                if self.currentLevel < 3 {
                    
                    self.transitionToNextLevel()
                } else {
                    
                    self.showGameCompleteScene()
                }
            }
        } else {
            print("Player lost level \(currentLevel)")
            
            let defeatLabel = SKLabelNode(fontNamed: "Futura-Bold")
            defeatLabel.text = "You lost!"
            defeatLabel.fontSize = 40
            defeatLabel.fontColor = .red
            defeatLabel.position = CGPoint(x: size.width/2, y: size.height/2)
            defeatLabel.setScale(0)
            defeatLabel.zPosition = ZPosition.popup
            addChild(defeatLabel)
            defeatLabel.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.2)
            ]))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.returnToMainMenu()
            }
        }
    }
    
    
    internal func transitionToNextLevel() {
        
        let nextSceneType: GameSceneType
        AudioManager.shared.playLevelChangeSound()
        switch currentLevel {
        case 1:
            nextSceneType = .gameLevel2
        case 2:
            nextSceneType = .gameLevel3
        default:
            nextSceneType = .mainMenu
        }
        
        SceneTransitionManager.transition(to: nextSceneType)
    }
    
    internal func showGameCompleteScene() {
        returnToMainMenu()
    }
    
    internal func returnToMainMenu() {
        AudioManager.shared.playButtonSelectSound()
        SceneTransitionManager.transition(to: .mainMenu)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node, let bodyB = contact.bodyB.node else {
            return
        }
        
        if (bodyA.name == "playerAttack" && bodyB.name == "enemy") ||
            (bodyB.name == "playerAttack" && bodyA.name == "enemy") {
            
            let attackNode = bodyA.name == "playerAttack" ? bodyA : bodyB
            let enemyNode = bodyA.name == "enemy" ? bodyA : bodyB
            
            if let damageValue = attackNode.userData?.value(forKey: "damage") as? Int {
                print("Player attack hit enemy with damage: \(damageValue)")
                (enemyNode as? Enemy)?.takeDamage(damageValue)
                showDamageEffect(at: contact.contactPoint, damage: damageValue)
                
                if attackNode.name == "playerAttack" {
                    player.specialMeter += damageValue / 3
                    if player.specialMeter > player.maxSpecialMeter {
                        player.specialMeter = player.maxSpecialMeter
                    }
                }
            }
        }
        
        if (bodyA.name == "enemyAttack" && bodyB.name == "player") ||
            (bodyB.name == "enemyAttack" && bodyA.name == "player") {
            let attackNode = bodyA.name == "enemyAttack" ? bodyA : bodyB
            let playerNode = bodyA.name == "player" ? bodyA : bodyB
            
            if let damageValue = attackNode.userData?.value(forKey: "damage") as? Int {
                print("Enemy attack hit player with damage: \(damageValue)")
                (playerNode as? Player)?.takeDamage(damageValue)
                showDamageEffect(at: contact.contactPoint, damage: damageValue)
                
                if attackNode.name == "enemyAttack" {
                    enemy.specialMeter += damageValue / 3
                    if enemy.specialMeter > enemy.maxSpecialMeter {
                        enemy.specialMeter = enemy.maxSpecialMeter
                    }
                }
            }
        }
    }
    
    internal func showDamageEffect(at position: CGPoint, damage: Int) {
        
        let damageLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        damageLabel.text = "\(damage)"
        damageLabel.fontSize = 24
        damageLabel.fontColor = .red
        damageLabel.position = position
        damageLabel.zPosition = ZPosition.effect
        addChild(damageLabel)
        
        let isPlayerDamaged = position.x < size.width / 2
        
        if isPlayerDamaged {
            
            AudioManager.shared.playEnemyAttackSound(attackType: 1)
        } else {
            
            AudioManager.shared.playAttackSound(attackType: 1)
        }
        
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove])
        damageLabel.run(sequence)
    }
}


enum GameState {
    case playing
    case victory
    case defeat
    case paused
}
