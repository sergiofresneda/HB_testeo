import Foundation

final class Vault: VaultDefinition {
    private var savings: [String: Double] = [:]
    private let syncQueue: DispatchQueue = DispatchQueue(label: "VaultQueue")
    private let dispatchKey: DispatchSpecificKey<Void> = DispatchSpecificKey<Void>()

    init() {
        syncQueue.setSpecific(key: dispatchKey, value: ())
    }

    func isAccountAlreadyCreated(for titularity: String) -> Bool {
        performSync {
            savings[titularity] != nil
        }
    }

    func accountBalance(for titularity: String) throws -> Double {
        guard isAccountAlreadyCreated(for: titularity) else {
            throw VaultError.accountNotFound
        }
        return performSync {
            savings[titularity, default: 0]
        }
    }

    func createSavingsAccount(titularity: String) throws {
        guard !isAccountAlreadyCreated(for: titularity) else {
            throw VaultError.accountAlreadyExists
        }
        return performSync {
            savings[titularity, default: 0] = 0
        }
    }

    func deposit(order: Order) throws {
        guard isAccountAlreadyCreated(for: order.titularity) else {
            throw VaultError.accountNotFound
        }
        guard order.amount > 0 else {
            throw VaultError.invalidAmount
        }
        return performSync {
            savings[order.titularity, default: 0] += order.amount
        }
    }

    func withdraw(order: Order, completion: @escaping (Result<Void, VaultError>) -> Void) {
        guard isAccountAlreadyCreated(for: order.titularity) else {
            completion(.failure(.accountNotFound))
            return
        }
        performSync {
            do {
                let currentBalance = try self.accountBalance(for: order.titularity)
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
}
private extension Vault {
    func performSync<T>(_ block: () -> T) -> T {
        if DispatchQueue.getSpecific(key: dispatchKey) != nil {
                return block()
        } else {
            return syncQueue.sync(execute: block)
        }
    }
}
