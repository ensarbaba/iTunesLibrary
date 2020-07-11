//
//  APIClientTest.swift
//  iTunesLibraryUnitTests
//
//  Created by Ensar Baba on 11.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import XCTest
@testable import iTunesLibrary

class APIClientTest: XCTestCase {
    
    //Subject under Test
    var sut: APIClient?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = APIClient.shared
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }
    
    func testItemsFetching() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // API Service Instance
        let sut = self.sut!
        
        // When searching an iTunes item
        let expect = XCTestExpectation(description: "callback")
        sut.search(term: "radiohead") { (success, message, itemsResponse) in
            expect.fulfill()
            XCTAssertEqual(itemsResponse?.resultCount, 100)
            for item in (itemsResponse?.results)! {
                XCTAssertNotNil(item.trackId)
            }
        }
        wait(for: [expect], timeout: 10.0)
    }
}
