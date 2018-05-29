import UIKit
import Anchorage
import BlockCypherSwift

protocol WalletRowItemPropertiesUpdating {
    var properties: WalletRowProperties { get set }
    func update(_ properties: WalletRowProperties)
}

struct WalletsSectionProperties {
    let items: [WalletRowProperties]
    let title: String
}

struct WalletRowProperties {
    let name: String
    let address: String
    let holdings: String
    let spent: String
    let walletType: WalletCurrency
    static let `default` = WalletRowProperties(name: "", address: "", holdings: "", spent: "", walletType: .bitcoin)
}

struct WalletsViewProperties {
    let title: String
    var sections: [WalletsSectionProperties]
    static let `default` = WalletsViewProperties(title: "", sections: [])
}

protocol WalletsViewPropertiesUpdating: PropsUpdating where Props == LoadableProps<WalletsViewProperties> { }

final class WalletsViewController: UITableViewController, WalletsViewPropertiesUpdating {
    public weak var dispatcher: WalletActionDispatching?
    private let emptyState = WalletsEmptyStateView()
    private let loading = TableLoadingView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearching: Bool = false
    var sections: [WalletsSectionProperties] = []
    
    var properties: LoadableProps<WalletsViewProperties> = .loading {
        didSet {
            update(properties)
        }
    }
    
    func update(_ props: LoadableProps<WalletsViewProperties>) {
        switch props {
        case .loading:
            tableView.backgroundView = loading
        case .data(let props):
            
            guard props.sections.count > 0 else {
                tableView.backgroundView = emptyState
                return
            }
            
            tableView.backgroundView?.isHidden = true
            sections = props.sections
            title = props.title
        case .error(let error): return
        }
        
        tableView.reloadData()
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallets"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(WalletRowCell.self, forCellReuseIdentifier: String(describing: WalletRowCell.self))
        tableView.register(WalletSectionHeader.self, forHeaderFooterViewReuseIdentifier: String(describing: WalletSectionHeader.self))
        tableView.refreshControl = UIRefreshControl()
        emptyState.actionButton.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
        emptyState.defaultButton.addTarget(self, action: #selector(defaultTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(scanTapped))
        
        // Setup the Search Controller
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search"
//        navigationItem.searchController = searchController
//        definesPresentationContext = true
        
//        searchController.searchBar.delegate = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
    
    @objc func refreshData() {
        dispatcher?.dispatch(walletAction: .reloadWallets)
    }
    
    @objc func scanTapped() {
        dispatcher?.dispatch(walletAction: .walletTypeSelectAlert)
    }
    
    @objc func editTapped() {
        
    }
    
    @objc private func defaultTapped() {
        dispatcher?.dispatch(walletAction: .displayDefaultWallets)
    }
}

extension WalletsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension WalletsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = true
        //        filteredCryptos = cryptos
        //        let searchCryptos = filteredCryptos.filter { $0.name.uppercased().range(of: searchText.uppercased()) != nil  || $0.symbol.uppercased().range(of: searchText.uppercased()) != nil }
        //        filteredCryptos = searchText == "" ? cryptos : searchCryptos
        //        tableView.reloadData()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        //        view.sendSubview(toBack: searchEmptyStateView)
        //        tableView.reloadData()
    }
}

extension WalletsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletRowCell.self)) as? WalletRowCell else {
            return UITableViewCell()
        }
        cell.properties = sections[indexPath.section].items[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: WalletSectionHeader.self)) as? WalletSectionHeader else {
            return UIView()
        }
        header.textLabel?.text = sections[section].title
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletRowCell.self)) as? WalletRowCell {
            dispatcher?.dispatch(walletAction: .selectedWallet(cell.properties.address, cell.properties.walletType))
        }
        //        let detailController = WalletDetailController()
        //        detailController.properties = detailProperties
        //        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Add") { (action, view, handler) in
            print("Add Action Tapped")
        }
        deleteAction.backgroundColor = StyleConstants.primaryGreen
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
        }
        deleteAction.backgroundColor = StyleConstants.primaryRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

enum StyleConstants {
    enum color {
        static let primaryGreen: UIColor = UIColor(hex: "4A9D86")
        static let emerald: UIColor = UIColor(hex: "65C87A")
        static let primaryRed: UIColor = UIColor(hex: "D65745")
        static let orange: UIColor = UIColor(hex: "E79F3C")
        static let purple: UIColor = UIColor(hex: "925EB1")
        static let bitOrange: UIColor = UIColor(hex: "E9973D")
        static let primaryGray: UIColor = UIColor(hex: "F0EFF4")
        static let secondaryGray: UIColor = UIColor(hex: "9B9B9C")
        static let lightGray: UIColor = UIColor(hex: "BCBBC1")
    }
    
    static let lightestGray: UIColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
    static let primaryBlue: UIColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
    static let primaryGreen: UIColor = UIColor(red:0.16, green:0.73, blue:0.37, alpha:1.0)
    static let primaryRed: UIColor = UIColor(red:0.99, green:0.30, blue:0.33, alpha:1.0)
    static let navGray: UIColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
}



