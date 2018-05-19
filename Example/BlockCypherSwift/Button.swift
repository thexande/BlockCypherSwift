import UIKit

final class SecondaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        layer.borderWidth = 2
        layer.borderColor = StyleConstants.primaryBlue.cgColor
        setTitleColor(StyleConstants.primaryBlue, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class PrimaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        backgroundColor = StyleConstants.primaryBlue
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
