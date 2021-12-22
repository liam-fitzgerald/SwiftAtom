//
//  File.swift
//  
//
//  Created by Liam Fitzgerald on 1/12/21.
//

import Foundation

import XCTest
import BigInt
import Parsing

@testable import UrbitAtom

final class PatpTest: XCTestCase {
    func testGalaxy() throws {
        guard let met = Patp(fromString: "~met") else {
            XCTFail();
            return;
        }
        XCTAssertEqual(met.value,  BigUInt(43));
        XCTAssertEqual(met.scot, "~met");
        XCTAssertEqual(met.clan, .czar)
    }
    
    func testStar() throws {
        let star = Patp(fromString: "~dopmet");
        XCTAssertEqual(star!.value.asBytes(), [0x2b, 0x12]);
        XCTAssertEqual(star!.clan, .king);
        let one = Patp(fromString: "~hastuc")
        XCTAssertEqual(star!.scot, "~dopmet");
    }
    
    func testPlanet() throws {
        let str = "~hastuc-dibtux";
        let planet = Patp(fromString: str);
        XCTAssertEqual(BigUInt("3248095670"), planet!.value);
        XCTAssertEqual(planet!.clan, .duke);
        XCTAssertEqual(planet!.scot, str);
    }
    
    func testBytes () throws {
        let num = BigUInt(65535);
        XCTAssertEqual([255, 255], num.asBytes())
        let foo = BigUInt(29485);
        XCTAssertEqual([0x2D, 0x73], foo.asBytes())
        
    }
    
    
}


