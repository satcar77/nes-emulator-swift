//
//  inestest.swift
//  nesemuTests
//
//  Created by Dhakal, Satkar on 9/8/24.
//

import XCTest

@testable import nesemu





final class inestest: XCTestCase {
    
    func test() throws{

        let bundle = Bundle(for: type(of: self))
               
               // Locate the file in the bundle
               guard let filePath = bundle.path(forResource: "nestest", ofType: "nes") else {
                   XCTFail("File not found")
                   return
               }
        let fileURL = URL(fileURLWithPath: filePath);
        let data = try Data(contentsOf: fileURL);
        let rom = try Rom(raw:[UInt8](data));
        let bus = Bus(rom: rom);
        let cpu = CPU(bi_bus: bus);
        cpu.reset();
        cpu.pc = 0xC000;
        let logger = CpuLogger();
        var out = "";
        cpu.run_with_callback(
            callback : {
                out += logger.log(cpu: cpu);
            }
        )
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("Cannot find document dir");
            return
        }
        print(documentDirectory)
        let fileWURL = documentDirectory.appendingPathComponent("test.txt")
        try! out.write(to : fileWURL, atomically: true, encoding: .utf8)
        
    }
}
