//
//  CustomLineAnchor.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 16.05.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import ARKit
import Foundation

/**
 This class defines the anchor model which is being used in order to trigger
 the creation of a new stroke or a stroke segment which are represented by [CustomNode](x-source-tag://CustomNodeProtocol) objects.
 - It defines all the neccessary properties such as source and destination point of a stroke segment as well as the pencil settings.
 - It implements methods for serialization and deserialization to make sure that objects of this class can be send to connected peers via [MultipeerSessions](https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience)
 */
/// - Tag: CustomLineAnchor
class CustomLineAnchor: ARAnchor {
    
    var sourcePoint: SCNVector3?
    var destinationPoint: SCNVector3?
    var color: UIColor?
    var id: NSString?
    var type: PencilSettings.PencilType?
    var strokeWidth: Float?
    
    enum CodingKeys: String {
        case sourcePoint = "sourcePoint"
        case destinationPoint = "destinationPoint"
        case color = "color"
        case id = "id"
        case type = "type"
        case strokeWidth = "strokeWidth"
    }
    
    required init(anchor: ARAnchor) {
        super.init(anchor: anchor)
        
        guard let customLineAnchor = anchor as? CustomLineAnchor else { return }
        self.color = customLineAnchor.color
        self.sourcePoint = customLineAnchor.sourcePoint
        self.destinationPoint = customLineAnchor.destinationPoint
        self.id = customLineAnchor.id
        self.type = customLineAnchor.type
        self.strokeWidth = customLineAnchor.strokeWidth
    }
    
    init(name: String, transform: simd_float4x4, sourcePoint: SCNVector3?, destinationPoint: SCNVector3, color: UIColor, id: NSString, type: PencilSettings.PencilType = .pencil, strokeWidth: Float) {
        super.init(name: name, transform: transform)
        self.sourcePoint = sourcePoint
        self.destinationPoint = destinationPoint
        self.color = color
        self.id = id
        self.type = type
        self.strokeWidth = strokeWidth
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    // Deserialize CustomLineAnchor
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let sourcePoint: Point = aDecoder.decodeObject(of: Point.self, forKey: CodingKeys.sourcePoint.rawValue) {
          self.sourcePoint = SCNVector3.init(x: sourcePoint.x, y: sourcePoint.y, z: sourcePoint.z)
        }
        
        if let destinationPoint: Point = aDecoder.decodeObject(of: Point.self, forKey: CodingKeys.destinationPoint.rawValue) {
          self.destinationPoint = SCNVector3(destinationPoint.x, destinationPoint.y, destinationPoint.z)
        }
        
        if let color: UIColor = aDecoder.decodeObject(of: UIColor.self, forKey: CodingKeys.color.rawValue) {
            self.color = color
        }
        
        if let id: NSString = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.id.rawValue) {
            self.id = id
        }
    
        let typeRaw: Int = aDecoder.decodeInteger(forKey: CodingKeys.type.rawValue)
        self.type = PencilSettings.PencilType(rawValue: typeRaw) ?? PencilSettings.PencilType.pencil
        
        self.strokeWidth = aDecoder.decodeFloat(forKey: CodingKeys.strokeWidth.rawValue)
    }
    
    // Serialize CustomLineAnchor
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        if let sourcePoint = sourcePoint {
            aCoder.encode(Point(x: sourcePoint.x, y: sourcePoint.y, z: sourcePoint.z), forKey: CodingKeys.sourcePoint.rawValue)
        }
        
        if let destinationPoint = destinationPoint {
             aCoder.encode(Point(x: destinationPoint.x, y: destinationPoint.y, z: destinationPoint.z), forKey: CodingKeys.destinationPoint.rawValue)
        }
        
        if let color = color {
            aCoder.encode(color, forKey: CodingKeys.color.rawValue)
        }
        
        if let id = id {
            aCoder.encode(id, forKey: CodingKeys.id.rawValue)
        }
        
        if let type = type?.rawValue {
            aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        }
        
        if let strokeWidth = strokeWidth {
            aCoder.encode(strokeWidth, forKey: CodingKeys.strokeWidth.rawValue)
        }
    }
}
