import UIKit

final class TransactionTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletDetailActionDispatching?
    public var sectionTitle: String?
    var sectionSubtitle: String?
    public var properties: [TransactionRowItemProperties] = []
    
    override init() {
        super.init()
    }
    
    init(_ properties: WalletDetailSectionProperties) {
        super.init()
        self.properties = properties.items
        self.sectionTitle = properties.title
        self.sectionSubtitle = properties.sub
    }
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(TransactionRowItemCell.self, forCellReuseIdentifier: String(describing: TransactionRowItemCell.self))
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: String(describing: UITableViewHeaderFooterView.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TransactionRowItemCell.self), for: indexPath) as? TransactionRowItemCell else {
            return UITableViewCell()
        }
        cell.properties = properties[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hash = properties[indexPath.row].transactionHash
        dispatcher?.dispatch(.selectedTransaction(hash))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: UITableViewHeaderFooterView.self)) else {
            return UIView()
        }
        header.textLabel?.text = sectionTitle
        header.detailTextLabel?.text = sectionSubtitle
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
