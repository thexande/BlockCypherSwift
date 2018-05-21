import UIKit
import Anchorage
import Lottie

final class WalletsEmptyStateView: UIView {
    let animation = LOTAnimationView(name: "qr_animation")
    let actionButton = UIButton()
    let defaultButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(animation)
        animation.sizeAnchors == CGSize(width: 200, height: 200)
        animation.centerXAnchor == centerXAnchor
        animation.centerYAnchor == centerYAnchor - 100
        animation.loopAnimation = true
        animation.play()
        
        actionButton.heightAnchor == 54
        defaultButton.heightAnchor == 54
        
        let buttonStack = UIStackView(arrangedSubviews: [actionButton, defaultButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 24
        
        addSubview(buttonStack)
        buttonStack.horizontalAnchors == horizontalAnchors + 18
        buttonStack.topAnchor == animation.bottomAnchor + 36
        
        actionButton.setTitle("Scan Wallet QR", for: .normal)
        actionButton.backgroundColor = .black
        actionButton.layer.cornerRadius = 10
        actionButton.tintColor = .gray
        
        defaultButton.setTitleColor(.black, for: .normal)
        defaultButton.setTitle("check out example wallets", for: .normal)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animation.play()
    }
}

