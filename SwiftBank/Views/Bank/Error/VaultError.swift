import Foundation

enum VaultError: Error, Sendable {
    case accountNotFound
    case insufficientFunds
    case accountAlreadyExists
    case invalidAmount
    case unknown
}
