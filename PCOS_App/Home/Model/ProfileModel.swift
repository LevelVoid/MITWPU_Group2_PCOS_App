//
//  ProfileModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import Foundation

struct ProfileModel: Codable{
    var name: String
    var dob: Date
    var height: Int
    var weight: Int
    var dietType: String
    var workoutType: String
    var pcosPhenotype: String
}
