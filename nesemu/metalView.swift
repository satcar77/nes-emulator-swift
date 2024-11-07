//
//  metalView.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 10/8/24.
//

import Foundation
import SwiftUI
import MetalKit
import Cocoa

let JOYMAP = [
    "a" : ButtonStatus.LEFT,
    "w" : ButtonStatus.UP,
    "s" : ButtonStatus.DOWN,
    "d" : ButtonStatus.RIGHT,
    "o" : ButtonStatus.START,
    "p" : ButtonStatus.SELECT,
    "k" : ButtonStatus.BUTTON_A,
    "l" : ButtonStatus.BUTTON_B,
]

let SYSTEM_PALETTE: [(UInt8, UInt8, UInt8)] = [
    (0x80, 0x80, 0x80), (0x00, 0x3D, 0xA6), (0x00, 0x12, 0xB0), (0x44, 0x00, 0x96), (0xA1, 0x00, 0x5E),
    (0xC7, 0x00, 0x28), (0xBA, 0x06, 0x00), (0x8C, 0x17, 0x00), (0x5C, 0x2F, 0x00), (0x10, 0x45, 0x00),
    (0x05, 0x4A, 0x00), (0x00, 0x47, 0x2E), (0x00, 0x41, 0x66), (0x00, 0x00, 0x00), (0x05, 0x05, 0x05),
    (0x05, 0x05, 0x05), (0xC7, 0xC7, 0xC7), (0x00, 0x77, 0xFF), (0x21, 0x55, 0xFF), (0x82, 0x37, 0xFA),
    (0xEB, 0x2F, 0xB5), (0xFF, 0x29, 0x50), (0xFF, 0x22, 0x00), (0xD6, 0x32, 0x00), (0xC4, 0x62, 0x00),
    (0x35, 0x80, 0x00), (0x05, 0x8F, 0x00), (0x00, 0x8A, 0x55), (0x00, 0x99, 0xCC), (0x21, 0x21, 0x21),
    (0x09, 0x09, 0x09), (0x09, 0x09, 0x09), (0xFF, 0xFF, 0xFF), (0x0F, 0xD7, 0xFF), (0x69, 0xA2, 0xFF),
    (0xD4, 0x80, 0xFF), (0xFF, 0x45, 0xF3), (0xFF, 0x61, 0x8B), (0xFF, 0x88, 0x33), (0xFF, 0x9C, 0x12),
    (0xFA, 0xBC, 0x20), (0x9F, 0xE3, 0x0E), (0x2B, 0xF0, 0x35), (0x0C, 0xF0, 0xA4), (0x05, 0xFB, 0xFF),
    (0x5E, 0x5E, 0x5E), (0x0D, 0x0D, 0x0D), (0x0D, 0x0D, 0x0D), (0xFF, 0xFF, 0xFF), (0xA6, 0xFC, 0xFF),
    (0xB3, 0xEC, 0xFF), (0xDA, 0xAB, 0xEB), (0xFF, 0xA8, 0xF9), (0xFF, 0xAB, 0xB3), (0xFF, 0xD2, 0xB0),
    (0xFF, 0xEF, 0xA6), (0xFF, 0xF7, 0x9C), (0xD7, 0xE8, 0x95), (0xA6, 0xED, 0xAF), (0xA2, 0xF2, 0xDA),
    (0x99, 0xFF, 0xFC), (0xDD, 0xDD, 0xDD), (0x11, 0x11, 0x11), (0x11, 0x11, 0x11)
]


struct MetalView: NSViewRepresentable {
    
    private var scaleFactor : UInt = 3
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
 
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let mtkView = MTKView(frame: CGRect(x:0,y:0,width : 256, height : 240))
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        mtkView.framebufferOnly = false
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 100, green: 100, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        
        
        let button = NSButton(frame: NSRect(x: 0, y: 0 , width: 100, height: 30))
        button.title = "Load ROM"
        button.bezelStyle = .rounded
        button.target = context.coordinator
        button.action = #selector(Coordinator.load_rom)
        
