//
//  maskreg.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/25/24.
//

import Foundation

public enum GameColor {
    case Red
    case Green
    case Blue
}

struct MaskRegister : OptionSet {
    var rawValue: UInt8 ;
    
    static let GREYSCALE               = MaskRegister(rawValue: 0b00000001);
    static let LEFTMOST_8PXL_BACKGROUND  = MaskRegister(rawValue: 0b00000010);
    static let LEFTMOST_8PXL_SPRITE      = MaskRegister(rawValue: 0b00000100);
    static let SHOW_BACKGROUND         = MaskRegister(rawValue: 0b00001000);
    static let SHOW_SPRITES            = MaskRegister(rawValue: 0b00010000);
    static let EMPHASISE_RED           = MaskRegister(rawValue: 0b00100000);
    static let EMPHASISE_GREEN         = MaskRegister(rawValue: 0b01000000);
    static let EMPHASISE_BLUE          = MaskRegister(rawValue: 0b10000000);
    
}

