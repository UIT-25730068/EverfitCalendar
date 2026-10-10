//
//  WorkoutsAPIClientTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class URLProtocolStub: URLProtocol {
    static var handler: ((URLRequest) throws -> (Int, Data, Bool))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = URLProtocolStub.handler else { return }
        do {
            let (status, data, isHTTP) = try handler(request)
            if isHTTP {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: status,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            } else {
                let response = URLResponse(
                    url: request.url!,
                    mimeType: nil,
                    expectedContentLength: data.count,
                    textEncodingName: nil
                )
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class WorkoutsAPIClientTests: XCTestCase {

    private var client: WorkoutsAPIClient!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        client = WorkoutsAPIClient(session: session, url: URL(string: "https://mock.internalef.com/workouts")!)
    }

    override func tearDown() {
        URLProtocolStub.handler = nil
        super.tearDown()
    }

    func testDecodesSuccessfulPayload() async throws {
        URLProtocolStub.handler = { _ in
            (200, Self.sampleJSON, true)
        }

        let dto = try await client.fetchWorkouts()
        XCTAssertEqual(dto.data.count, 1)
        XCTAssertEqual(dto.data.first?.assignments.first?.title, "Legs day")
        XCTAssertEqual(dto.data.first?.assignments.first?.totalExercise, 5)
    }

    func testNon2xxThrowsHTTPStatus() async {
        URLProtocolStub.handler = { _ in
            (500, Data("{}".utf8), true)
        }

        do {
            _ = try await client.fetchWorkouts()
            XCTFail("Expected failure")
        } catch let error as WorkoutsError {
            if case .httpStatus(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected httpStatus, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testInvalidJSONThrowsDecoding() async {
        URLProtocolStub.handler = { _ in
            (200, Data("not-json".utf8), true)
        }

        do {
            _ = try await client.fetchWorkouts()
            XCTFail("Expected failure")
        } catch let error as WorkoutsError {
            if case .decoding = error {
                XCTAssertNotNil(error.underlying)
            } else {
                XCTFail("Expected decoding, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testTimeoutMapsToNetwork() async {
        URLProtocolStub.handler = { _ in
            throw URLError(.timedOut)
        }

        do {
            _ = try await client.fetchWorkouts()
            XCTFail("Expected failure")
        } catch let error as WorkoutsError {
            if case .network(let urlError) = error {
                XCTAssertEqual(urlError.code, .timedOut)
            } else {
                XCTFail("Expected network, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testCancellationMapsToCancelled() async {
        URLProtocolStub.handler = { _ in
            throw URLError(.cancelled)
        }

        do {
            _ = try await client.fetchWorkouts()
            XCTFail("Expected failure")
        } catch let error as WorkoutsError {
            XCTAssertTrue(error.isCancelled)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testNonHTTPResponseThrowsInvalidResponse() async {
        URLProtocolStub.handler = { _ in
            (200, Data(), false)
        }

        do {
            _ = try await client.fetchWorkouts()
            XCTFail("Expected failure")
        } catch let error as WorkoutsError {
            if case .invalidResponse = error {
                return
            }
            XCTFail("Expected invalidResponse, got \(error)")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    private static let sampleJSON = Data("""
    {
      "data": [
        {
          "_id": "d0",
          "day": 0,
          "assignments": [
            { "_id": "a0", "title": "Legs day", "status": 1, "total_exercise": 5 }
          ]
        }
      ]
    }
    """.utf8)
}
