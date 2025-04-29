import Foundation

final actor Vault: VaultDefinition {
    private var savings: [String: Double] = [:]

    init() { }

    func isAccountAlreadyCreated(for titularity: String) async -> Bool {
        savings[titularity] != nil
    }

    func accountBalance(for titularity: String) async throws -> Double {
        guard await isAccountAlreadyCreated(for: titularity) else {
            throw VaultError.accountNotFound
        }
        return savings[titularity, default: 0]
    }

    func createSavingsAccount(titularity: String) async throws {
        guard await !isAccountAlreadyCreated(for: titularity) else {
            throw VaultError.accountAlreadyExists
        }
        return savings[titularity, default: 0] = 0
    }

    func deposit(order: Order) async throws {
        guard await isAccountAlreadyCreated(for: order.titularity) else {
            throw VaultError.accountNotFound
        }
        guard order.amount > 0 else {
            throw VaultError.invalidAmount
        }
        return savings[order.titularity, default: 0] += order.amount
    }

    func withdraw(order: Order, completion: @escaping (Result<Void, VaultError>) -> Void) async {
        guard await isAccountAlreadyCreated(for: order.titularity) else {
            completion(.failure(.accountNotFound))
            return
        }
        do {
            let currentBalance = try await self.accountBalance(for: order.titularity)
            guard currentBalance >= order.amount else {
                completion(.failure(.insufficientFunds))
                return
            }

            self.savings[order.titularity, default: 0] -= order.amount
            completion(.success(()))
        } catch {
            completion(.failure((error as? VaultError) ?? .unknown))
        }
    }
}
