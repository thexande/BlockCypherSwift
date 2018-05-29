import Foundation
import Result

public enum WalletServiceError: Error {
    case walletDoesNotExist
    case urlGenerationFailure
    
    case transactionNotFound
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
    open func wallet(address: String,
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
                completion(.success(try decoder.decode(Wallet.self, from: data)))
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
    open func transaction(hash: String,
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
        }
    }
}
