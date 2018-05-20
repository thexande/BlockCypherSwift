import UIKit
import Anchorage

final class TableLoadingView: UIView {
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicator)
        indicator.centerAnchors == centerAnchors
        indicator.sizeAnchors == CGSize(width: 80, height: 80)
        indicator.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
