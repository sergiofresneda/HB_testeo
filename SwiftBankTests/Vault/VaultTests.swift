
import XCTest
@testable import SwiftBank

@preconcurrency
final class VaultTests: XCTestCase {
    var sut: Vault!

    override func setUp() {
        sut = Vault()
    }

    override func tearDown() {
        sut = nil
    }

    func test_isAccountAlreadyCreated() async {
        // Given
        let titularity = "Sergio"

        // When
        let result = await sut.isAccountAlreadyCreated(for: titularity)

        // Then
        XCTAssertFalse(result)
    }

    func test_isAccounAlreadyCreated_returnTrue() async throws {
        // Given
        let titularity = "Sergio"

        // When
        try await sut.createSavingsAccount(titularity: titularity)
        let result = await sut.isAccountAlreadyCreated(for: titularity)

        // Then
        XCTAssertTrue(result)
    }

    func test_accountBalance() async throws {
        // Given
        let titularity = "Sergio"
        let expectedResult: Double = .zero

        // When
        try await sut.createSavingsAccount(titularity: titularity)
        let result = try await sut.accountBalance(for: titularity)

        // Then
        XCTAssertEqual(result, expectedResult)
    }

    func test_accountBalance_throws() async {
        // Given
        let titularity = "Sergio"

        // When
        // Then
        do {
            _ = try await sut.accountBalance(for: titularity)
        } catch {
            XCTAssertEqual(error as? VaultError, .accountNotFound)
        }
    }

    func test_createSavingsAccount() async {
        // Given
        let titularity = "Sergio"

        // When
        // Then
        do {
            try await sut.createSavingsAccount(titularity: titularity)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_createSavingsAccount_throws() async throws {
        // Given
        let titularity = "Sergio"

        // When
        // Then
        try await sut.createSavingsAccount(titularity: titularity)
        do {
            try await sut.createSavingsAccount(titularity: titularity)
        } catch {
            XCTAssertEqual(error as? VaultError, .accountAlreadyExists)
        }
    }

    func test_deposit() async throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)

        try await sut.createSavingsAccount(titularity: titularity)
        // When
        // Then
        do {
            try await sut.deposit(order: order)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deposit_throwsAccountNotFound() async throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)

        // When
        // Then
        do {
            try await sut.deposit(order: order)
        } catch {
            XCTAssertEqual(error as? VaultError, .accountNotFound)
        }
    }

    func test_deposit_throwsInvalidAmount() async throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = .zero
        let order = Order(amount: amount, titularity: titularity)

        try await sut.createSavingsAccount(titularity: titularity)

        // When
        // Then
        do {
            try await sut.deposit(order: order)
        } catch {
            XCTAssertEqual(error as? VaultError, .invalidAmount)
        }
    }

    func test_withdraw() async throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)
        let expectation = XCTestExpectation(description: "withdraw")
        try await sut.createSavingsAccount(titularity: titularity)
        try await sut.deposit(order: order)

        // When
        await sut.withdraw(order: order, completion: { result in
            switch result {
            case .failure:
                XCTFail("Unexpected result")
            default:
                break
            }
            expectation.fulfill()
        })

        // Then

        await fulfillment(of: [expectation])
    }

    func test_withdraw_throwsAccountNotFound() async throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)
        let expectation = XCTestExpectation(description: "withdraw throws")
        let expectedError = VaultError.accountNotFound
        var error: VaultError?

        // When
        await sut.withdraw(order: order) { result in
            switch result {
            case .failure(let withdrawError):
                error = withdrawError
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])
        XCTAssertEqual(error, expectedError)
    }

    func test_withdraw_throwsInsufficientFunds() async throws {
        // Given
        let titularity = "Sergio"
        let amount: Double = 100
        let order = Order(amount: amount, titularity: titularity)
        let withdrawOrder = Order(amount: 101, titularity: titularity)
        let expectation = XCTestExpectation(description: "withdraw throws")
        let expectedError = VaultError.insufficientFunds
        var error: VaultError?

        try await sut.createSavingsAccount(titularity: titularity)
        try await sut.deposit(order: order)

        // When
        await sut.withdraw(order: withdrawOrder) { result in
            switch result {
            case .failure(let withdrawError):
                error = withdrawError
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation])
        XCTAssertEqual(error, expectedError)
    }

    // MARK: - Thread Safe Tests

    func test_depositAndWithdraw() async throws {
        // Given
        let iterations = 100
        let titularity = "Sergio"
        try? await sut.createSavingsAccount(titularity: titularity)
        let expectation = XCTestExpectation(description: "depositAndWithdraw")
        expectation.expectedFulfillmentCount = iterations

        // When
        DispatchQueue.concurrentPerform(iterations: iterations) { some in
            Task {
                let amount: Double = Double.random(in: 10..<100) * Double(some)
                let order = Order(amount: amount, titularity: titularity)
                do {
                    let balance = try await sut.accountBalance(for: titularity)
                    print("🔴 \(balance)")

                    try await sut.deposit(order: order)
                    await sut.withdraw(order: order) { result in
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
        }

        // Then
        await fulfillment(of: [expectation])
    }
}
