final class MetadataTableSectionFactory {
    static func mapControllerFromSections(_ sections: [MetadataSectionProperties], dispatcher: WalletActionDispatching?) -> [WalletTableSectionController] {
        return sections.compactMap { section -> WalletTableSectionController? in
            if let properties = section as? MetadataAddressSectionProperties, let items = properties.items as? [MetadataAddressRowItemProperties] {
                let controller = MetadataAddressTableSectionController.mapControllerFromProperties(items)
                controller.dispatcher = dispatcher
                controller.sectionTitle = properties.title
                return controller
            } else if
                let properties = section as? MetadataTitleSectionProperties,
                let items = properties.items as? [MetadataTitleRowItemProperties] {
                    let controller = MetadataTitleTableSectionController.mapControllerFromProperties(items)
                    controller.dispatcher = dispatcher
                    controller.sectionTitle = properties.title
                    return controller
            } else if
                let properties = section as? MetadataTransactionSegmentSectionProperties,
                let items = properties.items as? [MetadataTransactionSegmentRowItemProperties] {
                    let controller = MetadataTransactionSegmentTableSectionController()
                    controller.dispatcher = dispatcher
                    controller.properties = items
                    controller.sectionTitle = properties.title
                    return controller
            }
            else {
                return nil
            }
        }
    }
}
