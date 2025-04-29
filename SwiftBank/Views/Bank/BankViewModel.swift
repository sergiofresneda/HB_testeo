import Foundation

final class BankViewModel {
    private let vault: VaultDefinition

    init(vault: VaultDefinition = Vault()) {
        self.vault = vault
    }

    func createSavingsAccount(titularity: String) async throws {
        try await vault.createSavingsAccount(titularity: titularity)
    }

    func deposit(order: Order) async throws {
        try await vault.deposit(order: order)
    }

    func withdraw(order: Order, completion: @escaping (Result<Void, VaultError>) -> Void) async {
        await vault.withdraw(order: order, completion: completion)
    }

    func balance(for titularity: String) async throws -> Double {
        try await vault.accountBalance(for: titularity)
    }
}
