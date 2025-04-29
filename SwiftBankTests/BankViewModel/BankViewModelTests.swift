import XCTest
@testable import SwiftBank

final class BankViewModelTests: XCTestCase {
    var sut: BankViewModel!
    var stub: VaultStub!

    override func setUp() {
        stub = VaultStub()
        sut = BankViewModel(vault: stub)
    }

    override func tearDown() {
        sut = nil
        stub = nil
    }

    func test_createSavingsAccount() async throws {
        // Given
        let titularity = "John Doe"

        // Then
        do {
            try await sut.createSavingsAccount(titularity: titularity)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_createSavingsAccount_accountAlreadyExists() async throws {
        // Given
        let titularity = "John Doe"

        // When
        await try sut.createSavingsAccount(titularity: titularity)
        stub.shouldThrowError = VaultError.accountAlreadyExists

        // Then
        do {
            try await sut.createSavingsAccount(titularity: titularity)
        } catch {
            XCTAssertEqual(error as? VaultError, .accountAlreadyExists)
        }
    }

    func test_deposit() async throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        stub.accountBalanceResult = amount

        // When
        try await sut.createSavingsAccount(titularity: titularity)
        try await sut.deposit(order: order)
        
        // Then
        let optionalResult = try? await sut.balance(for: titularity)
        let result = try XCTUnwrap(optionalResult)
        XCTAssertEqual(result, amount)
    }

    func test_deposit_accountNotFound() async throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        stub.shouldThrowError = VaultError.accountNotFound

        // Then
        do {
            try await sut.deposit(order: order)
        } catch {
            XCTAssertEqual(error as? VaultError, .accountNotFound)
        }
    }

    func test_deposit_invalidAmount() async throws {
        // Given
        let titularity = "John Doe"
        let amount = -100.0
        let order = Order(amount: amount, titularity: titularity)

        try await sut.createSavingsAccount(titularity: titularity)
        stub.shouldThrowError = VaultError.invalidAmount

        // Then
        do {
            try await sut.deposit(order: order)
        } catch {
            XCTAssertEqual(error as? VaultError, .invalidAmount)
        }
    }

    func test_withdraw() async throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        let expectation = expectation(description: "Withdraw completion")

        try await sut.createSavingsAccount(titularity: titularity)
        try await sut.deposit(order: order)
        stub.withdrawResult = .success(())

        // When
        await sut.withdraw(order: order) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])

        let optionalResult = try? await sut.balance(for: titularity)
        let result = try XCTUnwrap(optionalResult)
        XCTAssertEqual(result, 0)
    }

    func test_withdraw_insufficientFunds() async throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        let expectation = expectation(description: "Withdraw completion")
        var error: VaultError?

        try await sut.createSavingsAccount(titularity: titularity)
        stub.withdrawResult = .failure(.insufficientFunds)

        // When
        await sut.withdraw(order: order) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let vaultError):
                error = vaultError
            }
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])
        XCTAssertEqual(error, .insufficientFunds)
    }

    func test_withdraw_invalidAccount() async throws {
        // Given
        let titularity = "John Doe"
        let amount = 100.0
        let order = Order(amount: amount, titularity: titularity)
        let expectation = expectation(description: "Withdraw completion")
        var error: VaultError?
        stub.withdrawResult = .failure(.accountNotFound)

        // When
        await sut.withdraw(order: order) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let vaultError):
                error = vaultError
            }
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])
        XCTAssertEqual(error, .accountNotFound)
    }

    func test_balance_accountNotFound() async throws {
        // Given
        let titularity = "John Doe"
        stub.shouldThrowError = VaultError.accountNotFound

        // Then
        do {
            _ = try await sut.balance(for: titularity)
        } catch {
            XCTAssertEqual(error as? VaultError, .accountNotFound)
        }
    }
}
