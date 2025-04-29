import Foundation

protocol VaultDefinition {
    func isAccountAlreadyCreated(for titularity: String) async -> Bool
    func accountBalance(for titularity: String) async throws -> Double
    func createSavingsAccount(titularity: String) async throws
    func deposit(order: Order) async throws
    func withdraw(order: Order, completion: @escaping (Result<Void, VaultError>) -> Void) async
}
