//
//  nesemuTests.swift
//  nesemuTests
//
//  Created by Dhakal, Satkar on 8/20/24.
//

import XCTest
@testable import nesemu




final class CpuTests: XCTestCase {
    
    
    func make_cpu(raw:[UInt8]) -> CPU{
        
        let header: [UInt8] =  [
            0x4E, 0x45, 0x53, 0x1A, 0x02, 0x01, 0x31, 00, 00, 00, 00, 00, 00, 00, 00, 00,
        ];
        var prg_rom: [UInt8] = Array(repeating: 1, count: 2 * Rom.PRG_ROM_PAGE_SIZE)
        prg_rom[0..<raw.count] =  raw[0..<raw.count];
        let romb = header + prg_rom + Array(repeating: 2, count: 1 * Rom.CHR_ROM_PAGE_SIZE);
        let rom =  try! Rom(raw:romb);
        let bus = Bus(rom: rom);
        let cpu =  CPU(bi_bus: bus);
        cpu.pc = 0x8000;
        return cpu
    }
    
    
    override func setUpWithError() throws {
    
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_0xa9_lda_immediate_load_data() throws {
        let program : [UInt8] = [0xa9, 0x05, 0x00];
        let cpu = self.make_cpu(raw: program);
        cpu.run()
        XCTAssertEqual(cpu.register_a,0x05);
        XCTAssert(!cpu.status.contains(.zero));
        XCTAssert(!cpu.status.contains(.negative));
    }
    
    func test_jmp_indirect() throws {
        var program : [UInt8] = Array(repeating: 0, count: 0x0400);
        program[0..<3] = [0x6c, 0xff, 0x02,0x00];
        let cpu = self.make_cpu(raw: program);
        cpu.mem_write_u16(addr: 0x02FF, data: 0x0300);
        let val = cpu.mem_read_16(addr: 0x02FF);
        XCTAssertEqual(val, 0x0300);
        cpu.mem_write_u16(addr: 0x0300, data: 0xa969);
        let val2 = cpu.mem_read_16(addr: 0x0300);
        XCTAssertEqual(val2,0xa969);
        let logger = CpuLogger();
        cpu.run_with_callback(callback: {
            print(logger.log(cpu: cpu))
        })
    }
    
//    func test_0xa9_lda_zero_flag(){
//        self.cpu.load_run(program : [0xa9, 0x00, 0x00]);
//        XCTAssert(cpu.status.contains(.zero));
//    }
//    
//    func test_mem_idx(){
//        self.cpu.load(program: [0xa9,0xc7,0x00]);
//        self.cpu.mem_write_u16(addr: 0x6000, data: 0xf0f2);
//        XCTAssertEqual(self.cpu.bus.ram[Int(0x6000)], 0xf2);
//        XCTAssertEqual(self.cpu.bus.ram[Int(0x6001)], 0xf0);
//        XCTAssertEqual(self.cpu.mem_read_16(addr: 0x6000), 0xf0f2)
//    }
//    
//    func test_mem_read(){
//        self.cpu.load(program: [0xa9,0x00,0x00]);
//        self.cpu.reset();
//        XCTAssertEqual(self.cpu.mem_read_16(addr: 0xFFFC), 0x0600);
//        XCTAssertEqual(cpu.pc, 0x0600);
//    }
//    
//    func test_tax(){
//        self.cpu.load_run(program: [0xa9, 0xc7,0xaa, 0x00]);
//        XCTAssertEqual(self.cpu.register_x,0xc7);
//    }
//    
//    func test_tax_inc(){
//        self.cpu.load_run(program: [0xa9, 0xc0, 0xaa, 0xe8, 0x00]);
//        XCTAssertEqual(self.cpu.register_x,0xc1);
//    }
//    
//    func test_inx_overflow(){
//        self.cpu.load_run(program: [0xa2,0xff,0xe8,0xe8,0x00]);
//        XCTAssertEqual(self.cpu.register_x, 1);
//    }
//    
//    func test_lda_mem(){
//        self.cpu.mem_write(addr: 0x10, data: 0x55);
//        self.cpu.load_run(program: [0xa5,0x10,0x00]);
//        XCTAssertEqual(self.cpu.register_a, 0x55);
//    }
//    
//    func test_stack(){
//        let stl = self.cpu.sp;
//        self.cpu.stack_push(data: 0x55);
//        XCTAssertEqual(self.cpu.sp, stl - 1 );
//        XCTAssertEqual(self.cpu.stack_pop(), 0x55);
//        XCTAssertEqual(stl, self.cpu.sp);
//    }
//    
//    func test_branch(){
//        self.cpu.pc =  0x06CC;
//        self.cpu.mem_write(addr: 0x06CC, data: 0xf9);
//        self.cpu.branch(cond: true)
//        XCTAssertEqual(self.cpu.pc, 0x06C6);
//    }
//    
//    func test_sbc(){
//        self.cpu.load(program: [0xa9,80,0xe9,48,0x00]);
//        self.cpu.status.insert(.carry);
//        self.cpu.run()
//        XCTAssert(self.cpu.status.contains(.carry));
//        XCTAssertEqual(self.cpu.register_a, 32);
//        
//        self.cpu.load(program: [0xa9,0x50,0xe9,0xf0,0x00]);
//        self.cpu.status.insert(.carry);
//        self.cpu.run()
////        XCTAssert(!self.cpu.status.contains(.carry));
//        XCTAssertEqual(self.cpu.register_a, 0x60);
//    }

}
