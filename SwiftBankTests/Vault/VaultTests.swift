
import XCTest
@testable import SwiftBank

final class VaultTests: XCTestCase {
    var sut: Vault!

    override func setUp() {
        sut = Vault()
    }

    override func tearDown() {
        sut = nil
    }

    func test_isAccountAlreadyCreated() {
        // Given
        let titularity = "Sergio"

        // When
        let result = sut.isAccountAlreadyCreated(for: titularity)

        // Then
        XCTAssertFalse(result)
    }

    func test_isAccounAlreadyCreated_returnTrue() throws {
        // Given
        let titularity = "Sergio"

        // When
        try sut.createSavingsAccount(titularity: titularity)
        let result = sut.isAccountAlreadyCreated(for: titularity)

        // Then
        XCTAssertTrue(result)
    }

    func test_accountBalance() throws {
        // Given
        let titularity = "Sergio"
        let expectedResult: Double = .zero

        // When
        try sut.createSavingsAccount(titularity: titularity)
        let result = try sut.accountBalance(for: titularity)

        // Then
        XCTAssertEqual(result, expectedResult)
    }

    func test_accountBalance_throws() {
        // Given
        let titularity = "Sergio"

        // When
        // Then
        XCTAssertThrowsError(try sut.accountBalance(for: titularity))
    }

    func test_createSavingsAccount() {
        // Given
        let titularity = "Sergio"

        // When
        // Then
        XCTAssertNoThrow(try sut.createSavingsAccount(titularity: titularity)
        )
    }

    func test_createSavingsAccount_throws() throws {
        // Given
        let titularity = "Sergio"

        // When
        // Then
        try sut.createSavingsAccount(titularity: titularity)
        XCTAssertThrowsError(try sut.createSavingsAccount(titularity: titularity))
    }

    func test_deposit() throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)

        try sut.createSavingsAccount(titularity: titularity)
        // When
        // Then
        XCTAssertNoThrow(try sut.deposit(order: order))
    }

    func test_deposit_throwsAccountNotFound() throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)

        // When
        // Then
        XCTAssertThrowsError(try sut.deposit(order: order))
    }

    func test_deposit_throwsInvalidAmount() throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = .zero
        let order = Order(amount: amount, titularity: titularity)

        try sut.createSavingsAccount(titularity: titularity)

        // When
        // Then
        XCTAssertThrowsError(try sut.deposit(order: order))
    }

    func test_withdraw() throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)
        let expectation = XCTestExpectation(description: "withdraw")
        try sut.createSavingsAccount(titularity: titularity)
        try sut.deposit(order: order)

        // When
        sut.withdraw(order: order, completion: { result in
            switch result {
            case .failure:
                XCTFail("Unexpected result")
            default:
                break
            }
            expectation.fulfill()
        })

        // Then

        wait(for: [expectation])
    }

    func test_withdraw_throwsAccountNotFound() throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)
        let expectation = XCTestExpectation(description: "withdraw throws")
        let expectedError = VaultError.accountNotFound
        var error: VaultError?

        // When
        sut.withdraw(order: order) { result in
            switch result {
            case .failure(let withdrawError):
                error = withdrawError
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertEqual(error, expectedError)
    }

    func test_withdraw_throwsInsufficientFunds() throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)
        let withdrawOrder = Order(amount: 101, titularity: titularity)
        let expectation = XCTestExpectation(description: "withdraw throws")
        let expectedError = VaultError.insufficientFunds
        var error: VaultError?

        try sut.createSavingsAccount(titularity: titularity)
        try sut.deposit(order: order)

        // When
        sut.withdraw(order: withdrawOrder) { result in
            switch result {
            case .failure(let withdrawError):
                error = withdrawError
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation])
        XCTAssertEqual(error, expectedError)
    }

    // MARK: - Thread Safe Tests

    func test_depositAndWithdraw() throws {
        // Given
        let iterations = 100
        let titularity = "Sergio"
        try? sut.createSavingsAccount(titularity: titularity)
        let expectation = XCTestExpectation(description: "depositAndWithdraw")
        expectation.expectedFulfillmentCount = iterations

        // When
        DispatchQueue.concurrentPerform(iterations: iterations) { some in
            let amount: Double = Double.random(in: 10..<100) * Double(some)
            let order = Order(amount: amount, titularity: titularity)
            do {
                let balance = try sut.accountBalance(for: titularity)
                print("🔴 \(balance)")

                try sut.deposit(order: order)
                sut.withdraw(order: order) { result in
                    switch result {
                    default:
                        break
                    }
                }
            } catch {
                // Silence is golden
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}
