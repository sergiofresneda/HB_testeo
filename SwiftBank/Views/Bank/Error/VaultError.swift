import Foundation

enum VaultError: Error {
    case accountNotFound
    case insufficientFunds
    case accountAlreadyExists
    case invalidAmount
    case unknown
}
