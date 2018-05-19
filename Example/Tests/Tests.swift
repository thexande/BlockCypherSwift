import XCTest
import BlockCypherSwift
import Result


class Tests: XCTestCase {
    private var walletService: WalletService?
    private let walletAddress = "1GwifTHqRGMAYXDJwS7qxXkxjGsNED8DxH"
    
    override func setUp() {
//        walletService = WalletService(session: MockURLSession())
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testWalletFetch() {
        
//        walletService?.fetchWallet(walletAddress: walletAddress, walletType: .bitcoin, { walletResult in
//            switch walletResult {
//            case .success(let wallet): XCTAssert(wallet != nil)
//            case .failure(let error): XCTFail()
//            }
//        })
    }
}
