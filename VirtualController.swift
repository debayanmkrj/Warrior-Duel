//
//  VirtualController.swift
//  WarriorDuel
//
//  Created by Student on 4/17/25.
//

import SpriteKit

class VirtualController: SKNode {
    
    private var joystickBackground: SKShapeNode!
    private var joystickKnob: SKShapeNode!
    private var knobRadius: CGFloat = 30.0
    private var isJoystickActive = false
    private var initialKnobPosition = CGPoint.zero
    private var shieldButton: SKShapeNode!
    private var shieldHandler: (() -> Void)?
    
    private var punchButton: SKShapeNode!
    private var kickButton: SKShapeNode!
    private var specialButton: SKShapeNode!
    
    private var joystickHandler: ((CGPoint) -> Void)?
    private var punchHandler: (() -> Void)?
    private var kickHandler: (() -> Void)?
    private var specialHandler: (() -> Void)?
    private var isShieldButtonPressed = false
    
    init(sceneSize: CGSize) {
        super.init()
        
        setupJoystick(sceneSize: sceneSize)
        setupButtons(sceneSize: sceneSize)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupJoystick(sceneSize: CGSize) {
        
        let joystickPosition = CGPoint(x: sceneSize.width * 0.15, y: sceneSize.height * 0.2)
        
        joystickBackground = SKShapeNode(circleOfRadius: knobRadius * 1.5)
        joystickBackground.position = joystickPosition
        joystickBackground.fillColor = .darkGray
        joystickBackground.strokeColor = .lightGray
        joystickBackground.alpha = 0.7
        joystickBackground.zPosition = ZPosition.control
        addChild(joystickBackground)
        
        joystickKnob = SKShapeNode(circleOfRadius: knobRadius)
        joystickKnob.position = joystickPosition
        joystickKnob.fillColor = .gray
        joystickKnob.strokeColor = .white
        joystickKnob.alpha = 0.9
        joystickKnob.zPosition = ZPosition.control + 1
        addChild(joystickKnob)
        
        initialKnobPosition = joystickPosition
    }
    
    private func setupButtons(sceneSize: CGSize) {
        let buttonRadius: CGFloat = 40.0
        let buttonY = sceneSize.height * 0.2
        
        punchButton = createButton(
            radius: buttonRadius,
            position: CGPoint(x: sceneSize.width * 0.8, y: buttonY),
            color: .red,
            label: "ATTACK 1"
        )
        punchButton.name = "punchButton"
        addChild(punchButton)
        
        kickButton = createButton(
            radius: buttonRadius,
            position: CGPoint(x: sceneSize.width * 0.9, y: buttonY),
            color: .blue,
            label: "ATTACK 2"
        )
        kickButton.name = "kickButton"
        addChild(kickButton)
        
        shieldButton = createButton(
            radius: buttonRadius,
            position: CGPoint(x: sceneSize.width * 0.7, y: buttonY),
            color: .green,
            label: "SHIELD"
        )
        shieldButton.name = "shieldButton"
        addChild(shieldButton)
        
        specialButton = createButton(
            radius: buttonRadius,
            position: CGPoint(x: sceneSize.width * 0.85, y: buttonY + buttonRadius * 2.5),
            color: .purple,
            label: "SPECIAL"
        )
        specialButton.name = "specialButton"
        addChild(specialButton)
    }
    
    private func createButton(radius: CGFloat, position: CGPoint, color: UIColor, label: String) -> SKShapeNode {
        let button = SKShapeNode(circleOfRadius: radius)
        button.position = position
        button.fillColor = color
        button.strokeColor = .white
        button.lineWidth = 2.0
        button.alpha = 0.7
        button.zPosition = ZPosition.control
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-Bold")
        buttonLabel.text = label
        buttonLabel.fontSize = 14
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.zPosition = ZPosition.control + 1
        button.addChild(buttonLabel)
        
        return button
    }
    
    func setJoystickHandler(_ handler: @escaping (CGPoint) -> Void) {
        joystickHandler = handler
    }
    
    func setPunchHandler(_ handler: @escaping () -> Void) {
        punchHandler = handler
    }
    
    func setKickHandler(_ handler: @escaping () -> Void) {
        kickHandler = handler
    }
    
    func setSpecialHandler(_ handler: @escaping () -> Void) {
        specialHandler = handler
    }
    func setShieldHandler(_ handler: @escaping () -> Void) {
        shieldHandler = handler
    }
    
    private func animateButtonPress(_ button: SKNode) {
        button.run(SKAction.sequence([
            SKAction.scale(to: 0.8, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if joystickBackground.contains(location) {
                isJoystickActive = true
                updateJoystickPosition(location)
            }
            if punchButton.contains(location) {
                animateButtonPress(punchButton)
                punchHandler?()
            } else if kickButton.contains(location) {
                animateButtonPress(kickButton)
                kickHandler?()
            } else if specialButton.contains(location) {
                animateButtonPress(specialButton)
                specialHandler?()
            } else if shieldButton.contains(location) {
                isShieldButtonPressed = true
                animateButtonPress(shieldButton)
                shieldHandler?()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if isJoystickActive {
                updateJoystickPosition(location)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if isShieldButtonPressed && shieldButton.contains(location) {
                isShieldButtonPressed = false
               
                if let player = (scene as? GameScene)?.player {
                    player.shieldReleased()
                }
            }
        }
        
        resetJoystick()
        isShieldButtonPressed = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetJoystick()
        isShieldButtonPressed = false

        if let player = (scene as? GameScene)?.player {
            player.shieldReleased()
        }
    }
    
    private func updateJoystickPosition(_ touchLocation: CGPoint) {
 
        let direction = CGPoint(
            x: touchLocation.x - initialKnobPosition.x,
            y: touchLocation.y - initialKnobPosition.y
        )
        
        let distance = sqrt(direction.x * direction.x + direction.y * direction.y)
        
        let maxDistance = knobRadius * 1.5
        
        if distance < maxDistance {

            joystickKnob.position = touchLocation
        } else {
            
            let normalizedDirection = CGPoint(
                x: direction.x / distance,
                y: direction.y / distance
            )
            
            joystickKnob.position = CGPoint(
                x: initialKnobPosition.x + normalizedDirection.x * maxDistance,
                y: initialKnobPosition.y + normalizedDirection.y * maxDistance
            )
        }
        
        let movement: CGPoint
        if distance > 0 {

            let normalizedDistance = min(distance, maxDistance) / maxDistance
            movement = CGPoint(
                x: direction.x / distance * normalizedDistance,
                y: 0
            )
        } else {
            movement = CGPoint.zero
        }
        
        joystickHandler?(movement)
        print("Joystick movement: \(movement.x), \(movement.y)")
    }
    
    private func resetJoystick() {
        isJoystickActive = false
        
        let moveAction = SKAction.move(to: initialKnobPosition, duration: 0.1)
        joystickKnob.run(moveAction)
        
        joystickHandler?(CGPoint.zero)
    }
}
