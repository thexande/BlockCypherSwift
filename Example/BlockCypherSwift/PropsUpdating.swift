protocol PropsUpdating {
    associatedtype Props
    var properties: Props { get set }
    func update(_ props: Props)
}
