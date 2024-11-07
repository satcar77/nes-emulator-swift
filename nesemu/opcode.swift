//
//  opcode.swift
//  nesemu
//
//  Created by Dhakal, Satkar on 8/21/24.
//

import Foundation

public enum AddressingMode {
    case Immediate,
    ZeroPage,
    ZeroPage_X,
    ZeroPage_Y,
    Absolute,
    Absolute_X,
    Absolute_Y,
    Indirect_X,
    Indirect_Y,
    NoneAddressing
}

public struct Opcode {
    var value : UInt8;
    var name : String;
    var len : UInt8;
    var cycles : UInt8;
    var mode : AddressingMode;
}

public var opcodes = [
    Opcode(value: 0x00, name: "BRK", len: 1, cycles: 7, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xea, name: "NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    /* Arithmetic */
    Opcode(value: 0x69, name: "ADC", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x65, name: "ADC", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x75, name: "ADC", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x6d, name: "ADC", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x7d, name: "ADC", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x79, name: "ADC", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x61, name: "ADC", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x71, name: "ADC", len: 2, cycles: 5/*+1 if page crossed*/, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0xe9, name: "SBC", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xe5, name: "SBC", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xf5, name: "SBC", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xed, name: "SBC", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0xfd, name: "SBC", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_X),
    Opcode(value: 0xf9, name: "SBC", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0xe1, name: "SBC", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0xf1, name: "SBC", len: 2, cycles: 5/*+1 if page crossed*/, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x29, name: "AND", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x25, name: "AND", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x35, name: "AND", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x2d, name: "AND", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x3d, name: "AND", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x39, name: "AND", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x21, name: "AND", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x31, name: "AND", len: 2, cycles: 5/*+1 if page crossed*/, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x49, name: "EOR", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x45, name: "EOR", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x55, name: "EOR", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x4d, name: "EOR", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x5d, name: "EOR", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x59, name: "EOR", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x41, name: "EOR", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x51, name: "EOR", len: 2, cycles: 5/*+1 if page crossed*/, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x09, name: "ORA", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x05, name: "ORA", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x15, name: "ORA", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x0d, name: "ORA", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x1d, name: "ORA", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x19, name: "ORA", len: 3, cycles: 4/*+1 if page crossed*/, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x01, name: "ORA", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x11, name: "ORA", len: 2, cycles: 5/*+1 if page crossed*/, mode: AddressingMode.Indirect_Y),

    /*Shifts*/
    Opcode(value: 0x0a, name: "ASL", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x06, name: "ASL", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x16, name: "ASL", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x0e, name: "ASL", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x1e, name: "ASL", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),

    Opcode(value: 0x4a, name: "LSR", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x46, name: "LSR", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x56, name: "LSR", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x4e, name: "LSR", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x5e, name: "LSR", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),

    Opcode(value: 0x2a, name: "ROL", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x26, name: "ROL", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x36, name: "ROL", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x2e, name: "ROL", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x3e, name: "ROL", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),

    Opcode(value: 0x6a, name: "ROR", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x66, name: "ROR", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x76, name: "ROR", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x6e, name: "ROR", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x7e, name: "ROR", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),

    Opcode(value: 0xe6, name: "INC", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xf6, name: "INC", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xee, name: "INC", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0xfe, name: "INC", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),

    Opcode(value: 0xe8, name: "INX", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xc8, name: "INY", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0xc6, name: "DEC", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xd6, name: "DEC", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xce, name: "DEC", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0xde, name: "DEC", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),

    Opcode(value: 0xca, name: "DEX", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x88, name: "DEY", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0xc9, name: "CMP", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xc5, name: "CMP", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xd5, name: "CMP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xcd, name: "CMP", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0xdd, name: "CMP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X), // +1 if page crossed
    Opcode(value: 0xd9, name: "CMP", len: 3, cycles: 4, mode: AddressingMode.Absolute_Y), // +1 if page crossed
    Opcode(value: 0xc1, name: "CMP", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0xd1, name: "CMP", len: 2, cycles: 5, mode: AddressingMode.Indirect_Y), // +1 if page crossed

    Opcode(value: 0xc0, name: "CPY", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xc4, name: "CPY", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xcc, name: "CPY", len: 3, cycles: 4, mode: AddressingMode.Absolute),

    Opcode(value: 0xe0, name: "CPX", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xe4, name: "CPX", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xec, name: "CPX", len: 3, cycles: 4, mode: AddressingMode.Absolute),

        /* Branching */

    Opcode(value: 0x4c, name: "JMP", len: 3, cycles: 3, mode: AddressingMode.NoneAddressing), // AddressingMode that acts as Immediate
    Opcode(value: 0x6c, name: "JMP", len: 3, cycles: 5, mode: AddressingMode.NoneAddressing), // AddressingMode: Indirect with 6502 bug

    Opcode(value: 0x20, name: "JSR", len: 3, cycles: 6, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x60, name: "RTS", len: 1, cycles: 6, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0x40, name: "RTI", len: 1, cycles: 6, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0xd0, name: "BNE", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0x70, name: "BVS", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0x50, name: "BVC", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0x30, name: "BMI", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0xf0, name: "BEQ", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0xb0, name: "BCS", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0x90, name: "BCC", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page
    Opcode(value: 0x10, name: "BPL", len: 2, cycles: 2, mode: AddressingMode.NoneAddressing), // +1 if branch succeeds +2 if to a new page

    Opcode(value: 0x24, name: "BIT", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x2c, name: "BIT", len: 3, cycles: 4, mode: AddressingMode.Absolute),

    /* Stores, Loads */
    Opcode(value: 0xa9, name: "LDA", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xa5, name: "LDA", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xb5, name: "LDA", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xad, name: "LDA", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0xbd, name: "LDA", len: 3, cycles: 4, mode: AddressingMode.Absolute_X), // +1 if page crossed
    Opcode(value: 0xb9, name: "LDA", len: 3, cycles: 4, mode: AddressingMode.Absolute_Y), // +1 if page crossed
    Opcode(value: 0xa1, name: "LDA", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0xb1, name: "LDA", len: 2, cycles: 5, mode: AddressingMode.Indirect_Y), // +1 if page crossed

    Opcode(value: 0xa2, name: "LDX", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xa6, name: "LDX", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xb6, name: "LDX", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_Y),
    Opcode(value: 0xae, name: "LDX", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0xbe, name: "LDX", len: 3, cycles: 4, mode: AddressingMode.Absolute_Y), // +1 if page crossed

    Opcode(value: 0xa0, name: "LDY", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xa4, name: "LDY", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xb4, name: "LDY", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xac, name: "LDY", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0xbc, name: "LDY", len: 3, cycles: 4, mode: AddressingMode.Absolute_X), // +1 if page crossed

    Opcode(value: 0x85, name: "STA", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x95, name: "STA", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x8d, name: "STA", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x9d, name: "STA", len: 3, cycles: 5, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x99, name: "STA", len: 3, cycles: 5, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x81, name: "STA", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x91, name: "STA", len: 2, cycles: 6, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x86, name: "STX", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x96, name: "STX", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_Y),
    Opcode(value: 0x8e, name: "STX", len: 3, cycles: 4, mode: AddressingMode.Absolute),

    Opcode(value: 0x84, name: "STY", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x94, name: "STY", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x8c, name: "STY", len: 3, cycles: 4, mode: AddressingMode.Absolute),

    /*flags clear*/
    Opcode(value: 0xD8, name: "CLD", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x58, name: "CLI", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xB8, name: "CLV", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x18, name: "CLC", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x38, name: "SEC", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x78, name: "SEI", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xF8, name: "SED", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0xAA, name: "TAX", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xA8, name: "TAY", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xBA, name: "TSX", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x8A, name: "TXA", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x9A, name: "TXS", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x98, name: "TYA", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    /*stack*/
    Opcode(value: 0x48, name: "PHA", len: 1, cycles: 3, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x68, name: "PLA", len: 1, cycles: 4, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x08, name: "PHP", len: 1, cycles: 3, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x28, name: "PLP", len: 1, cycles: 4, mode: AddressingMode.NoneAddressing),
    
    /*unofficial*/
    Opcode(value: 0xc7, name: "*DCP", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xd7, name: "*DCP", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xCF, name: "*DCP", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0xdF, name: "*DCP", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),
    Opcode(value: 0xdb, name: "*DCP", len: 3, cycles: 7, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0xd3, name: "*DCP", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),
    Opcode(value: 0xc3, name: "*DCP", len: 2, cycles: 8, mode: AddressingMode.Indirect_X),

    Opcode(value: 0x27, name: "*RLA", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x37, name: "*RLA", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x2F, name: "*RLA", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x3F, name: "*RLA", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x3b, name: "*RLA", len: 3, cycles: 7, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x33, name: "*RLA", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),
    Opcode(value: 0x23, name: "*RLA", len: 2, cycles: 8, mode: AddressingMode.Indirect_X),

    Opcode(value: 0x07, name: "*SLO", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x17, name: "*SLO", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x0F, name: "*SLO", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x1f, name: "*SLO", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x1b, name: "*SLO", len: 3, cycles: 7, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x03, name: "*SLO", len: 2, cycles: 8, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x13, name: "*SLO", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x47, name: "*SRE", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x57, name: "*SRE", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x4F, name: "*SRE", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x5f, name: "*SRE", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x5b, name: "*SRE", len: 3, cycles: 7, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x43, name: "*SRE", len: 2, cycles: 8, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x53, name: "*SRE", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x80, name: "*NOP", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x82, name: "*NOP", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x89, name: "*NOP", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xc2, name: "*NOP", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0xe2, name: "*NOP", len: 2, cycles: 2, mode: AddressingMode.Immediate),

    Opcode(value: 0xCB, name: "*AXS", len: 2, cycles: 2, mode: AddressingMode.Immediate),

    Opcode(value: 0x6B, name: "*ARR", len: 2, cycles: 2, mode: AddressingMode.Immediate),

    Opcode(value: 0xeb, name: "*SBC", len: 2, cycles: 2, mode: AddressingMode.Immediate),

    Opcode(value: 0x0b, name: "*ANC", len: 2, cycles: 2, mode: AddressingMode.Immediate),
    Opcode(value: 0x2b, name: "*ANC", len: 2, cycles: 2, mode: AddressingMode.Immediate),

    Opcode(value: 0x4b, name: "*ALR", len: 2, cycles: 2, mode: AddressingMode.Immediate),

    Opcode(value: 0x04, name: "*NOP", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x44, name: "*NOP", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x64, name: "*NOP", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x14, name: "*NOP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x34, name: "*NOP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x54, name: "*NOP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x74, name: "*NOP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xd4, name: "*NOP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xf4, name: "*NOP", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x0c, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x1c, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x3c, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x5c, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x7c, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),
    Opcode(value: 0xdc, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),
    Opcode(value: 0xfc, name: "*NOP", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),

    Opcode(value: 0x67, name: "*RRA", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x77, name: "*RRA", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0x6f, name: "*RRA", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0x7f, name: "*RRA", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),
    Opcode(value: 0x7b, name: "*RRA", len: 3, cycles: 7, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x63, name: "*RRA", len: 2, cycles: 8, mode: AddressingMode.Indirect_X),
    Opcode(value: 0x73, name: "*RRA", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0xe7, name: "*ISB", len: 2, cycles: 5, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xf7, name: "*ISB", len: 2, cycles: 6, mode: AddressingMode.ZeroPage_X),
    Opcode(value: 0xef, name: "*ISB", len: 3, cycles: 6, mode: AddressingMode.Absolute),
    Opcode(value: 0xff, name: "*ISB", len: 3, cycles: 7, mode: AddressingMode.Absolute_X),
    Opcode(value: 0xfb, name: "*ISB", len: 3, cycles: 7, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0xe3, name: "*ISB", len: 2, cycles: 8, mode: AddressingMode.Indirect_X),
    Opcode(value: 0xf3, name: "*ISB", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x02, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x12, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x22, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x32, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x42, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x52, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x62, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x72, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x92, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xb2, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xd2, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xf2, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0x1a, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x3a, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x5a, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0x7a, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xda, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),
    Opcode(value: 0xfa, name: "*NOP", len: 1, cycles: 2, mode: AddressingMode.NoneAddressing),

    Opcode(value: 0xab, name: "*LXA", len: 2, cycles: 3, mode: AddressingMode.Immediate),
    Opcode(value: 0x8b, name: "*XAA", len: 2, cycles: 3, mode: AddressingMode.Immediate),
    Opcode(value: 0xbb, name: "*LAS", len: 3, cycles: 2, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x9b, name: "*TAS", len: 3, cycles: 2, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x93, name: "*AHX", len: 2, cycles: 8, mode: AddressingMode.Indirect_Y),
    Opcode(value: 0x9f, name: "*AHX", len: 3, cycles: 4, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x9e, name: "*SHX", len: 3, cycles: 4, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0x9c, name: "*SHY", len: 3, cycles: 4, mode: AddressingMode.Absolute_X),
    
    
    Opcode(value: 0xa7, name: "*LAX", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0xb7, name: "*LAX", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_Y),
    Opcode(value: 0xaf, name: "*LAX", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0xbf, name: "*LAX", len: 3, cycles: 4, mode: AddressingMode.Absolute_Y),
    Opcode(value: 0xa3, name: "*LAX", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),
    Opcode(value: 0xb3, name: "*LAX", len: 2, cycles: 5, mode: AddressingMode.Indirect_Y),

    Opcode(value: 0x87, name: "*SAX", len: 2, cycles: 3, mode: AddressingMode.ZeroPage),
    Opcode(value: 0x97, name: "*SAX", len: 2, cycles: 4, mode: AddressingMode.ZeroPage_Y),
    Opcode(value: 0x8f, name: "*SAX", len: 3, cycles: 4, mode: AddressingMode.Absolute),
    Opcode(value: 0x83, name: "*SAX", len: 2, cycles: 6, mode: AddressingMode.Indirect_X),

]



public func getOpcodesMap() ->  [UInt8:Opcode] {
    var opcode_map = [UInt8:Opcode]();
    for opcode in opcodes {
        opcode_map[opcode.value] = opcode;
    }
    return opcode_map;
}



