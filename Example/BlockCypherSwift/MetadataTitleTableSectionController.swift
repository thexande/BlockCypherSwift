import UIKit

final class MetadataTitleTableSectionController: NSObject, WalletTableSectionController {
    public var dispatcher: WalletActionDispatching?
    public var properties: [MetadataTitleRowItemProperties] = []
    var sectionTitle: String?
    
    func registerReusableTypes(tableView: UITableView) {
        tableView.register(MetadataTitleRowItemCell.self, forCellReuseIdentifier: String(describing: MetadataTitleRowItemCell.self))
        tableView.register(WalletSectionHeader.self, forHeaderFooterViewReuseIdentifier: String(describing: WalletSectionHeader.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MetadataTitleRowItemCell.self)) as? MetadataTitleRowItemCell else {
            return UITableViewCell()
        }
        cell.properties = properties[indexPath.row]
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
    
    static func mapControllerFromProperties(_ properties: [MetadataTitleRowItemProperties]) -> MetadataTitleTableSectionController {
        let controller = MetadataTitleTableSectionController()
        controller.properties = properties
        return controller
    }
}
