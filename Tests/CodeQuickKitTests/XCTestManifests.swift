import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BundleTests.allTests),
        testCase(DateTests.allTests),
        testCase(EnvironmentTests.allTests),
        testCase(LocalizedStringExpressibleTests.allTests),
        testCase(LogTests.allTests),
        testCase(NumberFormatterTests.allTests),
        testCase(PausableTimerTests.allTests),
    ]
}
#endif
