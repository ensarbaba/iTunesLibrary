//
//  MainItemsViewModelTest.swift
//  iTunesLibraryUnitTests
//
//  Created by Ensar Baba on 11.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import XCTest
@testable import iTunesLibrary

class MainItemsViewModelTest: XCTestCase {
   //Subject under Test
    var sut: MainItemsViewModel!
    
    fileprivate var mockAPIService: DummyAPIClient!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        mockAPIService = DummyAPIClient()
        sut = MainItemsViewModel(apiService: mockAPIService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockAPIService = nil
        super.tearDown()

    }
    func testSearchAPIHit() {
        // When
        sut.fetchItemsWith(term: "radiohead", mediaType: "all")
        
        // Assert
        XCTAssert(mockAPIService!.isSearchItemCalled)
    }
    
    func testFetchWithNoService() {
        
        let expectation = XCTestExpectation(description: "No service")
        
        // giving no service to a view model
        sut.apiService = nil
        
        // expected to not be able to fetch items
        sut.showAlertClosure = {  () in
            expectation.fulfill()
        }
        sut.fetchItemsWith(term: "radiohead", mediaType: "all")
        wait(for: [expectation], timeout: 10.0)
    }
    func testFetchingItems() {
        
        let expectation = XCTestExpectation(description: "iTunes items fetch")
        sut = MainItemsViewModel(apiService: APIClient.shared)

        sut.showAlertClosure = {
            XCTAssert(false, "Some error occured")
        }
        sut.reloadTableViewClosure = { [weak self] in
            guard let self = self else {return}
            if self.sut.numberOfItems > 0 {
                expectation.fulfill()
            }
        }
        sut.fetchItemsWith(term: "radiohead", mediaType: "all")

        wait(for: [expectation], timeout: 10.0)
    }
    func testActivityIndicator() {
        //Given
        let expect = XCTestExpectation(description: "Loading status updated")
        sut.updateLoadingStatus = { _ in
            expect.fulfill()
        }
        //when fetching
        sut.fetchItemsWith(term: "radiohead", mediaType: "all")
        
        wait(for: [expect], timeout: 1.0)
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate class DummyAPIClient: APIClientProtocol {
    
    var isSearchItemCalled = false
    var completeClosure: ((Bool, String?, SearchResponse?) -> ())!
    
    func search(term: String, mediaType: String, completion: @escaping (Bool, String?, SearchResponse?) -> ()) {
        isSearchItemCalled = true
        completeClosure = completion
    }
}
