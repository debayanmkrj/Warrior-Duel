# Warrior-Duel
This game is a side-scrolling fighting game where the user plays as one of three warrior characters battling against vampire enemies across three increasingly difficult levels. In the game, the user selects a character (Fighter, Samurai, or Shinobi) 
Download Sprites from - https://craftpix.net/freebies/free-shinobi-sprites-pixel-art/
https://craftpix.net/freebies/free-vampire-pixel-art-sprite-sheets/?num=1&count=22&sq=vampire&pos=2

A 2D fighting game where warriors battle against vampires across multiple stages.

🎮 Game Overview
Warrior Duel is a side-scrolling combat game developed in Swift using SpriteKit. Players select from three character classes (Fighter, Samurai, or Shinobi) and battle through increasingly difficult vampire enemies across three unique castle environments.
Key Features

Three playable character classes: Fighter, Samurai, and Shinobi
Three unique enemy types: Converted Vampire, Vampire Girl, and Countess Vampire
Multiple combat environments: Castle, Terrace, and Throne Room
Action-packed combat system: Basic attacks, special moves, and shield defense
Special meter: Build up power for devastating special attacks
Time-based battles: Defeat your enemy before time runs out

📱 Technical Details
Requirements

iOS 14.0+
Xcode 12.0+
Swift 5.0+

Project Structure
The game is built using Swift and SpriteKit with a clean architecture:

Core Game Structure

ContentView.swift - SwiftUI container for the game
GameScene.swift - Base game scene with shared functionality
Level1Scene.swift/Level2Scene.swift/Level3Scene.swift - Level-specific scenes
SceneTransitionManager.swift - Handles transitions between game states


Characters & Entities

Player.swift - Player character logic
Enemy.swift - Enemy AI and behavior
GameConstants.swift - Game enumerations and constants


UI & Controls

MainMenuScene.swift - Main menu interface
CharacterSelectScene.swift - Character selection screen
HUD.swift - In-game heads-up display
VirtualController.swift - On-screen controls


Animation & Audio

SpriteAnimation.swift - Animation management system
AudioManager.swift - Sound effects and music system



Game Architecture
The game uses a scene-based architecture with various game states:

Main Menu → Character Select → Level 1 → Level 2 → Level 3

Combat is handled through a physics-based collision system with custom hit detection for attacks and defensive maneuvers.
🎯 Gameplay
Controls
The game features an intuitive virtual control system:

Left joystick: Move character

Hold for running (after walking for 1 second)


Attack buttons:

Attack 1: Basic punch attack
Attack 2: Stronger kick attack
Special: Powerful special move (when meter is full)


Shield button: Defend against enemy attacks (reduces damage by 70%)

Character Types
Each character has unique attributes:

Fighter: Balanced character with medium attack power and defense
Samurai: Stronger attacks but slower movement
Shinobi: Faster attacks and movement but lower defense

Combat Mechanics

Health system: Each character has a health bar that depletes when hit
Special meter: Builds up as you land attacks on enemies
Timed matches: Each battle has a 100-second time limit
Shields: Block attacks to reduce incoming damage
Combat animations: Unique attack, walk, run, and special move animations

🚀 Installation

Clone the repository:

bashgit clone https://github.com/yourusername/WarriorDuel.git

Open WarriorDuel.xcodeproj in Xcode
Build and run on your iOS device or simulator

🎵 Audio
The game features:

Background music for menu and gameplay
Attack sound effects
Shield activation sounds
Footstep sounds
Victory/defeat sounds

🧠 AI Opponents
Enemies feature adaptive AI that:

Attacks when in range
Blocks player attacks
Chases the player across the stage
Uses special attacks when their meter is full
Increases in difficulty across the three game levels
![Warrior_Duel_submission_screengrabs](https://github.com/user-attachments/assets/5bd252a9-7761-4901-bfde-8b9aa9b29659)



🎨 Art Assets
The game uses sprite sheet animations for characters with:

Idle, walk, and run animations
Attack animations
Shield effects
Special attack animations
Death sequences

📝 Future Development
Planned features for future updates:

Additional character classes
More enemy types and boss battles
Multiplayer combat
Character progression system
Additional stages and environments

🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

![Warrior_Duel_Logo](https://github.com/user-attachments/assets/5897ad4b-84d3-46e3-98ed-6bae496b5ec5)
