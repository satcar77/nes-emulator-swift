//
//  cpulogger.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 9/30/24.
//

import Foundation

final class HexFormatter {
    public static func format(hexstring : UInt8)-> String{
        return String(format: "%02X", hexstring)
    }
}

public class CpuLogger{
    var opc_map : [UInt8 : Opcode];
    
    public init(){
        self.opc_map = getOpcodesMap();
    }
    
    public func log(cpu : CPU) -> String {
        guard let opcode = self.opc_map[cpu.mem_read(addr: cpu.pc)] else{
            return "Invalid opcode"
        }
        var op_str = HexFormatter.format(hexstring: opcode.value) + " ";
        switch opcode.len{
        case 1 :
            op_str += "     "
        case 2 :
            op_str += HexFormatter.format(hexstring: cpu.mem_read(addr: cpu.pc + UInt16(1))) + "   "
        case 3:
            op_str += HexFormatter.format(hexstring: cpu.mem_read(addr: cpu.pc + UInt16(1))) + " "
            op_str += HexFormatter.format(hexstring: cpu.mem_read(addr: cpu.pc + UInt16(2)))
        default :
            op_str += "INV"
        }
        
        let (memAddr, storedValue): (UInt16, UInt8) = {
            switch opcode.mode {
            case .Immediate, .NoneAddressing:
                return (0, 0)
                
            default:
                let (addr , _) = cpu.get_abs_addr(mode: opcode.mode,addr: cpu.pc + 1)
                return (addr, cpu.mem_read(addr: addr))
            }
        }()
        
        let tmp: String = {
            switch opcode.len {
            case 1:
                switch opcode.value {
                case 0x0a, 0x4a, 0x2a, 0x6a:
                    return "A "
                default:
                    return ""
                }
                
            case 2:
                let address: UInt8 = cpu.mem_read(addr: cpu.pc + 1)
                // let value = cpu.memRead(address)
//                        op_str += address
//                        hexDump.append(address)

                switch opcode.mode {
                case .Immediate:
                    return String(format: "#$%02X", address)
                    
                case .ZeroPage:
                    return String(format: "$%02X = %02X", memAddr, storedValue)
                    
                case .ZeroPage_X:
                    return String(format: "$%02X,X @ %02X = %02X", address, memAddr, storedValue)
                    
                case .ZeroPage_Y:
                    return String(format: "$%02X,Y @ %02X = %02X", address, memAddr, storedValue)
                    
                case .Indirect_X:
                    return String(format: "($%02X,X) @ %02X = %04X = %02X", address, address &+ cpu.register_x, memAddr, storedValue)
                    
                case .Indirect_Y:
                    return String(format: "($%02X),Y = %04X @ %04X = %02X", address, memAddr &- UInt16(cpu.register_y), memAddr, storedValue)
                    
                case .NoneAddressing:
                    let iaddress : Int8 = Int8(bitPattern: cpu.mem_read(addr: cpu.pc + 1));
                    let calculatedAddress = cpu.pc &+ 2 &+ UInt16(bitPattern: Int16(iaddress))
                    return String(format: "$%04X", calculatedAddress)
                    
                default:
                    fatalError("Unexpected addressing mode \(opcode.mode) has ops-len 2. code \(String(format: "%02X", opcode.value))")
                }
                
            case 3:
                let address = cpu.mem_read_16(addr:cpu.pc + 1)
                
                switch opcode.mode {
                case .NoneAddressing:
                    if opcode.value == 0x6c {
                        // jmp indirect
                        let jmpAddr: UInt16
                        if address & 0x00FF == 0x00FF {
                            let lo = cpu.mem_read(addr:address)
                            let hi = cpu.mem_read(addr:address & 0xFF00)
                            jmpAddr = (UInt16(hi) << 8) | UInt16(lo)
                        } else {
                            jmpAddr = cpu.mem_read_16(addr:address)
                        }
                        return String(format: "($%04X) = %04X", address, jmpAddr)
                    } else {
                        return String(format: "$%04X", address)
                    }
                    
                case .Absolute:
                    return String(format: "$%04X = %02X", memAddr, storedValue)
                    
                case .Absolute_X:
                    return String(format: "$%04X,X @ %04X = %02X", address, memAddr, storedValue)
                    
                case .Absolute_Y:
                    return String(format: "$%04X,Y @ %04X = %02X", address, memAddr, storedValue)
                    
                default:
                    fatalError("Unexpected addressing mode \(opcode.mode) has ops-len 3. code \(String(format: "%02X", opcode.value))")
                }
                
            default:
                return ""
            }
        }()
        
        let first_part = "\(String(format: "%04X", cpu.pc))  \(op_str)\(opcode.name.starts(with: "*") ? " ": "  ")\(opcode.name) \(tmp)"
        let out = "\(first_part.withCString { String(format: "%-47s", $0) }) A:\(HexFormatter.format(hexstring:cpu.register_a)) X:\(HexFormatter.format(hexstring: cpu.register_x)) Y:\(HexFormatter.format(hexstring: cpu.register_y)) P:\(HexFormatter.format(hexstring: cpu.get_status())) SP:\(HexFormatter.format(hexstring: cpu.sp))\n"
        return out
    }
}

