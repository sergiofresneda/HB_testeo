import Foundation

final class BankViewModel {
    private let vault: VaultDefinition

    init(vault: VaultDefinition = Vault()) {
        self.vault = vault
    }

    func createSavingsAccount(titularity: String) throws {
        try vault.createSavingsAccount(titularity: titularity)
    }

    func deposit(order: Order) throws {
        try vault.deposit(order: order)
    }

    func withdraw(order: Order, completion: (Result<Void, VaultError>) -> Void) {
        vault.withdraw(order: order, completion: completion)
    }

    func balance(for titularity: String) throws -> Double {
        try vault.accountBalance(for: titularity)
    }
}
