//
//  statusreg.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/25/24.
//

import Foundation

struct StatusRegister : OptionSet {
    var rawValue: UInt8 ;
    
    static let NOTUSED          = StatusRegister(rawValue: 0b00000001);
    static let NOTUSED2         = StatusRegister(rawValue: 0b00000010);
    static let NOTUSED3         = StatusRegister(rawValue: 0b00000100);
    static let NOTUSED4         = StatusRegister(rawValue: 0b00001000);
    static let NOTUSED5         = StatusRegister(rawValue: 0b00010000);
    static let SPRITE_OVERFLOW  = StatusRegister(rawValue: 0b00100000);
    static let SPRITE_ZERO_HIT  = StatusRegister(rawValue: 0b01000000);
    static let VBLANK_STARTED   = StatusRegister(rawValue: 0b10000000);

}
