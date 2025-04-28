import Foundation

final class Vault {
    private var savings: [String: Double] = [:]

    func isAccountAlreadyCreated(for titularity: String) -> Bool {
        savings[titularity] != nil
    }

    func accountBalance(for titularity: String) throws -> Double {
        guard isAccountAlreadyCreated(for: titularity) else {
            throw VaultError.accountNotFound
        }
        return savings[titularity, default: 0]
    }

    func createSavingsAccount(titularity: String) throws {
        guard !isAccountAlreadyCreated(for: titularity) else {
            throw VaultError.accountAlreadyExists
        }
        savings[titularity, default: 0] = 0
    }

    func deposit(order: Order) throws {
        guard isAccountAlreadyCreated(for: order.titularity) else {
            throw VaultError.accountNotFound
        }
        guard order.amount > 0 else {
            throw VaultError.invalidAmount
        }

        savings[order.titularity, default: 0] += order.amount
    }

    func withdraw(order: Order, completion: (Result<Void, VaultError>) -> Void) {
        guard isAccountAlreadyCreated(for: order.titularity) else {
            completion(.failure(.accountNotFound))
            return
        }
        do {
            let currentBalance = try accountBalance(for: order.titularity)
            guard currentBalance >= order.amount else {
                completion(.failure(.insufficientFunds))
                return
            }

            savings[order.titularity, default: 0] -= order.amount
            completion(.success(()))
        } catch let error as VaultError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknown))
        }
    }
}
