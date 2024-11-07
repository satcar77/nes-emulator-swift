//
//  ppu.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/24/24.
//

import Foundation


public class PPU{
    var ar: AddressRegister;
    var cr : ControlRegister;
    var sr : StatusRegister;
    var mr : MaskRegister;
    var scr: ScrollRegister;
    var oam_addr: UInt8;
    var oam_data: [UInt8];
    var buffer : UInt8;
    var chr_rom : [UInt8];
    var vram : [UInt8];
    var mirroring : Mirroring;
    var cycles : Int;
    var scanline : UInt16;
    var nmi_intr : UInt8?;
    var pallet : [UInt8];
    
    public init(chr_rom : [UInt8], mirroring : Mirroring) {
        self.ar = AddressRegister();
        self.cr = ControlRegister(rawValue: 0b00000000);
        self.sr = StatusRegister(rawValue: 0b00000000);
        self.scr = ScrollRegister();
        self.buffer = 0;
        self.chr_rom = chr_rom;
        self.vram = Array(repeating: 0, count: 2048);
        self.mirroring = mirroring;
        self.cycles = 0;
        self.scanline = 0;
        self.pallet = Array(repeating: 0, count: 32);
        self.mr = MaskRegister(rawValue: 0b00000000);
        self.oam_data = Array(repeating: 0, count: 64 * 4)
        self.oam_addr=0;


    }
    
    public func take_nmi() -> UInt8? {
        if self.nmi_intr == 1 {
            self.nmi_intr = nil
            return 1
        }
        return nil
    }
    
    
    public func ar_write(value : UInt8){
        self.ar.update(data: value);
    }
    
    public func increment_addr(){
        self.ar.increment(inc: self.cr.get_increment());
    }

    public func mask_write(value : UInt8){
        self.mr.rawValue = value;
    }

    public func oam_write(value : UInt8){
        self.oam_addr = value;
    }

    public func read_status()->UInt8{
        let res = self.sr.rawValue;
        self.sr.remove(.VBLANK_STARTED);
        self.ar.reset_latch();
        self.scr.reset_latch();
        return res;
    }

    public func oam_data_write(value : UInt8){
        self.oam_data[Int(self.oam_addr)] = value;
        self.oam_addr = self.oam_addr &+ 1;
    }
    
    public func oam_dma_write(data:[UInt8]){
        for d in data {
            self.oam_data[Int(self.oam_addr)] = d;
            self.oam_addr = self.oam_addr &+ 1;
        }
    }

    public func oam_read()->UInt8{
        return self.oam_data[Int(self.oam_addr)];
    }
    public func scroll_write(value : UInt8){
        self.scr.write(data: value);
    }
    
    public func mirr_vram(addr : UInt16) -> UInt16{
       let mirrored_vram = addr & 0b10111111111111;
        let vram_idx = mirrored_vram - 0x2000;
        let name_table = vram_idx / 0x400;
        switch((self.mirroring,name_table)){
        case (.VERTICAL,2) , (.VERTICAL,3) :
            return vram_idx - 0x800;
        case (.HORIZONTAL,2):
            return vram_idx - 0x400;
        case (.HORIZONTAL,1):
            return vram_idx - 0x400;
        case (.HORIZONTAL,3):
            return vram_idx - 0x800;
        default:
            return vram_idx
        }
    }
    
    public func data_read()->UInt8{
        let addr = self.ar.get();
        self.increment_addr();
        switch(addr){
            case 0...0x1fff :
                let res = self.buffer;
                self.buffer = self.chr_rom[Int(addr)];
                return res;
            case 0x2000...0x2fff :
                let res = self.buffer;
                self.buffer = self.vram[Int(self.mirr_vram(addr:addr))]
                return res
            case 0x3000...0x3eff :
                fatalError("\(String(format: "%02X",addr)) should not be used.");
            default :
                fatalError("Seg fault on ppu read address");
        }
        return 0;
    }
    
    func check_sprite_zero_hit() -> Bool{
        let y = self.oam_data[0];
        let x = self.oam_data[3];
        return y == self.scanline && x <= self.cycles && self.mr.contains(.SHOW_SPRITES);
    }
    
    public func tick(cycles : UInt8) -> Bool{
        self.cycles += Int(cycles);
        if self.cycles >= 341 {
            if check_sprite_zero_hit() {
                self.sr.insert(.SPRITE_ZERO_HIT)
            }
            
            self.cycles = self.cycles - 341;
            self.scanline += 1;
            if self.scanline == 241 {
                self.sr.insert(.VBLANK_STARTED);
                self.sr.remove(.SPRITE_ZERO_HIT);
                if self.cr.contains(.GENERATE_NMI){
                    self.nmi_intr = 1;
                }
                return true;
            }
            if self.scanline >= 262 {
                self.scanline = 0;
                self.nmi_intr = nil;
                self.sr.remove(.SPRITE_ZERO_HIT);
                self.sr.remove(.VBLANK_STARTED);
            }
        }
        return false;
    }
    
    public func cr_write(value:UInt8){
        let before_nmi = self.cr.contains(.GENERATE_NMI);
        self.cr.rawValue = value;
        if !before_nmi && self.cr.contains(.GENERATE_NMI) && self.sr.contains(.VBLANK_STARTED){
            self.nmi_intr = 1;
        }
    }

    public func data_write(value:UInt8){
        let addr = self.ar.get();
        switch(addr){
            case 0...0x1fff :
                print("Write to CHR ROM");
            case 0x2000...0x2fff :
                self.vram[Int(self.mirr_vram(addr:addr))] = value;
            case 0x3000...0x3eff :
                print("\(String(format: "%04X",addr)) should not be used.");
            case 0x3f10,0x3f14,0x3f18,0x3f1c :
                let mirror_add = addr - 0x10;
                self.pallet[Int(mirror_add - 0x3f00)] = value;
            case 0x3f00...0x3fff :
                self.pallet[Int(addr - 0x3f00)] = value;
            default :
                fatalError("Seg fault on ppu write address");
        }

        self.increment_addr();
    }
    
    
}
