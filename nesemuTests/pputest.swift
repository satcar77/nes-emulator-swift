//
//  pputest.swift
//  nesemuTests
//
//  Created by Dhakal, Satkar on 9/30/24.
//

import XCTest

@testable import nesemu


final class pputest: XCTestCase {
    var ppu : PPU! ;
    
    override func setUp() async throws {
        self.ppu = PPU(chr_rom: Array(repeating: 0, count: 2048), mirroring: Mirroring.HORIZONTAL)
    }
    
    func test_vram_writes(){
        self.ppu.ar_write(value: 0x23);
        self.ppu.ar_write(value: 0x05);
        self.ppu.data_write(value: 0x66);
        XCTAssertEqual(ppu.vram[0x0305], 0x66);
    }
    
    func test_vran_read(){
        self.ppu.cr_write(value: 0);
        ppu.vram[0x0305] = 0x66;
        ppu.ar_write(value: 0x23);
        ppu.ar_write(value: 0x05);
        ppu.data_read();
        XCTAssertEqual(ppu.ar.get(), 0x2306);
        XCTAssertEqual(ppu.data_read(), 0x66);
    }
    func test_vran_read_cross_page(){
        self.ppu.cr_write(value: 0);
        ppu.vram[0x01ff] = 0x66;
        ppu.vram[0x0200] = 0x77;
        ppu.ar_write(value: 0x21);
        ppu.ar_write(value: 0xff);
        ppu.data_read();
        XCTAssertEqual(ppu.data_read(), 0x66);
        XCTAssertEqual(ppu.data_read(), 0x77);
    }
    
    func test_vran_read_step_32(){
        self.ppu.cr_write(value: 0b100);
        ppu.vram[0x01ff] = 0x66;
        ppu.vram[0x01ff + 32] = 0x77;
        ppu.vram[0x01ff + 64] = 0x88;
        ppu.ar_write(value: 0x21);
        ppu.ar_write(value: 0xff);
        ppu.data_read();
        XCTAssertEqual(ppu.data_read(), 0x66);
        XCTAssertEqual(ppu.data_read(), 0x77);
        XCTAssertEqual(ppu.data_read(), 0x88);
        
    }
    
    func test_vram_horiz(){
        ppu.ar_write(value: 0x24)
        ppu.ar_write(value : 0x05)
        ppu.data_write(value : 0x66) // write to A
        
        ppu.ar_write(value:0x28)
        ppu.ar_write(value :0x05)
        ppu.data_write(value:0x77) // write to B
        
        ppu.ar_write(value: 0x20)
        ppu.ar_write(value: 0x05)
        
        ppu.data_read() // load into buffer
        XCTAssertEqual(ppu.data_read(), 0x66) // read from A
        
        ppu.ar_write(value:0x2C)
        ppu.ar_write(value:0x05)
        
        ppu.data_read() // load into buffer
        XCTAssertEqual(ppu.data_read(), 0x77) // read from B
    }
    
    func test_vram_vert(){
        let vppu = PPU(chr_rom: Array(repeating: 0, count: 2048), mirroring: .VERTICAL);
        vppu.ar_write(value: 0x20)
        vppu.ar_write(value : 0x05)
        vppu.data_write(value : 0x66) // write to A
        
        vppu.ar_write(value:0x2c)
        vppu.ar_write(value :0x05)
        vppu.data_write(value:0x77) // write to B
        
        vppu.ar_write(value: 0x28)
        vppu.ar_write(value: 0x05)
        
        vppu.data_read() // load into buffer
        XCTAssertEqual(vppu.data_read(), 0x66) // read from A
        
        vppu.ar_write(value:0x24)
        vppu.ar_write(value:0x05)
        
        vppu.data_read() // load into buffer
        XCTAssertEqual(vppu.data_read(), 0x77) // read from B
    }
    
    func test_latch(){
        ppu.vram[0x0305] = 0x66;
        ppu.ar_write(value: 0x21);
        ppu.ar_write(value: 0x23);
        ppu.ar_write(value: 0x05);
        ppu.data_read();
        XCTAssertNotEqual(ppu.data_read(), 0x66);
        ppu.read_status();
        ppu.ar_write(value: 0x23);
        ppu.ar_write(value: 0x05);
        ppu.data_read()
        XCTAssertEqual(ppu.data_read(), 0x66);
    }
    
    func test_vram_mirror(){
        ppu.cr_write(value: 0);
        ppu.vram[0x0305] = 0x66;
        ppu.ar_write(value: 0x63);
        ppu.ar_write(value: 0x05);
        ppu.data_read();
        XCTAssertEqual(ppu.data_read(), 0x66);
    }
    
    func test_oam(){
        ppu.oam_write(value: 0x10);
        ppu.oam_data_write(value:0x66);
        ppu.oam_data_write(value:0x77);
        ppu.oam_write(value: 0x10);
        XCTAssertEqual(ppu.oam_read(), 0x66);
        ppu.oam_write(value: 0x11);
        XCTAssertEqual(ppu.oam_read(), 0x77);
    }
    
    func test_vblank(){
        ppu.sr.insert(.VBLANK_STARTED);
        let status = ppu.read_status();
        XCTAssertEqual(status >> 7, 1);
        XCTAssertEqual(ppu.sr.rawValue >> 7, 0);
    }
    
    func test_oam_dma(){
        var data:[UInt8] = Array(repeating: 0x66, count: 256);
        data[0] = 0x77;
        data[255] = 0x88;
        ppu.oam_write(value: 0x10);
        ppu.oam_dma_write(data: data);
        ppu.oam_write(value: 0xf);
        XCTAssertEqual(ppu.oam_read(), 0x88);
    }
}
