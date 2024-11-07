//
//  addrreg.rs.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/24/24.
//

import Foundation

public class AddressRegister {
    var value0 : UInt8;
    var value1 : UInt8;
    var hi_ptr : Bool;
    
    public init(){
        value0 = 0;
        value1 = 0;
        hi_ptr = true;
    }
    
    public func set(data :UInt16){
        self.value0 = UInt8(data >> 8);
        self.value1 = UInt8(data & 0xff);
    }
    public func get() -> UInt16{
        return UInt16(self.value0) << 8 | UInt16(self.value1);
    }
    
    private func mirror(){
        if self.get() > 0x3fff {
            self.set(data : self.get() & 0b11111111111111);
        }
    }
    
    public func update(data:UInt8){
        if self.hi_ptr {
            self.value0 = data;
        }else{
            self.value1 = data;
        }
        mirror();
        self.hi_ptr = !self.hi_ptr;
    }
    
    public func increment(inc : UInt8){
        let lo = self.value1;
        self.value1 = self.value1 &+ inc;
        if lo > self.value1 {
            self.value0 = self.value0 &+ 1;
        }
        mirror();
    }
    
    public func reset_latch(){
        self.hi_ptr = true;
    }
    
}
