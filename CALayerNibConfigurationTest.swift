import XCTest
import UIKit
import QuartzCore

class CALayerNibConfigurationTest: XCTestCase {

    let layer = CALayer()

    func testSetGetBorderUIColor() {
        let color = UIColor.redColor()

        XCTAssert(layer.borderUIColor != color, "shouldn't start out with this color")

        layer.borderUIColor = color
        XCTAssert(layer.borderUIColor == color, "should have this color after being set")
    }

}
