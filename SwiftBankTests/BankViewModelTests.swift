import XCTest
@testable import SwiftBank

final class BankViewModelTests: XCTestCase {
    var sut: BankViewModel!

    override func setUp() {
        sut = BankViewModel()
    }

    override func tearDown() {
        sut = nil
    }

    func test_createSavingsAccount() throws {
        // Given
        let titularity = "John Doe"

        // Then
        XCTAssertNoThrow(try sut.createSavingsAccount(titularity: titularity))
    }

    func test_createSavingsAccount_accountAlreadyExists() throws {
        // Given
        let titularity = "John Doe"

        // When
        try sut.createSavingsAccount(titularity: titularity)

        // Then
        XCTAssertThrowsError(try sut.createSavingsAccount(titularity: titularity))
    }

    func test_deposit() throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)

        // When
        try sut.createSavingsAccount(titularity: titularity)
        try sut.deposit(order: order)

        // Then
        let optionalResult = try? sut.balance(for: titularity)
        let result = try XCTUnwrap(optionalResult)
        XCTAssertEqual(result, amount)
    }

    func test_deposit_invalidAccount() throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)

        // Then
        XCTAssertThrowsError(try sut.deposit(order: order))
    }

    func test_deposit_invalidAmount() throws {
        // Given
        let titularity = "John Doe"
        let amount = -100.0
        let order = Order(amount: amount, titularity: titularity)

        try sut.createSavingsAccount(titularity: titularity)

        // Then
        XCTAssertThrowsError(try sut.deposit(order: order))
    }

    func test_withdraw() throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        let expectation = expectation(description: "Withdraw completion")

        try sut.createSavingsAccount(titularity: titularity)
        try sut.deposit(order: order)

        // When
        sut.withdraw(order: order) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)

        let optionalResult = try? sut.balance(for: titularity)
        let result = try XCTUnwrap(optionalResult)
        XCTAssertEqual(result, 0)
    }

    func test_withdraw_insufficientFunds() throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        let expectation = expectation(description: "Withdraw completion")
        var error: VaultError?

        try sut.createSavingsAccount(titularity: titularity)

        // When
        sut.withdraw(order: order) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let vaultError):
                error = vaultError
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(error, .insufficientFunds)
    }

    func test_withdraw_invalidAccount() throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        let expectation = expectation(description: "Withdraw completion")
        var error: VaultError?

        // When
        sut.withdraw(order: order) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let vaultError):
                error = vaultError
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(error, .accountNotFound)
    }

    func test_balance_accountNotFound() throws {
        // Given
        let titularity = "John Doe"

        // Then
        XCTAssertThrowsError(try sut.balance(for: titularity))
    }
}