        mtkView.addSubview(button)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown){
            event in context.coordinator.handleKeyDown(event)
            return event
        }
       NSEvent.addLocalMonitorForEvents(matching: .keyUp){
            event in context.coordinator.handleKeyUp(event)
            return event
        }
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
        
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent: MetalView
        var metalDevice: MTLDevice!
        var metalCommandQueue: MTLCommandQueue!
        private var bus: Bus!
        private var cpu : CPU!
        private var frame : [UInt32]
        private var width  = 256;
        private var height = 240;
        private var metalView : MTKView!;
        private var frameCount : Int = 0
        private var lastFrameUpdate : Double = 0

        init(_ parent: MetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.metalDevice = metalDevice
            }
            self.metalCommandQueue = metalDevice.makeCommandQueue()!
            let sf = Int(self.parent.scaleFactor)
            self.frame = [UInt32].init(repeating: 0x00, count: 256 * 240 * sf * sf)
            super.init()
        }
        
        @objc func load_rom(){
            let openDialog = NSOpenPanel()
            if(openDialog.runModal() == .OK) {
                load_game(rom_url: openDialog.url?.path ?? "")
            }
        }
        
        func get_background_pallet(ppu:PPU,attrb_table : inout [UInt8],tileX:Int,tileY:Int)->[Int]{
            let attrb_idx = (tileY / 4) * 8 + (tileX / 4);
            let attrb_data = attrb_table[attrb_idx];
            let pallet_i : UInt8
            switch ((tileX % 4) / 2,(tileY % 4) / 2){
            case (0,0) :
                pallet_i = attrb_data & 0b11;
            case (1,0):
                pallet_i = (attrb_data >> 2) & 0b11;
            case (0,1):
                pallet_i = (attrb_data >> 4) & 0b11;
            case (1,1):
                pallet_i = (attrb_data >> 6) & 0b11;
            default :
                fatalError("no such bg pallet tile case")
            }
            let start: Int = 1 + (Int(pallet_i) * 4);
            return [Int(ppu.pallet[0]),Int(ppu.pallet[start]),Int(ppu.pallet[start+1]),Int(ppu.pallet[start+2])]
            
        }
        
        
        func spritePalette(ppu: PPU, paletteIdx: UInt8) -> [UInt8] {
            let start = 0x11 + Int(paletteIdx * 4)
            
            return [
                0,
                ppu.pallet[start],
                ppu.pallet[start + 1],
                ppu.pallet[start + 2]
            ]
        }
        
        func setPixel(x:Int,y:Int,rgb : (UInt8,UInt8,UInt8)){
            let iSf = Int(self.parent.scaleFactor)
            if (x < width && y < height) {
                let rgba : UInt32 = (UInt32(rgb.0) << 16) | (UInt32(rgb.1) << 8) | (UInt32(rgb.2) << 0)
                for i in 0..<iSf {
                    for j in 0..<iSf {
                        self.frame[((x * iSf) + i) + ((y * iSf + j) * (256 * iSf))] = rgba
                    }
                }
            }
        }
        
        func renderBackground(nametable:  inout [UInt8] , viewport : Viewport, shiftx : Int, shifty : Int){
            let ppu = self.bus.ppu;
            let bank = ppu.cr.get_backgrnd_addr()
            var attrb_table : [UInt8] = Array(nametable[0x3c0..<0x400])
            //background tiles
            for i in 0..<0x03c0{
                let tileI = UInt16(nametable[i]);
                let tileX = i % 32;
                let tileY = i / 32;
                let tile: [UInt8] = Array(ppu.chr_rom[Int(bank + tileI * 16)...Int(bank + tileI * 16 + 15)])
                let pallet = self.get_background_pallet(ppu: ppu,attrb_table: &attrb_table, tileX: tileX, tileY: tileY)
                for y in 0...7 {
                    var upper = tile[y]
                    var lower = tile[y + 8]
                    
                    for x in stride(from: 7, through: 0, by: -1) {
                        let value = ((1 & lower) << 1) | (1 & upper)
                        upper >>= 1
                        lower >>= 1
                        
                        let rgb: (UInt8,UInt8,UInt8)
                        switch value {
                        case 0:
                            rgb = SYSTEM_PALETTE[pallet[0]]
                        case 1:
                            rgb = SYSTEM_PALETTE[pallet[1]]
                        case 2:
                            rgb = SYSTEM_PALETTE[pallet[2]]
                        case 3:
                            rgb = SYSTEM_PALETTE[pallet[3]]
                        default:
                            fatalError("Invalid value encountered.")
                        }
                        let pix_x = tileX * 8 + x;
                        let pix_y = tileY * 8 + y;
                        if pix_x >= viewport.x1 && pix_x < viewport.x2 && pix_y >= viewport.y1 && pix_y < viewport.y2 {
                            self.setPixel(x: pix_x + shiftx , y: pix_y + shifty, rgb: rgb)
                        }
                    }
                }
            }
        }
        
        func get_nametables(mirroring_mode : Mirroring, nametable_addr : UInt16) -> ([UInt8],[UInt8]){
            let ppu = self.bus.ppu;
                switch (mirroring_mode, nametable_addr) {
                case (.VERTICAL, 0x2000), (.VERTICAL, 0x2800), (.HORIZONTAL, 0x2000), (.HORIZONTAL, 0x2400):
                    return (Array(ppu.vram[0..<0x400]), Array(ppu.vram[0x400..<0x800]))
                case (.VERTICAL, 0x2400), (.VERTICAL, 0x2C00), (.HORIZONTAL, 0x2800), (.HORIZONTAL, 0x2C00):
                    return (Array(ppu.vram[0x400..<0x800]), Array(ppu.vram[0..<0x400]))
                default:
                    fatalError("Unsupported mirroring type")
                }
        }
        
        func renderCallback(){
            let ppu = self.bus.ppu;
            let scrollX = Int(ppu.scr.x);
            let scrollY = Int(ppu.scr.y);
            var (main_nt , second_nt) = self.get_nametables(mirroring_mode: ppu.mirroring, nametable_addr: ppu.cr.get_nametable_address())
            self.renderBackground(nametable: &main_nt, viewport: Viewport(x1: scrollX, y1: scrollY, x2: 256, y2: 240), shiftx: -scrollX, shifty: -scrollY)
        
            if scrollX > 0 {
                self.renderBackground(nametable: &second_nt, viewport: Viewport(x1: 0, y1: 0, x2: scrollX, y2: 240), shiftx: (256 - scrollX), shifty: 0)
                }
            else if scrollY > 0 {
                self.renderBackground(nametable: &second_nt, viewport: Viewport(x1: 0, y1: 0, x2: 256 , y2: scrollY), shiftx : 0 , shifty: (240 - scrollY))
            }
          
            for i in stride(from: ppu.oam_data.count - 4, through: 0, by: -4) {
                let tileIdx = UInt16(ppu.oam_data[i + 1])
                let tileX = Int(ppu.oam_data[i + 3])
                let tileY = Int(ppu.oam_data[i])
                
                let flipVertical = (ppu.oam_data[i + 2] >> 7 & 1) == 1
                let flipHorizontal = (ppu.oam_data[i + 2] >> 6 & 1) == 1
                let paletteIdx = ppu.oam_data[i + 2] & 0b11
                let spritePalette = spritePalette(ppu: ppu, paletteIdx: paletteIdx)
                
                let bank: UInt16 = ppu.cr.sprite_pall_addr()
                
                let tile = Array(ppu.chr_rom[(Int(bank) + Int(tileIdx * 16))...Int(bank + tileIdx * 16 + 15)])
                
                for y in 0...7 {
                    var upper = tile[y]
                    var lower = tile[y + 8]
                    
                    for x in stride(from: 7, through: 0, by: -1) {
                        let value = ((1 & lower) << 1) | (1 & upper)
                        upper >>= 1
                        lower >>= 1
                        
                        let rgb: (UInt8,UInt8,UInt8)
                        switch value {
                        case 0:
                            continue // skip coloring the pixel
                        case 1:
                            rgb = SYSTEM_PALETTE[Int(spritePalette[1])]
                        case 2:
                            rgb = SYSTEM_PALETTE[Int(spritePalette[2])]
                        case 3:
                            rgb = SYSTEM_PALETTE[Int(spritePalette[3])]
                        default:
                            fatalError("Unexpected value")
                        }
                        
                        switch (flipHorizontal, flipVertical) {
                        case (false, false):
                            self.setPixel(x: tileX + x, y: tileY + y, rgb: rgb)
                        case (true, false):
                            self.setPixel(x: tileX + 7 - x, y: tileY + y, rgb: rgb)
                        case (false, true):
                            self.setPixel(x: tileX + x, y: tileY + 7 - y, rgb: rgb)
                        case (true, true):
                            self.setPixel(x: tileX + 7 - x, y: tileY + 7 - y, rgb: rgb)
                        }
                    }
                }
            }
        }
        
        func load_game(rom_url:String){
            do {
                let fileURL = URL(fileURLWithPath: rom_url)
                let data = try Data(contentsOf: fileURL)
                let rom =  try Rom(raw:[UInt8](data))
                self.bus = Bus(rom: rom)
                self.cpu = CPU(bi_bus: self.bus)
                self.cpu.reset()
            }
            catch {
                fatalError("Cannot load ROM : \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            self.metalView = view
        }
        
        func handleKeyDown(_ event:NSEvent)
        {
            let key = event.charactersIgnoringModifiers ?? ""
            guard let btn = JOYMAP[key] else {
                return
            }
            self.bus.joy1.press_btn(val: btn,pressed: true)
            
        }
        func handleKeyUp(_ event:NSEvent)
        {
            let key = event.charactersIgnoringModifiers ?? ""
            guard let btn = JOYMAP[key] else {
                return
            }
            self.bus.joy1.press_btn(val: btn,pressed : false)
            
        }
         
        func renderMetal() {
            guard let drawable = self.metalView.currentDrawable else {
                return
            }
            let width = Int(256 * self.parent.scaleFactor)
            let height = Int(240 * self.parent.scaleFactor)
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            
            self.metalView.currentDrawable!.texture.replace(region: MTLRegionMake2D(0, 0, width , height),
                                                  mipmapLevel: 0,
                                                  withBytes: self.frame,
                                                  bytesPerRow: bytesPerRow)
            
            let commandBuffer = metalCommandQueue.makeCommandBuffer()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }    

        func draw(in view: MTKView) {
            if self.bus == nil || self.cpu == nil {
                return
            }
            while !self.bus.frameReady {
                cpu.step()
            }
            self.bus.frameReady = false
            self.renderCallback();
            self.renderMetal()
        }

    
    }
}
