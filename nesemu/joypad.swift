//
//  joypad.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 10/15/24.
//

import Foundation


struct ButtonStatus : OptionSet {
    var rawValue: UInt8 ;
    
    static let RIGHT          = ButtonStatus(rawValue: 1 << 7);
    static let LEFT         = ButtonStatus(rawValue: 1 << 6);
    static let DOWN         = ButtonStatus(rawValue: 1 << 5);
    static let UP         = ButtonStatus(rawValue: 1 << 4);
    static let START         = ButtonStatus(rawValue: 1 << 3);
    static let SELECT  = ButtonStatus(rawValue: 1 << 2);
    static let BUTTON_B  = ButtonStatus(rawValue: 1 << 1);
    static let BUTTON_A   = ButtonStatus(rawValue: 1 << 0);

}


class Joypad {
    private var strobe : Bool
    private var btn_idx : UInt8
    private var btn_sta : ButtonStatus
    
    init(){
        self.strobe = false
        self.btn_idx = 0
        self.btn_sta = ButtonStatus(rawValue: 0)
    }
    
    public func write(data : UInt8){
        self.strobe = data & 1 == 1
        if self.strobe {
            self.btn_idx = 0
        }
    }
    public func read() -> UInt8 {
        if self.btn_idx > 7 {
            return 1
        }
        let res  = (self.btn_sta.rawValue & (1 << self.btn_idx)) >> self.btn_idx;
        if !self.strobe && self.btn_idx <= 7 {
            self.btn_idx += 1
        }
        return res
    }
    public func press_btn(val : ButtonStatus, pressed : Bool){
        if pressed {
            self.btn_sta.insert(val)
        }else{
            self.btn_sta.remove(val)
        }
    }
    
    
}
