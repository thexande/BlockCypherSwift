import Foundation

enum LoadableProps<T> {
    case loading
    case error(Error)
    case data(T)
}
