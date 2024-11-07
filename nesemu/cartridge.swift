//
//  cartridge.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/8/24.
//

import Foundation


public enum Mirroring {
    case VERTICAL
    case HORIZONTAL
    case  FOUR_SCREEN
}


public enum RomError: Error {
    case invalidFormat
    case unsupportedVersion
}

public class Rom {
    public var prg_rom :[UInt8];
    public var chr_rom :[UInt8];
    public var mapper : UInt8;
    public var screen_mirroring : Mirroring;
    
    static let NES_TAG: [UInt8] = [0x4E, 0x45, 0x53, 0x1A];
    static let PRG_ROM_PAGE_SIZE: Int = 16384;
    static let CHR_ROM_PAGE_SIZE: Int = 8192;
    
    public init (raw: [UInt8]) throws{
        guard raw.count >= 16 else {
                  throw RomError.invalidFormat
              }
        
        if Array(raw[0..<4]) != Rom.NES_TAG {
            throw RomError.invalidFormat;
        }
        
        let mapper = (raw[7] & 0b1111_0000) | (raw[6] >> 4)
        let inesVersion = (raw[7] >> 2) & 0b11
        if inesVersion != 0 {
           throw RomError.unsupportedVersion
        }

        let fourScreen = raw[6] & 0b1000 != 0
        let verticalMirroring = raw[6] & 0b1 != 0
    
        let prgRomSize = Int(raw[4]) * Rom.PRG_ROM_PAGE_SIZE
        let chrRomSize = Int(raw[5]) * Rom.CHR_ROM_PAGE_SIZE
        

        let skipTrainer = raw[6] & 0b100 != 0
        let prgRomStart = 16 + (skipTrainer ? 512 : 0)
        let chrRomStart = prgRomStart + prgRomSize
        
        guard prgRomStart + prgRomSize <= raw.count && chrRomStart + chrRomSize <= raw.count else {
            throw RomError.invalidFormat
        }
        
        
        self.prg_rom = Array(raw[prgRomStart..<(prgRomStart + prgRomSize)])
        self.chr_rom = Array(raw[chrRomStart..<(chrRomStart + chrRomSize)])
        self.mapper = mapper
        self.screen_mirroring = {
            if fourScreen {
                return .FOUR_SCREEN
            } else if verticalMirroring {
                return .VERTICAL
            } else {
                return .HORIZONTAL
            }
        }()
        
        
    }
}
