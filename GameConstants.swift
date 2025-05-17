//
//  GameConstants.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

enum CharacterType: String {
    case fighter = "Fighter"
    case samurai = "Samurai"
    case shinobi = "Shinobi"
}

enum EnemyType: String {
    case convertedVampire = "Converted_Vampire"
    case vampireGirl = "Vampire_Girl"
    case countessVampire = "Countess_Vampire"
}

enum AnimationType: String {
    case idle = "Idle"
    case walk = "Walk"
    case run = "Run"
    case attack1 = "Attack_1"
    case attack2 = "Attack_2"
    case attack3 = "Attack_3"
    case jump = "Jump"
    case dead = "Dead"
    case hurt = "Hurt"
    case shield = "Shield"
}

// Attack types
enum AttackType: String {
    case punch = "punch"
    case kick = "kick"
    case special = "special"
}

struct CollisionCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0
    static let enemy: UInt32 = 0x1 << 1
    static let playerAttack: UInt32 = 0x1 << 2
    static let enemyAttack: UInt32 = 0x1 << 3     
    static let boundary: UInt32 = 0x1 << 4         
    static let all: UInt32 = UInt32.max
}

struct ZPosition {
    static let background: CGFloat = 0
    static let floor: CGFloat = 10
    static let character: CGFloat = 20
    static let effect: CGFloat = 30
    static let hud: CGFloat = 40
    static let control: CGFloat = 50
    static let popup: CGFloat = 60
    static let debug: CGFloat = 100
}
