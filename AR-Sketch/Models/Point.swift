//
//  Point.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 16.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation

/**
This class represents a point in 3D space and us.
  - It implements methods for serialization and deserialization to make sure that objects of this class can be send to connected peers via [MultipeerSessions](https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience)
 */
/// - Tag: Point
class Point: NSObject, NSSecureCoding {
  var x: Float
  var y: Float
  var z: Float
  
  public static var supportsSecureCoding: Bool {
    get {
      return true
    }
  }
  
  public enum CodingKeys: String {
    case x = "x"
    case y = "y"
    case z = "z"
  }
  
  public init(x: Float, y: Float, z: Float) {
    self.x = x
    self.y = y
    self.z = z
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.x = aDecoder.decodeFloat(forKey: CodingKeys.x.rawValue)
    self.y = aDecoder.decodeFloat(forKey: CodingKeys.y.rawValue)
    self.z = aDecoder.decodeFloat(forKey: CodingKeys.z.rawValue)
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.x, forKey: CodingKeys.x.rawValue)
    aCoder.encode(self.y, forKey: CodingKeys.y.rawValue)
    aCoder.encode(self.z, forKey: CodingKeys.z.rawValue)
  }
}

