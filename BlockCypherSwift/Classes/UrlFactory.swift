public struct UrlFactory {
    static func url(walletAddress: String, currency: WalletCurrency) -> URL? {
        let address = "https://api.blockcypher.com/v1/\(currency.symbol.lowercased())/main/addrs/\(walletAddress)/full?limit=200"
        return URL(string: address)
    }
    
    static func url(transactionHash: String, currency: WalletCurrency) -> URL? {
        let address = "https://api.blockcypher.com/v1/\(currency.symbol.lowercased())/main/txs/\(transactionHash)?limit=50&includeHex=true"
        return URL(string: address)
    }
    
    static let globalCryptoATMEndpoint: URL? = URL(string: "https://www.coinatmfinder.com/CoimATMs-API.php")
}
