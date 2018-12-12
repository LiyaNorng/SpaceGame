//
//  MenuScene.swift
//  SpaceGame
//
//  Created by Liya Norng on 10/4/18.
//  Copyright © 2018 LiyaNorng. All rights reserved.
//

import UIKit
import SpriteKit


class MenuScene: SKScene {
    
    private var gameTitle:SKLabelNode!
    private var difficulty:SKLabelNode!
    private var levelLabel:SKLabelNode!
    private var startGame:SKSpriteNode!
    private var weather:SKEmitterNode!
    private var audioNode:SKAudioNode!
    private var instance = User.instance
    
    
    override func didMove(to view: SKView) {
    
        
        self.audioNode = (self.childNode(withName: "soundNode") as! SKAudioNode)
        self.audioNode.run(SKAction.play())
        self.audioNode.autoplayLooped = true
        self.difficulty = (self.childNode(withName: "difficulty") as! SKLabelNode)
        self.levelLabel = (self.childNode(withName: "levelLabel") as! SKLabelNode)
        self.levelLabel.text = "Level \(self.instance.getLevel())"
        
        
        let conditionweather = arc4random_uniform(2) == 0 ? "snow" : "rain"
        if conditionweather == "snow"{
            self.weather = SKEmitterNode(fileNamed: "Snow")
        }
        else {
            self.weather = SKEmitterNode(fileNamed: "Rain")
        }
        self.weather.advanceSimulationTime(20)
        self.weather.zPosition = -1
        self.addChild(self.weather)
        
        self.startGame = (self.childNode(withName: "startGame") as! SKSpriteNode)
        self.difficulty.text = self.instance.getDifficulty()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let location = touches.first?.location(in: self){
            let nodeArray  = self.nodes(at: location)
            
            if nodeArray.first?.name == "startGame"{
                self.audioNode.autoplayLooped = false
                self.instance.setDifficulty(difficulty: self.difficulty.text!)
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene!, transition: transition)
                
            }
            else if (nodeArray.first?.intersects(self.difficulty))!{
                
                if (self.difficulty.text == "Easy"){
                    self.difficulty.text = "Difficulty"
                }
                else {
                    self.difficulty.text = "Easy"
                }
            }
        }
        
    }
}
