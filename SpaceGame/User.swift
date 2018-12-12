//
//  User.swift
//  SpaceGame
//
//  Created by Liya Norng on 10/4/18.
//  Copyright © 2018 LiyaNorng. All rights reserved.
//

import Foundation

class User:NSObject{
    
    static var instance = User()
    private var userName:String = "Avatar"
    private var level:Int = 1
    private var difficulty:String = "Easy"
    private var score:[String] = [String]()
    private var gunPower:String = "1.5"
    
    override init(){

    }
    
    func setGunPower(gunPower:String)->Void{
        self.gunPower = gunPower
    }
    
    func getGunPower()->String{
        return self.gunPower
    }
    
    func getUserName()->String{
        return self.userName
    }
    
    func getLevel()->Int{
        return self.level
    }
    
    func addLevel()->Void{
        self.level += 1
    }
    
    func getDifficulty()->String{
        return self.difficulty
    }
    
    func setDifficulty(difficulty:String)->Void{
        self.difficulty = difficulty
    }
    
    func addScore(score:String)->Void{
        self.score.append(score)
    }

}


