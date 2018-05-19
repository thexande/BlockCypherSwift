import Foundation
import Result

enum WalletType: String {
    case bitcoin
    case litecoin
    case dogecoin
    case dash
    
    public var symbol: String {
        switch self {
        case .bitcoin: return "BTC"
        case .litecoin: return "LTC"
        case .dogecoin: return "DOGE"
        case .dash: return "DASH"
        }
    }
}

struct URLFactory {
    static func url(walletAddress: String, walletType: WalletType) -> URL? {
        let address = "https://api.blockcypher.com/v1/\(walletType.symbol.lowercased())/main/addrs/\(walletAddress)/full?limit=50"
        return URL(string: address)
    }
    
    static let globalCryptoATMEndpoint: URL? = URL(string: "https://www.coinatmfinder.com/CoimATMs-API.php")
}

enum WalletServiceError: Error {
    case walletDoesNotExist
    case urlGenerationFailure
}

final class WalletService {
    static func fetchWallet(walletAddress: String, walletType: WalletType, _ completion: @escaping(Result<Wallet, WalletServiceError>) -> Void) {
        guard let url = URLFactory.url(walletAddress: walletAddress, walletType: walletType) else {
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
