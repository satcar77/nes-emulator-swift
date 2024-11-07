//
//  bus.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/8/24.
//

import Foundation

let RAM: UInt16 = 0x0000;
let RAM_MIRRORS_END: UInt16 = 0x1FFF;
let PPU_REGISTERS: UInt16 = 0x2000;
let PPU_REGISTERS_MIRRORS_END: UInt16 = 0x3FFF;

public class Bus {
    var ram : [UInt8];
    var rom :Rom;
    var ppu : PPU;
    var cycles : Int;
    var callback :  (() -> Void)?;
    var joy1 : Joypad;
    var frameReady : Bool = false;
    
    public init(rom:Rom){
        self.ram = Array(repeating: 0, count: 2048);
        self.rom = rom;
        self.ppu = PPU(chr_rom: self.rom.chr_rom, mirroring: self.rom.screen_mirroring);
        self.cycles = 0;
        self.joy1 = Joypad();
    }
    
    public func add_callback(callback:@escaping (()->Void)){
        self.callback = callback;
    }
    
    func mem_read(addr:UInt16) -> UInt8 {
        switch addr {
        case RAM...RAM_MIRRORS_END:
            let mirrAdd = addr & 0b00000111_11111111;
            return self.ram[Int(mirrAdd)]
        case 0x2000, 0x2001,0x2003,0x2005,0x2006,0x4014:
            fatalError("Attempting to read write only PPU register");
        case 0x2002 :
            return self.ppu.read_status()
        case 0x2004 :
            return self.ppu.oam_read()
        case 0x2007 :
            return self.ppu.data_read()
        case 0x4000...0x4015 :
            return 0
        case 0x4016:
            return self.joy1.read()
        case 0x4017:
            return 0
        case 0x2008...PPU_REGISTERS_MIRRORS_END:
            let mirrDown = addr & 0b00100000_00000111;
            return self.mem_read(addr: mirrDown);
        case  0x8000...0xFFFF:
            return self.read_prg_rom(addr:addr)
        default:
          print("Ignoring mem access at \(String(format: "%04X", addr))")
          return 0
        }
    }
    
    func mem_write(addr:UInt16, data :UInt8){
        switch addr {
            case RAM ... RAM_MIRRORS_END :
                let mirrAdd = addr & 0b00000111_11111111;
                self.ram[Int(mirrAdd)] = data;
            case 0x2000 :
                self.ppu.cr_write(value: data);
            case 0x2001:
                self.ppu.mask_write(value:data);
            case 0x2002:
                fatalError("Attempt to write to PPU status register");
            case 0x2003:
                self.ppu.oam_write(value:data);
            case 0x2004:
                self.ppu.oam_data_write(value:data);
            case 0x2005:
                self.ppu.scroll_write(value:data);
            case 0x2006:
                self.ppu.ar_write(value:data);
            case 0x2007:
                self.ppu.data_write(value:data);
            case 0x4000...0x4013,0x4015:
                return
            case 0x4016:
                self.joy1.write(data: data);
            case 0x4017:
                return
            case 0x4014:
                var buf:[UInt8] = Array(repeating: 0, count: 256);
                    let hi = UInt16(data) << 8;
                for i in 0..<256 {
                    buf[i] = self.mem_read(addr: hi + UInt16(i));
                };
                self.ppu.oam_dma_write(data: buf)
            
            case 0x2008...PPU_REGISTERS_MIRRORS_END:
                let mirror_addr = addr & 0b00100000_00000111
                self.mem_write(addr: mirror_addr, data: data);
            
            case 0x8000...0xFFFF :
                fatalError("Attempt to write to Cartridge ROM space");

            default:
              print("Ignoring mem access at \(addr)")
            }
            
        }
    
    func read_prg_rom(addr: UInt16) -> UInt8 {
        
        var addr = addr - 0x8000
        
        if self.rom.prg_rom.count == 0x4000 && addr >= 0x4000 {
            addr %= 0x4000
        }
        
        return self.rom.prg_rom[Int(addr)]
    }
    
    public func tick(cycles:UInt8){
        self.cycles += Int(cycles);
        if self.ppu.tick(cycles : cycles * 3){
            self.callback?();
            self.frameReady = true;
        }
    }
    
    public func poll_nmi()->UInt8?{
        return self.ppu.take_nmi();
    }
    
}
