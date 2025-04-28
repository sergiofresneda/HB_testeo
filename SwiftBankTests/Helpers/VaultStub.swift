import Foundation
@testable import SwiftBank

final class VaultStub: VaultDefinition {
    var isAccountAlreadyCreatedResult: Bool = false
    var accountBalanceResult: Double = 0
    var shouldThrowError: VaultError?
    var withdrawResult: Result<Void, VaultError> = .failure(.unknown)

    init() {}

    func isAccountAlreadyCreated(for titularity: String) -> Bool {
        isAccountAlreadyCreatedResult
    }

    func accountBalance(for titularity: String) throws -> Double {
        if let error = shouldThrowError {
            throw error
        }

        return accountBalanceResult
    }

    func createSavingsAccount(titularity: String) throws {
        if let error = shouldThrowError {
            throw error
        }
    }

    func deposit(order: Order) throws {
        if let error = shouldThrowError {
            throw error
        }
    }

    func withdraw(order: Order, completion: (Result<Void, VaultError>) -> Void) {
        completion(withdrawResult)
    }
}
