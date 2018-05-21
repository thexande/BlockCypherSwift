import UIKit

final class TransactionTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletActionDispatching?
    public var sectionTitle: String?
    public var properties: [TransactionRowItemProperties] = []
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(WalletDetailRowItemCell.self, forCellReuseIdentifier: String(describing: WalletDetailRowItemCell.self))
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: String(describing: UITableViewHeaderFooterView.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletDetailRowItemCell.self), for: indexPath) as? WalletDetailRowItemCell else {
            return UITableViewCell()
        }
        cell.properties = properties[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatcher?.dispatch(walletAction: .selectedTransaction(properties[indexPath.row].transactionHash))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: UITableViewHeaderFooterView.self)) else {
            return UIView()
        }
        header.textLabel?.text = sectionTitle
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
}
