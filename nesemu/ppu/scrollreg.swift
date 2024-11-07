//
//  scrollreg.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/25/24.
//

import Foundation

public class ScrollRegister {
    var x : UInt8;
    var y : UInt8;
    var latch : Bool;
    
    public init(){
        x = 0;
        y = 0;
        latch = false;
    }
    
    public func write(data : UInt8){
        if !self.latch{
            self.x = data;
        }else{
            self.y = data;
        }
        self.latch = !self.latch;
    }
    
    public func reset_latch(){
        self.latch = false;
    }
}
