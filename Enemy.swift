//
//  Enemy.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class Enemy: SKSpriteNode {
    private var enemyType: EnemyType
    private var level: Int
    private var health: Int = 100
    private var maxHealth: Int = 100
    internal var specialMeter: Int = 0
    internal var maxSpecialMeter: Int = 30
    private var attackPower: Int = 8
    private var specialAttackPower: Int = 25
    private var isShielding = false
    private var runSpeedMultiplier: CGFloat = 2.0
    private var walkToRunDelay: TimeInterval = 1.0
    private var walkStartTime: TimeInterval = 0.0
    private let damageMultiplier: Double
    private var attackCooldown: TimeInterval = 2.0
    private var lastAttackTime: TimeInterval = 0.0
    private var moveCooldown: TimeInterval = 1.5
    private var lastMoveTime: TimeInterval = 0.0
    private var bloodChargeEffect: SKSpriteNode?
    var isAttacking = false
    var isMoving = false
    var isFacingLeft = true
    
    private var frameCounts: [String: Int] = [:]
    private var animationFrames: [String: [SKTexture]] = [:]
    
    init(enemyType: EnemyType, level: Int) {
        self.enemyType = enemyType
        self.level = level
        
        switch level {
        case 1:
            damageMultiplier = 0.85 // 85% of player damage
        case 2:
            damageMultiplier = 0.95 // 95% of player damage
        case 3:
            damageMultiplier = 1.15 // 115% of player damage
        default:
            damageMultiplier = 0.85
        }
        
        maxHealth = 100 + ((level - 1) * 25)
        health = maxHealth
        attackPower = Int(Double(8) * damageMultiplier) + ((level - 1) * 2)
        specialAttackPower = Int(Double(25) * damageMultiplier) + ((level - 1) * 5)
        
        attackCooldown = 2.0 - (Double(level - 1) * 0.3)
        moveCooldown = 0.2
        
        
        let texture = SKTexture(imageNamed: "\(enemyType.rawValue)_Idle")
        let desiredWidth: CGFloat = 250
        let desiredHeight: CGFloat = 250
        let scaledSize = CGSize(width: desiredWidth, height: desiredHeight)
        super.init(texture: texture, color: .clear, size: scaledSize)
        
        setupFrameCounts()
        
        self.isFacingLeft = true
        self.xScale = -abs(self.xScale)
        
        
        self.name = "enemy"
        self.zPosition = ZPosition.character
        
        
        loadAnimationFrames()
        setupPhysics()
        runAnimation(.idle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFrameCounts() {
        switch enemyType {
        case .convertedVampire:
            
            frameCounts = [
                "idle": 5,
                "walk": 8,
                "run": 8,
                "attack1": 5,
                "attack2": 3,
                "attack3": 4,
                "hurt": 1,
                "dead": 8,
                "shield": 2
            ]
        case .vampireGirl:
            
            frameCounts = [
                "idle": 5,
                "walk": 6,
                "run": 6,
                "attack1": 5,
                "attack2": 4,
                "attack3": 5,
                "hurt": 2,
                "dead": 10,
                "shield": 2
            ]
        case .countessVampire:
            
            frameCounts = [
                "idle": 5,
                "walk": 6,
                "run": 6,
                "attack1": 6,
                "attack2": 3,
                "attack3": 6,
                "hurt": 2,
                "dead": 8,
                "shield": 1
            ]
        }
    }
    
    private let animationDurations: [String: TimeInterval] = [
        "idle": 0.3,
        "walk": 0.8,
        "run": 0.6,
        "attack1": 0.4,
        "attack2": 0.4,
        "attack3": 0.7,
        "hurt": 0.4,
        "dead": 0.6,
    ]
    
    
    private func setupPhysics() {
        
        let bodySize = CGSize(width: size.width * 0.7, height: size.height * 0.9)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        
        physicsBody?.categoryBitMask = CollisionCategory.enemy
        physicsBody?.contactTestBitMask = CollisionCategory.player | CollisionCategory.playerAttack
        physicsBody?.collisionBitMask = CollisionCategory.boundary
        
        self.name = "enemy"
        physicsBody?.linearDamping = 3.0
        physicsBody?.friction = 0.2
    }
    
    
    private func loadAnimationFrames() {
        animationFrames.removeAll()
        
        for (animType, frameCount) in frameCounts {
            if frameCount == 0 {
                continue
            }
            
            let actionName = convertAnimTypeToFileName(animType)
            print("Loading animation for \(enemyType.rawValue)_\(actionName) with \(frameCount) frames")
            let frames = SpriteAnimation.createAnimationFrames(
                for: enemyType.rawValue,
                action: actionName,
                frameCount: frameCount
            )
            
            if frames.isEmpty {
                print("Warning: No frames loaded for \(enemyType.rawValue)_\(actionName)")
            } else {
                print("Loaded \(frames.count) frames for \(enemyType.rawValue)_\(actionName)")
            }
            
            animationFrames[animType] = frames
        }
        
        print("Completed animation loading for \(enemyType.rawValue)")
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
        case "hit":
            return "Hit"
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
    
    
    func update(currentTime: TimeInterval, playerPosition: CGPoint) {
        
        if isAttacking || isShielding {
            return
        }
        
        let distanceToPlayer = abs(position.x - playerPosition.x)
        
        if playerPosition.x < position.x && !isFacingLeft {
            isFacingLeft = true
            xScale = -abs(xScale)
        } else if playerPosition.x > position.x && isFacingLeft {
            isFacingLeft = false
            xScale = abs(xScale)
        }
        
        if distanceToPlayer < 100 && currentTime - lastAttackTime > attackCooldown {
            
            let playerIsAttacking = (scene as? GameScene)?.player.isAttacking ?? false
            
            if playerIsAttacking && !isShielding {
                
                applyShield()
                lastAttackTime = currentTime
                isMoving = false
                walkStartTime = 0
                return
            } else if !playerIsAttacking && !isShielding {
                
                performAttack(currentTime: currentTime, attackType: .punch)
                isMoving = false
                walkStartTime = 0
                return
            }
        } else if specialMeter >= maxSpecialMeter && currentTime - lastAttackTime > attackCooldown {
            
            performAttack(currentTime: currentTime, attackType: .special)
            isMoving = false
            walkStartTime = 0
            return
        }
        
        
        if !isAttacking && !isShielding && currentTime - lastMoveTime > moveCooldown {
            moveTowardsPlayer(playerPosition: playerPosition, currentTime: currentTime)
        }
    }
    
    
    private func performAttack(currentTime: TimeInterval, attackType: AttackType? = nil) {
        lastAttackTime = currentTime
        isAttacking = true
        
        if isShielding {
            isShielding = false
        }
        
        let attack: AttackType
        var damage: Int
        
        if let attackType = attackType {
            attack = attackType
        } else if specialMeter >= maxSpecialMeter && Int.random(in: 1...5) == 1 {
            attack = .special
        } else {
            attack = Bool.random() ? .punch : .kick
        }
        
        switch attack {
        case .special:
            if enemyType == .countessVampire {
                damage = Int(Double(specialAttackPower) * 2.0)
                specialMeter = 0
                AudioManager.shared.playEnemySpecialAttackSound()
                runAnimation(.attack3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.addBloodChargeEffect()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.createAttackHitbox(damage: damage, attackType: attack)
                }
                
                let animationDuration = animationDurations[getAnimationKey(for: .attack3)] ?? 0.7
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
                    self?.isAttacking = false
                    self?.runAnimation(.idle)
                }
                return
            } else {
                damage = Int(Double(specialAttackPower) * 1.5)
                specialMeter = 0
                AudioManager.shared.playEnemySpecialAttackSound()
                runAnimation(.attack3)
            }
        case .kick:
            damage = attackPower + 3
            AudioManager.shared.playEnemyAttackSound(attackType: 2)
            runAnimation(.attack2)
        case .punch:
            damage = attackPower
            AudioManager.shared.playEnemyAttackSound(attackType: 1)
            runAnimation(.attack1)
        }
        
        createAttackHitbox(damage: damage, attackType: attack)
        
        let animationDuration = animationDurations[getAnimationKey(for: self.getCurrentAnimationType())] ?? 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.isAttacking = false
            self?.runAnimation(.idle)
        }
    }
    
    private func addBloodChargeEffect() {
        bloodChargeEffect?.removeFromParent()
        let effect = SKSpriteNode(imageNamed: "Blood_charge_1")
        bloodChargeEffect = effect
        let handOffsetX: CGFloat = isFacingLeft ? -size.width * 0.4 : size.width * 0.4
        let handOffsetY: CGFloat = 0
        
        effect.position = CGPoint(x: handOffsetX, y: handOffsetY)
        effect.zPosition = self.zPosition + 1
        effect.setScale(1.5)
        
        if isFacingLeft {
            effect.xScale = -effect.xScale
        }
        
        self.parent?.addChild(effect)
        
        let textures = [
            SKTexture(imageNamed: "Blood_charge_1"),
            SKTexture(imageNamed: "Blood_charge_2"),
            SKTexture(imageNamed: "Blood_charge_3")
        ]
        
        let animateAction = SKAction.animate(with: textures, timePerFrame: 0.15)
        let repeatAction = SKAction.repeat(animateAction, count: 2)
        let removeAction = SKAction.removeFromParent()
        
        effect.run(SKAction.sequence([repeatAction, removeAction]))
    }
    
    func applyShield() {
        if isAttacking || isShielding {
            return
        }
        
        isShielding = true
        AudioManager.shared.playShieldSound()
        runAnimation(.shield)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.releaseShield()
        }
    }
    
    func releaseShield() {
        if isShielding {
            isShielding = false
            runAnimation(.idle)
        }
    }
    
    func isShieldActive() -> Bool {
        return isShielding
    }
    
    private func getCurrentAnimationType() -> AnimationType {
        if isAttacking {
            return .attack1
        } else if isMoving {
            return .walk
        } else {
            return .idle
        }
    }
    
    private func createAttackHitbox(damage: Int, attackType: AttackType) {
        let hitboxNode = SKNode()
        hitboxNode.name = "enemyAttack"
        
        var hitboxSize: CGSize
        switch attackType {
        case .punch:
            hitboxSize = CGSize(width: size.width * 0.8, height: size.height * 0.8)
        case .kick:
            hitboxSize = CGSize(width: size.width * 1.0, height: size.height * 0.8)
        case .special:
            hitboxSize = CGSize(width: size.width * 2.0, height: size.height * 1.0)
        }
        
        hitboxNode.position = CGPoint.zero
        
        hitboxNode.userData = NSMutableDictionary()
        hitboxNode.userData?.setValue(damage, forKey: "damage")
        hitboxNode.userData?.setValue(attackType.rawValue, forKey: "attackType")
        
        let path = CGMutablePath()
        
        let halfWidth = hitboxSize.width / 2
        let halfHeight = hitboxSize.height / 2
        
        let originX = isFacingLeft ? -halfWidth : -halfWidth
        let originY = -halfHeight
        
        path.addRect(CGRect(x: originX, y: originY, width: hitboxSize.width, height: hitboxSize.height))
        
        hitboxNode.physicsBody = SKPhysicsBody(polygonFrom: path)
        hitboxNode.physicsBody?.isDynamic = false
        hitboxNode.physicsBody?.allowsRotation = false
        hitboxNode.physicsBody?.categoryBitMask = CollisionCategory.enemyAttack
        hitboxNode.physicsBody?.contactTestBitMask = CollisionCategory.player
        hitboxNode.physicsBody?.collisionBitMask = CollisionCategory.none
        
        addChild(hitboxNode)
        
        let duration: TimeInterval = attackType == .special ? 0.75 : 0.50
        hitboxNode.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ]))
    }
    
    
    private func moveTowardsPlayer(playerPosition: CGPoint, currentTime: TimeInterval) {
        lastMoveTime = currentTime
        
        if walkStartTime == 0 {
            walkStartTime = currentTime
        }
        
        let directionX = playerPosition.x > position.x ? 1.0 : -1.0
        let distanceToPlayer = abs(position.x - playerPosition.x)
        let minDistanceToPlayer: CGFloat = 100
        
        if distanceToPlayer <= minDistanceToPlayer {
            if isMoving {
                isMoving = false
                walkStartTime = 0
                runAnimation(.idle)
            }
            if currentTime - lastAttackTime > attackCooldown {
                performAttack(currentTime: currentTime, attackType: .punch)
            }
            
            return
        }
        
        isMoving = true
        
        let shouldRun = currentTime - walkStartTime >= walkToRunDelay
        if shouldRun || (Int(currentTime * 10) % 10 == 0) {
            AudioManager.shared.playFootstepSound()
        }
        
        let baseSpeed: CGFloat = 5.0
        let runMultiplier: CGFloat = 2.0
        
        let moveSpeed: CGFloat = shouldRun ? baseSpeed * runMultiplier : baseSpeed
        
        if shouldRun {
            runAnimation(.run)
        } else {
            runAnimation(.walk)
        }
        
        // Move towards player
        let newX = position.x + (directionX * moveSpeed)
        let halfWidth = size.width / 2
        let screenWidth = scene?.size.width ?? 1024
        let boundedX = max(halfWidth, min(screenWidth - halfWidth, newX))
        position = CGPoint(x: boundedX, y: position.y)
    }
    
    func takeDamage(_ amount: Int) {
        
        let wasFacingLeft = isFacingLeft
        let currentXScale = self.xScale
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
            isAttacking = false
            isMoving = false
            SpriteAnimation.stopAnimation(on: self)
            
            if let deadFrames = animationFrames["dead"],
               let duration = animationDurations["dead"] {
                
                print("Playing enemy death animation with \(deadFrames.count) frames")
                
                let deathAction = SKAction.animate(with: deadFrames,
                                                   timePerFrame: duration / TimeInterval(deadFrames.count),
                                                   resize: false,
                                                   restore: false)
                
                self.run(deathAction, withKey: "deathAnimation")
            } else {
                print("Failed to find death animation frames for enemy")
                
            }
            return
        }
        
        self.isFacingLeft = wasFacingLeft
        self.xScale = wasFacingLeft ? -abs(currentXScale) : abs(currentXScale)
        
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.2),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.isFacingLeft = wasFacingLeft
                self.xScale = wasFacingLeft ? -abs(currentXScale) : abs(currentXScale)
            }
        ])
        run(flashAction)
        
        SpriteAnimation.stopAnimation(on: self)
        let animKey = getAnimationKey(for: .hurt)
        if let frames = animationFrames[animKey],
           let duration = animationDurations[animKey] {
            
            let textureAction = SKAction.animate(with: frames, timePerFrame: duration / TimeInterval(frames.count))
            let orientationAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                self.isFacingLeft = wasFacingLeft
                self.xScale = wasFacingLeft ? -abs(currentXScale) : abs(currentXScale)
            }
            
            let animationSequence = SKAction.sequence([
                textureAction,
                orientationAction
            ])
            self.run(animationSequence, withKey: "hurtAnimation")
        }
        
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
            guard let self = self else { return }
            if self.health <= 0 {
                return
            }
            
            self.isFacingLeft = wasFacingLeft
            self.xScale = wasFacingLeft ? -abs(currentXScale) : abs(currentXScale)
            
            if self.isShielding {
                self.runAnimation(.shield)
            } else {
                self.runAnimation(.idle)
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
}
