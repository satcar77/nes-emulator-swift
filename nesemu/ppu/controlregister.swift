//
//  controlregister.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/24/24.
//

import Foundation

struct ControlRegister : OptionSet {
    var rawValue: UInt8 ;
    
    static let NAMETABLE1              = ControlRegister(rawValue: 0b00000001);
    static let NAMETABLE2              = ControlRegister(rawValue: 0b00000010);
    static let VRAM_ADD_INCREMENT      = ControlRegister(rawValue: 0b00000100);
    static let SPRITE_PATTERN_ADDR     = ControlRegister(rawValue: 0b00001000);
    static let BACKROUND_PATTERN_ADDR  = ControlRegister(rawValue: 0b00010000);
    static let SPRITE_SIZE             = ControlRegister(rawValue: 0b00100000);
    static let MASTER_SLAVE_SELECT     = ControlRegister(rawValue: 0b01000000);
    static let GENERATE_NMI            = ControlRegister(rawValue: 0b10000000);

    func get_increment()->UInt8 {
        if !self.contains(.VRAM_ADD_INCREMENT){
            return 1;
        } else {
            return 32;
        }
    }
    
    func get_nametable_address() -> UInt16{
        switch self.rawValue & 0b11 {
            case 0 : return 0x2000
            case 1 : return 0x2400
            case 2: return 0x2800
            case 3 : return 0x2c00
        default :
           fatalError("Nametable address error")
        }
         
    }
    
    func get_backgrnd_addr()->UInt16{
        if !self.contains(.BACKROUND_PATTERN_ADDR){
            return 0;
        }else{
            return 0x1000;
        }
    }
    
    func sprite_pall_addr()->UInt16 {
        if !self.contains(.SPRITE_PATTERN_ADDR){
            return 0;
        }else{
            return 0x1000;
        }
    }
}
