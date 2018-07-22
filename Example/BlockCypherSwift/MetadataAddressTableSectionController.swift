import UIKit

final class MetadataAddressTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletActionDispatching?
    public var properties: [MetadataAddressRowItemProperties] = []
    var sectionTitle: String?
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(MetadataAddressRowItemCell.self, forCellReuseIdentifier: String(describing: MetadataAddressRowItemCell.self))
        tableView.register(WalletSectionHeader.self, forHeaderFooterViewReuseIdentifier: String(describing: WalletSectionHeader.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MetadataAddressRowItemCell.self)) as? MetadataAddressRowItemCell else {
            return UITableViewCell()
        }
        cell.address = properties[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: WalletSectionHeader.self)) as? WalletSectionHeader else {
            return UIView()
        }
        header.textLabel?.text = sectionTitle
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatcher?.dispatch(.selectedTransactionSegment(properties[indexPath.row].address))
    }
    
    static func mapControllerFromProperties(_ properties: [MetadataAddressRowItemProperties]) -> MetadataAddressTableSectionController {
        let controller = MetadataAddressTableSectionController()
        controller.properties = properties
        return controller
    }
}
