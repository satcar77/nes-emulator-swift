//
//  RomTests.swift
//  nesemuTests
//
//  Created by Dhakal, Satkar on 9/8/24.
//

import XCTest
@testable import nesemu
final class RomTests: XCTestCase {

    override func setUpWithError() throws {
      
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_rom() throws{
        let header: [UInt8] =  [
            0x4E, 0x45, 0x53, 0x1A, 0x02, 0x01, 0x31, 00, 00, 00, 00, 00, 00, 00, 00, 00,
        ];
        let rom = header + Array(repeating: 1, count: 2 * Rom.PRG_ROM_PAGE_SIZE) + Array(repeating: 2, count: 1 * Rom.CHR_ROM_PAGE_SIZE);
        try! Rom(raw: rom)
    }
    
    func test_nes_v2() throws{
        let header: [UInt8] =  [
            0x4E, 0x45, 0x53, 0x1A, 0x01, 0x01, 0x31, 0x8, 00, 00, 00, 00, 00, 00, 00, 00,
        ];
        let rom = header + Array(repeating: 1, count: 2 * Rom.PRG_ROM_PAGE_SIZE) + Array(repeating: 2, count: 1 * Rom.CHR_ROM_PAGE_SIZE);
        XCTAssertThrowsError(try Rom(raw: rom)){
            error in XCTAssertEqual(error as? RomError, .unsupportedVersion)
        }
    }
    
    func test_w_trainer() throws{
        let header: [UInt8] =  [
                    0x4E,
                    0x45,
                    0x53,
                    0x1A,
                    0x02,
                    0x01,
                    0x31 | 0b100,
                    00,
                    00,
                    00,
                    00,
                    00,
                    00,
                    00,
                    00,
                    00,
        ];
        let trainer : [UInt8] = Array(repeating:0,count : 512);
        let raw = header + trainer +  Array(repeating: 1, count: 2 * Rom.PRG_ROM_PAGE_SIZE) + Array(repeating: 2, count: 1 * Rom.CHR_ROM_PAGE_SIZE);
        let rom = try Rom(raw: raw)
        XCTAssertEqual(rom.chr_rom, Array(repeating: 2, count: 1 * Rom.CHR_ROM_PAGE_SIZE))
        XCTAssertEqual(rom.prg_rom, Array(repeating: 1, count: 2 * Rom.PRG_ROM_PAGE_SIZE))
        XCTAssertEqual(rom.mapper,3)
        XCTAssertEqual(rom.screen_mirroring,Mirroring.VERTICAL)
        
    }
        
    
    

}
