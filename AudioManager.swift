//
//  AudioManager.swift
//  WarriorDuel
//
//  Created by Student on 4/26/25.
//

import AVFoundation

class AudioManager {
    
    static let shared = AudioManager()
    private var musicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [URL: AVAudioPlayer] = [:]
    private var musicVolume: Float = 0.5
    private var sfxVolume: Float = 1.0
    private var isMusicEnabled = true
    private var isSfxEnabled = true
    private var currentMusicTrack: String?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    
    func playBackgroundMusic(filename: String) {
        if currentMusicTrack == filename && musicPlayer?.isPlaying == true {
            return
        }
        
        stopBackgroundMusic()
        
        currentMusicTrack = filename
        
        guard isMusicEnabled else { return }
        
        if let path = Bundle.main.path(forResource: filename, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.numberOfLoops = -1
                musicPlayer?.volume = musicVolume
                musicPlayer?.prepareToPlay()
                musicPlayer?.play()
            } catch {
                print("Failed to play background music: \(error.localizedDescription)")
            }
        } else {
            print("Music file not found: \(filename)")
        }
    }
    
    func stopBackgroundMusic() {
        musicPlayer?.stop()
        currentMusicTrack = nil
    }
    
    func pauseBackgroundMusic() {
        musicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        if isMusicEnabled {
            musicPlayer?.play()
        }
    }
    
    func playSoundEffect(filename: String, volume: Float? = nil) {
        guard isSfxEnabled else { return }
        
        if let path = Bundle.main.path(forResource: filename, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            if let player = soundEffectPlayers[url], !player.isPlaying {
                player.volume = volume ?? sfxVolume
                player.currentTime = 0
                player.play()
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = volume ?? sfxVolume
                player.prepareToPlay()
                player.play()
                
                if soundEffectPlayers.count > 10 {
                    soundEffectPlayers.removeValue(forKey: soundEffectPlayers.keys.first!)
                }
                soundEffectPlayers[url] = player
            } catch {
                print("Failed to play sound effect: \(error.localizedDescription)")
            }
        } else {
            print("Sound effect file not found: \(filename)")
        }
    }
    
    
    func setMusicVolume(volume: Float) {
        musicVolume = max(0.0, min(1.0, volume))
        musicPlayer?.volume = musicVolume
    }
    
    
    func setSfxVolume(volume: Float) {
        sfxVolume = max(0.0, min(1.0, volume))
    }
    
    func enableMusic(_ enabled: Bool) {
        isMusicEnabled = enabled
        if enabled {
            resumeBackgroundMusic()
        } else {
            pauseBackgroundMusic()
        }
    }
    
    func enableSfx(_ enabled: Bool) {
        isSfxEnabled = enabled
    }
    
    func playMainMenuMusic() {
        playBackgroundMusic(filename: "Gamemusic.mp3")
    }
    
    func playGameLevelMusic() {
        playBackgroundMusic(filename: "Gamemusic.mp3")
    }
    
    
    func playAttackSound(attackType: Int) {
        switch attackType {
        case 1:
            playSoundEffect(filename: "Attack.wav")
        case 2:
            playSoundEffect(filename: "Attack2.wav")
        case 3:
            playSoundEffect(filename: "Attack3.wav")
        default:
            playSoundEffect(filename: "Attack.wav")
        }
    }
    
    
    func playShieldSound() {
        playSoundEffect(filename: "Shield.wav")
    }
    
    
    func playFootstepSound() {
        playSoundEffect(filename: "Footstep.wav", volume: 0.3)
    }
    
    
    func playLevelChangeSound() {
        playSoundEffect(filename: "LevelChange.wav")
    }
    
    
    func playButtonSelectSound() {
        playSoundEffect(filename: "Buttonselect.wav")
    }
    
    
    func playTimeOverSound() {
        playSoundEffect(filename: "Timeover.wav")
    }
    
    
    func playPlayerVictorySound() {
        playSoundEffect(filename: "Playerwin.wav")
    }
    
    
    func playPlayerDefeatSound() {
        playSoundEffect(filename: "Playerdefeat.wav")
    }
    
    
    func playEnemyAttackSound(attackType: Int) {
        switch attackType {
        case 1:
            playSoundEffect(filename: "Enemyattack.wav")
        case 2:
            playSoundEffect(filename: "Enemyattack2.wav")
        case 3:
            playSoundEffect(filename: "Enemyattack3.wav")
        default:
            playSoundEffect(filename: "Enemyattack.wav")
        }
    }
    
    func playEnemySpecialAttackSound() {
        playSoundEffect(filename: "Enemyspecialattack.wav")
    }
}
