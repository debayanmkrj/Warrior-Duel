//
//  Player.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class Player: SKSpriteNode {
    
    private var characterType: CharacterType
    private var health: Int = 100
    private var maxHealth: Int = 100
    internal var specialMeter: Int = 0
    internal var maxSpecialMeter: Int = 30
    private var attackPower: Int = 10
    private var specialAttackPower: Int = 30
    private var isShielding = false
    private var runSpeedMultiplier: CGFloat = 2.0
    private var walkToRunTimer: Timer?
    private var moveDirection = CGPoint.zero
    
    var isAttacking = false
    private var isMoving = false
    private var isFacingRight = true
    
    private var frameCounts: [String: Int] = [:]
    private var animationFrames: [String: [SKTexture]] = [:]
    
    private func setupFrameCounts() {
        switch characterType {
        case .fighter:
            
            frameCounts = [
                "idle": 6,
                "walk": 8,
                "run": 8,
                "attack1": 4,
                "attack2": 3,
                "attack3": 4,
                "hurt": 3,
                "dead": 3,
                "shield": 2
            ]
        case .samurai:
            
            frameCounts = [
                "idle": 6,
                "walk": 8,
                "run": 8,
                "attack1": 6,
                "attack2": 4,
                "attack3": 3,
                "hurt": 2,
                "dead": 3,
                "shield": 2
            ]
        case .shinobi:
            
            frameCounts = [
                "idle": 6,
                "walk": 8,
                "run": 8,
                "attack1": 6,
                "attack2": 3,
                "attack3": 4,
                "hurt": 2,
                "dead": 4,
                "shield": 4
            ]
        }
    }
    
    
    private let animationDurations: [String: TimeInterval] = [
        "idle": 1.2,
        "walk": 0.8,
        "run": 0.6,
        "attack1": 0.3,
        "attack2": 0.4,
        "attack3": 0.7,
        "hurt": 0.3,
        "dead": 0.6,
        "shield": 0.5,
        "jump": 0.8
    ]
    
    init(characterType: CharacterType) {
        self.characterType = characterType
        
        let texture = SKTexture(imageNamed: "\(characterType.rawValue)_Idle")
        
        let desiredHeight: CGFloat = 250 // Adjust this value as needed
        let desiredWidth: CGFloat = 250
        let scaledSize = CGSize(width: desiredWidth, height: desiredHeight)
        super.init(texture: texture, color: .clear, size: scaledSize)
        
        setupFrameCounts()
        
        self.name = "player"
        self.zPosition = ZPosition.character
        
        loadAnimationFrames()
        setupPhysics()
        runAnimation(.idle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        
        let bodySize = CGSize(width: size.width * 0.7, height: size.height * 0.9)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        
        physicsBody?.categoryBitMask = CollisionCategory.player
        physicsBody?.contactTestBitMask = CollisionCategory.enemy | CollisionCategory.enemyAttack
        physicsBody?.collisionBitMask = CollisionCategory.boundary
        
        
        physicsBody?.linearDamping = 3.0
        physicsBody?.friction = 0.2
        
        self.name = "player"
    }
    
    private func loadAnimationFrames() {
        
        animationFrames.removeAll()
        
        for (animType, frameCount) in frameCounts {
            
            let actionName = convertAnimTypeToFileName(animType)
            print("Loading animation for \(characterType.rawValue)_\(actionName) with \(frameCount) frames")
            
            let frames = SpriteAnimation.createAnimationFrames(
                for: characterType.rawValue,
                action: actionName,
                frameCount: frameCount
            )
            
            if frames.isEmpty {
                print("Warning: No frames loaded for \(characterType.rawValue)_\(actionName)")
            } else {
                print("Loaded \(frames.count) frames for \(characterType.rawValue)_\(actionName)")
            }
            
            animationFrames[animType] = frames
        }
        
        print("Completed animation loading for \(characterType.rawValue)")
    }
    
    private func convertAnimTypeToFileName(_ animType: String) -> String {
        
        switch animType {
        case "attack1":
            return "Attack_1"
        case "attack2":
            return "Attack_2"
        case "attack3":
            return "Attack_3"
        case "dead":
            return "Dead"
        case "hurt":
            return "Hurt"
        case "idle":
            return "Idle"
        case "run":
            return "Run"
        case "walk":
            return "Walk"
        case "shield":
            return "Shield"
        default:
            return animType.prefix(1).uppercased() + animType.dropFirst()
        }
    }
    
    func runAnimation(_ animationType: AnimationType) {
        
        SpriteAnimation.stopAnimation(on: self)
        
        let animKey = getAnimationKey(for: animationType)
        
        if let frames = animationFrames[animKey],
           let duration = animationDurations[animKey] {
            
            if animationType == .idle {
                
                if !frames.isEmpty {
                    self.texture = frames.first
                }
                return
            } else if animationType == .dead {
                SpriteAnimation.runAnimation(on: self, frames: frames, duration: duration, repeating: false)
                return
            }
            
            let repeating = animationType == .walk || animationType == .run
            SpriteAnimation.runAnimation(on: self, frames: frames, duration: duration, repeating: repeating)
        } else {
            print("Missing animation for \(animKey)")
        }
    }
    
    private func getAnimationKey(for animationType: AnimationType) -> String {
        switch animationType {
        case .idle:
            return "idle"
        case .walk:
            return "walk"
        case .run:
            return "run"
        case .attack1:
            return "attack1"
        case .attack2:
            return "attack2"
        case .attack3:
            return "attack3"
        case .jump:
            return "jump"
        case .dead:
            return "dead"
        case .hurt:
            return "hurt"
        case .shield:
            return "shield"
        }
    }
    
    func move(direction: CGPoint) {
        
        if isAttacking || isShielding {
            isMoving = false
            return
        }
        
        if direction.x == 0 && direction.y == 0 {
            if isMoving {
                isMoving = false
                walkToRunTimer?.invalidate()
                walkToRunTimer = nil
                runAnimation(.idle)
                physicsBody?.velocity = .zero
            }
            return
        }
        
        isMoving = true
        
        let isRunning = walkToRunTimer == nil
        if isRunning || (!isRunning && Int(Date().timeIntervalSince1970 * 10) % 20 == 0) {
            AudioManager.shared.playFootstepSound()
        }
        
        if direction.x > 0 && !isFacingRight {
            isFacingRight = true
            xScale = abs(xScale)
        } else if direction.x < 0 && isFacingRight {
            isFacingRight = false
            xScale = -abs(xScale)
        }
        
        if walkToRunTimer == nil {
            runAnimation(.walk)
            walkToRunTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self, self.isMoving else { return }
                
                self.runAnimation(.run)
            }
        }
        
        let baseSpeed: CGFloat = 8.0
        
        let moveSpeed = isRunning ? baseSpeed * runSpeedMultiplier : baseSpeed
        
        let nextX = position.x + (direction.x * moveSpeed)
        
        let halfWidth = size.width / 2
        let screenWidth = (scene?.size.width ?? 1024)
        let boundedX = max(halfWidth, min(screenWidth - halfWidth, nextX))
        
        position = CGPoint(x: boundedX, y: position.y)
    }
    
    func isShieldActive() -> Bool {
        return isShielding
    }
    
    func attack(type: AttackType) {
        
        if isAttacking {
            return
        }
        
        if isShielding {
            return
        }
        
        isAttacking = true
        let animationType: AnimationType
        var damage: Int
        
        switch type {
        case .punch:
            animationType = .attack1
            damage = attackPower
            AudioManager.shared.playAttackSound(attackType: 1)
            
        case .kick:
            animationType = .attack2
            damage = attackPower + 5
            AudioManager.shared.playAttackSound(attackType: 2)
            
        case .special:
            if specialMeter < maxSpecialMeter {
                
                isAttacking = false
                return
            }
            animationType = .attack3
            
            damage = Int(Double(specialAttackPower) * 1.5)
            AudioManager.shared.playAttackSound(attackType: 3)
            specialMeter = 0
        }
        
        runAnimation(animationType)
        
        createAttackHitbox(damage: damage, attackType: type)
        
        let animationDuration = animationDurations[getAnimationKey(for: animationType)] ?? 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.isAttacking = false
            self?.runAnimation(.idle)
        }
    }
    
    func shieldPressed() {
        
        if !isAttacking && !isShielding {
            isShielding = true
            AudioManager.shared.playShieldSound()
            runAnimation(.shield)
        }
    }
    
    func shieldReleased() {
        if isShielding {
            isShielding = false
            runAnimation(.idle)
        }
    }
    
    
    private func createAttackHitbox(damage: Int, attackType: AttackType) {
        
        let hitboxNode = SKNode()
        hitboxNode.name = "playerAttack"
        
        var hitboxSize: CGSize
        var hitboxOffset: CGFloat
        
        switch attackType {
        case .punch:
            hitboxSize = CGSize(width: size.width * 0.8, height: size.height * 0.8)
            hitboxOffset = size.width * 0.2
        case .kick:
            hitboxSize = CGSize(width: size.width * 1.0, height: size.height * 0.8)
            hitboxOffset = size.width * 0.2
        case .special:
            hitboxSize = CGSize(width: size.width * 1.2, height: size.height)
            hitboxOffset = size.width * 0.8
        }
        
        let xPosition = isFacingRight ? hitboxOffset : -hitboxOffset
        hitboxNode.position = CGPoint(x: xPosition, y: 0)
        
        hitboxNode.userData = NSMutableDictionary()
        hitboxNode.userData?.setValue(damage, forKey: "damage")
        hitboxNode.userData?.setValue(attackType.rawValue, forKey: "attackType")
        
        hitboxNode.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        hitboxNode.physicsBody?.isDynamic = false
        hitboxNode.physicsBody?.allowsRotation = false
        hitboxNode.physicsBody?.categoryBitMask = CollisionCategory.playerAttack
        hitboxNode.physicsBody?.contactTestBitMask = CollisionCategory.enemy
        hitboxNode.physicsBody?.collisionBitMask = CollisionCategory.none
        
        addChild(hitboxNode)
        hitboxNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    func takeDamage(_ amount: Int) {
        
        let actualDamage: Int
        if isShielding {
            
            actualDamage = Int(Double(amount) * 0.3)
            AudioManager.shared.playShieldSound()
        } else {
            actualDamage = amount
        }
        
        health -= actualDamage
        if health < 0 {
            health = 0
        }
        
        if health <= 0 {
            SpriteAnimation.stopAnimation(on: self)
            
            if let deadFrames = animationFrames["dead"],
               let duration = animationDurations["dead"] {
                
                print("Playing player death animation with \(deadFrames.count) frames")
                
                let textureAction = SKAction.animate(with: deadFrames,
                                                     timePerFrame: duration / TimeInterval(deadFrames.count),
                                                     resize: false,
                                                     restore: false)
                
                self.run(textureAction, withKey: "deathAnimation")
            } else {
                print("Failed to find dead animation frames for player")
                self.color = .red
                self.colorBlendFactor = 0.8
            }
            return
        }
        
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
        ])
        run(flashAction)
        
        runAnimation(.hurt)
        
        if self.scene != nil {
            let damageLabel = SKLabelNode(fontNamed: "Arial-Bold")
            damageLabel.text = "-\(actualDamage)"
            damageLabel.fontSize = 32
            damageLabel.fontColor = .red
            damageLabel.position = CGPoint(x: 0, y: size.height/2 + 20)
            damageLabel.zPosition = ZPosition.effect
            self.addChild(damageLabel)
            
            let floatUp = SKAction.moveBy(x: 0, y: 60, duration: 0.8)
            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            let grow = SKAction.scale(to: 1.5, duration: 0.4)
            let shrink = SKAction.scale(to: 1.0, duration: 0.4)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([
                SKAction.group([floatUp, fadeOut, SKAction.sequence([grow, shrink])]),
                remove
            ])
            damageLabel.run(sequence)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if let self = self {
                if self.health <= 0 {
                    return
                }
                
                if self.isShielding {
                    self.runAnimation(.shield)
                } else {
                    self.runAnimation(.idle)
                }
            }
        }
    }
    
    func getHealth() -> Int {
        return health
    }
    
    func getHealthPercentage() -> CGFloat {
        return CGFloat(health) / CGFloat(maxHealth)
    }
    
    func getSpecialMeter() -> Int {
        return specialMeter
    }
    
    func getSpecialMeterPercentage() -> CGFloat {
        return CGFloat(specialMeter) / CGFloat(maxSpecialMeter)
    }
    
    private var canUseSpecial: Bool {
        return specialMeter >= maxSpecialMeter
    }
}
