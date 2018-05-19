import Foundation
import Result

public enum WalletServiceError: Error {
    case walletDoesNotExist
    case urlGenerationFailure
}

final public class WalletService {
    open func fetchWallet(walletAddress: String, walletType: WalletType, _ completion: @escaping(Result<Wallet, WalletServiceError>) -> Void) {
        guard let url = UrlFactory.url(walletAddress: walletAddress, walletType: walletType) else {
            completion(.failure(.urlGenerationFailure))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                let wallet = try decoder.decode(Wallet.self, from: data)
                completion(.success(wallet))
            } catch let error {
                completion(.failure(.walletDoesNotExist))
                print(error.localizedDescription)
            }
            }.resume()
    }
}
