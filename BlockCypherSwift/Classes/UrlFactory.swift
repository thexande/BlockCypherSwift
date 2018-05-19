public struct UrlFactory {
    static func url(walletAddress: String, walletType: WalletType) -> URL? {
        let address = "https://api.blockcypher.com/v1/\(walletType.symbol.lowercased())/main/addrs/\(walletAddress)/full?limit=50"
        return URL(string: address)
    }
    
    static let globalCryptoATMEndpoint: URL? = URL(string: "https://www.coinatmfinder.com/CoimATMs-API.php")
}
