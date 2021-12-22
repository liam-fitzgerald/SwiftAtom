import XCTest
import BigInt
import Parsing

@testable import UrbitAtom

final class UrbitAtomTests: XCTestCase {
    
    func testPatdaParse() throws {
        let str = "~2021.1.1..00.00.00";
        let da = Patda(fromString:str);
        let ud = BigUInt("170141184504841449916980385121776435200");
        XCTAssertEqual(da!.value, ud);
        XCTAssertEqual(da!.scot, str);
                       
    }
    
    func testPatdaParseTwo() throws {
        let str = "~2021.11.30..22.03.41..b8ed";
        let da = Patda(fromString:str);
        let ud =  BigUInt("170141184505373649952260282331988754432");
        XCTAssertNotNil(da);
        print("Diff");
        print(ud - da!.value);
        XCTAssertEqual(da!.value, ud);
        XCTAssertEqual(da!.minutes, 3);
        XCTAssertEqual(da!.year, 2021);
        XCTAssertEqual(da!.scot, str);
    }
    
    func testYawn() throws {
        let epoch = BigUInt("292277024400");
        let year = epoch + BigUInt("2021");
        print(year);
        let days = yawn(day: 1, month: 1, year: year);
        print("c");
        XCTAssertEqual(days, BigUInt("106751991822573"));
    }
}
