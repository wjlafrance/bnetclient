import XCTest

class StringReverseTest: XCTestCase {

    func testStringByReversingString() {
        let value: NSString = "this is a test string"
        XCTAssert("gnirts tset a si siht" == value.stringByReversingString())
    }

}
