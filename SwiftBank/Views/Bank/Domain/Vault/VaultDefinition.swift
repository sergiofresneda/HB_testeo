import Foundation

protocol VaultDefinition {
    func isAccountAlreadyCreated(for titularity: String) -> Bool
    func accountBalance(for titularity: String) throws -> Double
    func createSavingsAccount(titularity: String) throws
    func deposit(order: Order) throws
    func withdraw(order: Order, completion: @escaping (Result<Void, VaultError>) -> Void)
}
