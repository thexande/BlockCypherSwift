import Foundation
import Result

public enum WalletServiceError: Error {
    case walletDoesNotExist
    case urlGenerationFailure
    
    case transactionNotFound
}


/// Source: http://kean.github.io/post/codable-tips-and-tricks
public struct Safe<Base: Decodable>: Decodable {
    public let value: Base?
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            assertionFailure("ERROR: \(error)")
            // TODO: automatically send a report about a corrupted data
            self.value = nil
        }
    }
}


final public class WalletService {
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    public init(session: URLSession) {
        self.session = session
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full())
    }
    
    /// Fetch a wallet for a currency available on the BlockCypher API
    ///
    /// - Parameters:
    ///   - address: the public key for a given wallet.
    ///   - currency: BTC, LTC, DOGE, DASH
    ///   - completion: callback with serialized `Wallet` or an error
    public func wallet(address: String,
                    currency: WalletCurrency,
                    completion: @escaping(Result<Wallet, WalletServiceError>) -> Void) {
        
        guard let url = UrlFactory.url(walletAddress: address, currency: currency) else {
            completion(.failure(.urlGenerationFailure))
            return
        }
        
        session.dataTask(with: url) { [weak self] (data, response, error) in
            guard
                let data = data,
                let decoder = self?.decoder
            else {
                return
            }
            
            do {
                if let wallet = try decoder.decode(Safe<Wallet>.self, from: data).value {
                    completion(.success(wallet))
                }
            } catch let error {
                completion(.failure(.walletDoesNotExist))
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    /// Fetch a transaction from the BlockCypher API
    ///
    /// - Parameters:
    ///   - hash: The hash for a given transaction.
    ///   - currency: BTC, LTC, DOGE, DASH
    ///   - completion: callback with serialized `Transaction` or an error
    public func transaction(hash: String,
                        currency: WalletCurrency,
                        completion: @escaping(Result<Transaction, WalletServiceError>) -> Void) {
        guard let url = UrlFactory.url(transactionHash: hash, currency: currency) else {
            completion(.failure(.urlGenerationFailure))
            return
        }
        
        session.dataTask(with: url) { [weak self] (data, response, error) in
            guard
                let data = data,
                let decoder = self?.decoder
            else {
                return
            }
            
            do {
                completion(.success(try decoder.decode(Transaction.self, from: data)))
            } catch let error {
                completion(.failure(.transactionNotFound))
                print(error.localizedDescription)
            }
        }.resume()
    }
}
