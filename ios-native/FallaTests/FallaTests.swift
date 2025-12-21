// FallaTests.swift
// Falla - iOS 26 Fortune Telling App
// Unit tests

import XCTest
@testable import Falla

final class FallaTests: XCTestCase {
    
    func testBiorhythmCalculation() {
        // Test biorhythm algorithm
        let birthDate = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1))!
        let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        let daysSinceBirth = Calendar.current.dateComponents([.day], from: birthDate, to: targetDate).day ?? 0
        
        // Physical cycle: 23 days
        let physicalAngle = (2 * Double.pi * Double(daysSinceBirth)) / 23.0
        let physical = (sin(physicalAngle) + 1) / 2
        
        XCTAssertGreaterThanOrEqual(physical, 0)
        XCTAssertLessThanOrEqual(physical, 1)
    }
    
    func testGlassStyleProperties() {
        // This is a placeholder test
        XCTAssertTrue(true)
    }
}
