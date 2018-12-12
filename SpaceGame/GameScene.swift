//
//  GameScene.swift
//  SpaceGame
//
//  Created by Liya Norng on 10/2/18.
//  Copyright © 2018 LiyaNorng. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AudioToolbox
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player:SKSpriteNode!
    private var backGround:SKEmitterNode!
    private var audioNode:SKAudioNode!
    private var readyLabel:SKLabelNode!
    private var alien = ["alien", "alien2" , "alien3", "shuttle", "ufo"]
    private var gun:String = "bullet1"
    private var scoreLabel:SKLabelNode!
    private var skTimer:SKLabelNode!
    private var timeCountDown:TimeInterval = 0
    private var time:TimeInterval = 0
    private var speeds:TimeInterval = 0
    private var spark:SKEmitterNode!
    private var instance = User.instance
    private var rain:SKEmitterNode!
    private var snow:SKEmitterNode!
    private var timeInterVal:TimeInterval!
    

    private var score:Int = 0 {
        didSet {
            self.scoreLabel.text = "Score : \(score)"
            self.upgradeGun()
        }
    }
    
    private var gameTimer:Timer!
    private let alienCategory:UInt32 = 0x1 << 1
    private let photoTorpedoCategory:UInt32 = 0x1 << 0
    private let playerCategory:UInt32 = 0x1 << 2
    private let motionManager = CMMotionManager()
    private var gameStatus = true
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    private var lifeLabel:[SKSpriteNode]!
    private var life:Int = 5
    
    override func didMove(to view: SKView) {
        
        
        let audio = SKAudioNode(fileNamed: "tropicalCyclone.wav")
        self.audioNode = audio
        self.audioNode.run(SKAction.play())
        self.audioNode.autoplayLooped = true
        self.addChild(audio)

      
        self.readyLabel = SKLabelNode(text: " ")
        self.readyLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.readyLabel.fontSize = 20
        self.readyLabel.fontColor = UIColor.green
        self.readyLabel.fontName = "AmericanTypeWriter-Bold"
        self.addChild(self.readyLabel)
 
        
        let place = arc4random_uniform(2) == 0 ? "startField" : "ocean"
        self.backGround = SKEmitterNode(fileNamed: "Starfield")
        
        
        if (place == "startField"){
            self.backGround.position = CGPoint(x: 0, y: self.frame.size.height)
            self.backGround.zPosition = -1
            self.backGround.advanceSimulationTime(10)
            self.addChild(self.backGround)
        }
        else {
            self.scene?.backgroundColor = UIColor(red: 104.0 / 255.0, green: 214.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)

        }
        
        
       
        
        
        self.snow = SKEmitterNode(fileNamed: "Snow")
        self.rain = SKEmitterNode(fileNamed: "Rain")
        
        
        let weather = arc4random_uniform(2) == 0 ? "rain" : "snow"
        
        if weather == "rain"{
            self.rain.position = self.backGround.position
            self.addChild(self.rain)
            self.rain.physicsBody?.collisionBitMask = self.player.shadowedBitMask
        }
        else {
            self.snow.position = self.backGround.position
            self.addChild(self.snow)
            self.snow.physicsBody?.collisionBitMask = self.player.shadowedBitMask
        }
    
        self.lifeLabel = [SKSpriteNode]()
        for i in 1...self.life{
            let lifeNode = SKSpriteNode(imageNamed: "Spaceship")
            lifeNode.position = CGPoint(x: self.frame.size.width - CGFloat(30 * i ), y: self.frame.size.height - 30)
            lifeNode.size = CGSize(width: 30, height: 30)
            self.addChild(lifeNode)
            self.lifeLabel.append(lifeNode)
        }
        
        
        self.player = SKSpriteNode(imageNamed: "Spaceship")
        self.player.size = CGSize(width: 50, height: 50)
        self.player.position = CGPoint(x: self.frame.size.width / 2, y: self.player.size.height / 2 + 10)
        self.player.physicsBody?.isDynamic = true
        self.player.physicsBody = SKPhysicsBody(texture: self.player.texture!, size: self.player.size)
        
        self.player.physicsBody?.contactTestBitMask = alienCategory
        self.player.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(self.player)
        
  
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
    
        self.spark = SKEmitterNode(fileNamed: "MyParticle")
        self.spark.particleSize = CGSize(width: 4, height: 5)
        self.spark.position = CGPoint(x: self.player.position.x - self.spark.particleSize.width , y: self.player.position.y  - self.player.size.height / 2)
        self.spark.particleSize = CGSize(width: 1, height: 3)
        self.addChild(self.spark)
        
        
        self.scoreLabel = SKLabelNode(text: "Score : 0")
        self.scoreLabel.fontColor = UIColor.red
        self.scoreLabel.fontName = "AmericanTypeWriter-Bold"
        self.scoreLabel.position = CGPoint(x: 42, y: self.frame.size.height - 20)
        self.scoreLabel.fontSize = 18
        self.addChild(self.scoreLabel)
        self.readyLabel.text = "Ready In : \(Int(time))"
        
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            if (self.time == 0){
                self.readyLabel.text = "GO"
                self.gameStatus = true
                self.gameTimer.invalidate()
                if (self.instance.getDifficulty() == "Easy"){
                    self.speeds = 0.75
                }
                else if (self.instance.getDifficulty() == "Difficulty"){
                    self.speeds = 0.25
                }
                self.gameTimer = Timer.scheduledTimer(timeInterval: self.speeds, target: self, selector: #selector(self.addAlien), userInfo: nil, repeats: true)
                self.run(SKAction.wait(forDuration: 1)){
                    self.readyLabel.text = " "
                    self.timeCountDown = 100

                    self.skTimer = SKLabelNode(text: String(Int(self.timeCountDown)))
                    self.skTimer.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 40)
                    self.skTimer.fontName = "AmericanTypeWriter-Bold"
                    self.skTimer.fontSize = 20
                    self.skTimer.fontColor = UIColor.green
                    self.addChild(self.skTimer)
                    
                    
                    self.timeInterVal = TimeInterval(self.instance.getGunPower())
                    self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                        
                        if (self.timeCountDown == 0){
                            self.timeInterVal -= 0.001
                            self.instance.addScore(score: String(self.score))
                            self.instance.addLevel()
                            self.instance.setGunPower(gunPower: String(self.timeInterVal))
                            self.gameOver()
                            self.gameTimer.invalidate()
                        }
                        self.skTimer.text = String(Int(self.timeCountDown))
                        self.timeCountDown -= 1
                        
                        })
                }
            }
            else {
                self.readyLabel.text = "Ready In \(Int(self.time))"
                self.gameStatus = false
            }
            self.time -= 1
            })
        
        self.motionManager.accelerometerUpdateInterval = 0.2
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            
            if let accelerometer = data{
                let acceleration = accelerometer.acceleration
                self.xAcceleration =  CGFloat(acceleration.x * 0.75) + self.xAcceleration * 0.25
                self.yAcceleration = CGFloat(acceleration.y * 0.75) + self.yAcceleration * 0.25
            }
        }
    }
    
    @objc func addAlien()->Void{
        
        let possibleAlien = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.alien)
        let newAlien = SKSpriteNode(imageNamed: possibleAlien[0] as! String)

        let randomPosition = GKRandomDistribution(lowestValue: (Int(0 + newAlien.size.width / 2)), highestValue: Int(self.frame.size.width - newAlien.size.width / 2))
        let position = CGFloat(randomPosition.nextInt())
        newAlien.position = CGPoint(x: position, y: self.frame.size.height)
        newAlien.size = CGSize(width: 30, height: 30)
        
        newAlien.physicsBody?.categoryBitMask = alienCategory
        newAlien.physicsBody?.contactTestBitMask = photoTorpedoCategory
        newAlien.physicsBody?.collisionBitMask = 0
        
        newAlien.physicsBody?.isDynamic = true
        if (possibleAlien[0] as! String == "shuttle"){
            newAlien.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            newAlien.zRotation = CGFloat(Double.pi)
        }
        newAlien.physicsBody = SKPhysicsBody(texture: newAlien.texture!, size: newAlien.size)
        self.addChild(newAlien)

        var animationDuration:TimeInterval = 0
        if (self.instance.getDifficulty() == "difficulty"){
            animationDuration = 3
        }
        else {
             animationDuration = 8
        }
        
        
        var skAction = [SKAction]()
        
        skAction.append(SKAction.move(to: CGPoint(x: position, y: -newAlien.size.height), duration: animationDuration))
        skAction.append(SKAction.removeFromParent())
        
        newAlien.run(SKAction.sequence(skAction))
    }
    
    func upgradeGun()->Void{
        if self.score > 0  && self.score <= 10{
            self.gun = "bullet1"
        }
        else if self.score > 11  && self.score <= 20{
            self.gun = "bullet2"
        }
        else if self.score > 21  && self.score <= 30{
            self.gun = "bullet3"
        }
        else if self.score > 31  && self.score <= 40{
            self.gun = "bullet4"
        }
        else if self.score > 41  && self.score <= 50{
            self.gun = "bullet5"
        }
        else if self.score > 51  && self.score <= 60{
            self.gun = "bullet6"
        }
        else if self.score > 61  && self.score <= 70{
            self.gun = "bullet7"
        }
        else if self.score > 71  && self.score <= 80{
            self.gun = "bullet8"
        }
        else if self.score > 81  && self.score <= 90{
            self.gun = "bullet9"
        }
        else if self.score > 91  && self.score <= 100{
            self.gun = "bullet10"
        }
        else if self.score > 101{
            self.gun = "torpedo"
        }
    }
    
    func fireTorpedo()->Void{
        
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        let torpedo = SKSpriteNode(imageNamed: self.gun)
        torpedo.position = self.player.position
        torpedo.position.y += self.player.size.height + 10
        torpedo.zRotation = CGFloat(Double.pi / 2)
        
        torpedo.physicsBody = SKPhysicsBody(rectangleOf: torpedo.size)
        torpedo.physicsBody?.isDynamic = true
        
        torpedo.physicsBody?.categoryBitMask = photoTorpedoCategory
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(torpedo)

        var sequenceArray = [SKAction]()
        
        sequenceArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 0.5 ), duration: timeInterVal))
        sequenceArray.append(SKAction.removeFromParent())
        
        torpedo.run(SKAction.sequence(sequenceArray))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    
        if self.gameStatus {
            if self.player.intersects(contact.bodyA.node as! SKSpriteNode) && contact.bodyA.node != self.player {
                self.crash(spaceShipNode: self.player, alienNode: contact.bodyA.node as! SKSpriteNode)
            }
            else if self.player.intersects(contact.bodyB.node as! SKSpriteNode) && contact.bodyB.node != self.player {
                self.crash(spaceShipNode: self.player, alienNode: contact.bodyB.node as! SKSpriteNode)
            }
            else{
                var firstBody:SKPhysicsBody
                var secondBody:SKPhysicsBody
                
                if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
                    firstBody = contact.bodyA
                    secondBody = contact.bodyB
                }
                else {
                    firstBody = contact.bodyB
                    secondBody = contact.bodyA
                }
                
                if (firstBody.categoryBitMask & photoTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 && firstBody.node != self.player && secondBody.node != self.player{
                    
                    self.collision(alienNode: firstBody.node as! SKSpriteNode, photonNode: secondBody.node as! SKSpriteNode)
                }
            }
        }
    }
    
    func crash(spaceShipNode:SKSpriteNode, alienNode:SKSpriteNode)->Void{
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.particleSize = CGSize(width: 30, height: 30)
        explosion.position = self.player.position
        self.addChild(explosion)
        alienNode.removeFromParent()
        alienNode.removeAllActions()
        self.player.physicsBody?.contactTestBitMask = 3
        self.player.isHidden = true
        self.spark.isHidden = true
        self.gameStatus = false
        self.player.physicsBody?.isDynamic = false
     
        if self.lifeLabel.count > 0{
            let lifeNode = self.lifeLabel.removeLast()
            lifeNode.removeFromParent()
            self.score -= 2
        }
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
            self.player.isHidden = false
            self.spark.isHidden = false
            self.player.position = CGPoint(x: self.frame.size.width / 2, y: self.player.size.height / 2 + 10)
            self.spark.position = CGPoint(x: self.player.position.x - self.spark.particleSize.width , y: self.player.position.y  - self.player.size.height / 2)
            
        }
        
        self.run(SKAction.wait(forDuration: 3)){
          
            self.time = 3
            self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if (self.time == 0){
                    self.readyLabel.text = "GO"
                   
                    self.gameStatus = true
                    self.player.physicsBody?.isDynamic = true
                    self.gameTimer.invalidate()
                    self.player.zRotation = CGFloat(0)
                   
                    self.run(SKAction.wait(forDuration: 0.5)){
                        self.readyLabel.text = " "
                        self.player.physicsBody?.contactTestBitMask = self.alienCategory
                    }
                }
                else {
                    self.readyLabel.text = "Ready In : \(Int(self.time))"
                    self.gameStatus = false
                }
                self.time -= 1
            })
        }
        
        if self.lifeLabel.count == 0{
            self.gameOver()
            
        }
    }
    
    func gameOver()->Void{
        self.gameStatus = false
        self.player.removeFromParent()
        self.audioNode.autoplayLooped = false
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        let menuScene = GameScene(fileNamed: "MenuScene")
        self.view?.presentScene(menuScene!, transition: transition)
    }

    func collision(alienNode:SKSpriteNode, photonNode:SKSpriteNode)->Void{
        
        self.run(SKAction.playSoundFileNamed("bigExplosion.mp3", waitForCompletion: false))
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = photonNode.position
        explosion.particleSize = CGSize(width: 20, height: 20)
        self.addChild(explosion)
        alienNode.removeFromParent()
        photonNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        self.score += 1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.gameStatus{
            self.fireTorpedo()
        }
    }
    
    override func didSimulatePhysics() {
       
        self.player.position.x += self.xAcceleration * 5
        self.player.position.y += self.yAcceleration * 5
        self.spark.position.x += self.xAcceleration * 5
        self.spark.position.y += self.yAcceleration * 5

        if (yAcceleration > 0){
            self.spark.particleLifetime = 1
        }
        else if (yAcceleration <= 0){
            self.spark.particleLifetime = 0.25
        }
        
       // let angle = sqrt ( abs(pow(self.player.position.x, self.player.position.x)) + abs(pow(self.player.position.y, self.player.position.y)))
        
        if (self.player.position.x < 0 + self.player.size.width / 2){
            self.player.position.x = self.player.size.width / 2
            self.spark.position.x = self.player.position.x - self.spark.particleSize.width
            self.xAcceleration = 0
            
            
        }
        else if (self.player.position.x > self.frame.size.width - self.player.size.width / 2){
            self.player.position.x = self.frame.size.width - self.player.size.width / 2
            self.spark.position.x = self.player.position.x - self.spark.particleSize.width
            self.xAcceleration = 0
        }
        
        
        if (self.player.position.y < 0 + self.player.size.height / 2){
            self.player.position.y = self.player.size.height / 2
            self.spark.position.y = self.player.position.y  - self.player.size.height / 2
            self.xAcceleration = 0
        }
        else if (self.player.position.y > self.frame.size.height - self.player.size.height / 2){
            self.player.position.y = self.frame.size.height - self.player.size.height / 2
            self.spark.position.y = self.player.position.y  - self.player.size.height / 2
            self.xAcceleration = 0
        }
       // self.player.zRotation = angle
        
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
