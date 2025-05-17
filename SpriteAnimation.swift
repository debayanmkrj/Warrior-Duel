//
//  SpriteAnimation.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class SpriteAnimation {
    
    private static var textureCache: [String: [SKTexture]] = [:]
    
    static func createAnimationFrames(for characterType: String, action: String, frameCount: Int) -> [SKTexture] {
        
        let cacheKey = "\(characterType)_\(action)"
        if let cachedFrames = textureCache[cacheKey] {
            return cachedFrames
        }
        
        var frames: [SKTexture] = []
        
        let spriteSheetName = "\(characterType)_\(action)"
        print("Attempting to load sprite sheet: \(spriteSheetName)")
        let spriteSheet = SKTexture(imageNamed: spriteSheetName)
        
        if spriteSheet.size().width > 0 {
            
            print("Successfully loaded sprite sheet: \(spriteSheetName) with size \(spriteSheet.size())")
            
            let frameWidth = 1.0 / CGFloat(frameCount)
            
            for i in 0..<frameCount {
                
                let rect = CGRect(
                    x: CGFloat(i) * frameWidth,
                    y: 0,
                    width: frameWidth,
                    height: 1.0
                )
                
                let frameTexture = SKTexture(rect: rect, in: spriteSheet)
                
                frames.append(frameTexture)
            }
            
            print("Created \(frames.count) frames from sprite sheet: \(spriteSheetName)")
        } else {
            print("Failed to load sprite sheet: \(spriteSheetName), trying alternate names...")
            
            let alternateNames = [
                "\(characterType)\(action)",
                "\(characterType)-\(action)",
                "\(characterType)_\(action.lowercased())",
                "\(characterType.lowercased())_\(action)",
                "\(characterType.lowercased())_\(action.lowercased())"
            ]
            
            var found = false
            for altName in alternateNames {
                print("Trying alternative name: \(altName)")
                let altTexture = SKTexture(imageNamed: altName)
                if altTexture.size().width > 0 {
                    print("Found texture with alternative name: \(altName)")
                    
                    let frameWidth = 1.0 / CGFloat(frameCount)
                    
                    for i in 0..<frameCount {
                        let rect = CGRect(
                            x: CGFloat(i) * frameWidth,
                            y: 0,
                            width: frameWidth,
                            height: 1.0
                        )
                        let frameTexture = SKTexture(rect: rect, in: altTexture)
                        frames.append(frameTexture)
                    }
                    
                    print("Created \(frames.count) frames from alternate sprite sheet: \(altName)")
                    found = true
                    break
                }
            }
            
            if !found {
                print("All attempts failed for loading sprite sheet: \(spriteSheetName)")
            }
        }
        
        textureCache[cacheKey] = frames
        
        return frames
    }
    
    static func runAnimation(on sprite: SKSpriteNode, frames: [SKTexture], duration: TimeInterval, repeating: Bool = true) {
        guard !frames.isEmpty else {
            print("Warning: Trying to run animation with empty frames")
            return
        }
        
        stopAnimation(on: sprite)
        
        print("Running animation with \(frames.count) frames, duration: \(duration), repeating: \(repeating)")
        sprite.texture = frames.first
        
        if frames.count == 1 {
            print("Single frame animation - displaying static frame only")
            return
        }
        
        SKTexture.preload(frames) {
            print("Textures preloaded, starting animation")
            
            let timePerFrame = duration / TimeInterval(max(1, frames.count))
            
            let animateAction = SKAction.animate(with: frames, timePerFrame: timePerFrame)
            
            if repeating {
                print("Setting up repeating animation")
                let repeatAction = SKAction.repeatForever(animateAction)
                sprite.run(repeatAction, withKey: "animation")
            } else {
                print("Setting up non-repeating animation")
                let sequence = SKAction.sequence([
                    animateAction,
                    SKAction.run { [weak sprite] in
                        print("Animation complete, setting final frame")
                        sprite?.texture = frames.last ?? frames.first
                    }
                ])
                sprite.run(sequence, withKey: "animation")
            }
        }
    }
    
    static func stopAnimation(on sprite: SKSpriteNode) {
        sprite.removeAction(forKey: "animation")
    }
}
