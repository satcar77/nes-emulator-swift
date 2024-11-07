//
//  viewport.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 10/27/24.
//

import Foundation


public class Viewport {
    var x1 : Int
    var y1 : Int
    var x2 : Int
    var y2 : Int
    
    public init(x1 : Int, y1 : Int , x2 : Int, y2 : Int){
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }
}
