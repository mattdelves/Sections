//
//  UICollectionView+helpers.swift
//  Sections
//
//  Created by Matthew Delves on 12/6/18.
//  Copyright © 2018 Reformed Software. All rights reserved.
//

import UIKit

enum CollectionViewSupplementaryViewType {
  case sectionHeader
  case sectionFooter
  case header

  init?(kind: String) {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      self = .sectionHeader
    case UICollectionView.elementKindSectionFooter:
      self = .sectionFooter
    default:
      self = .header
    }
  }

  var identifier: String {
    switch self {
    case .sectionHeader:
      return UICollectionView.elementKindSectionHeader
    case .sectionFooter:
      return UICollectionView.elementKindSectionFooter
    case .header:
      return "header"
    }
  }
}

extension UICollectionView {

  // MARK: - Dequeue cells

  func dequeueReusableCell<Cell>(indexPath: IndexPath, type: Cell.Type) -> Cell {
    return dequeueReusableCell(identifier: String(describing: type), indexPath: indexPath, type: type)
  }

  private func dequeueReusableCell<Cell>(identifier: String, indexPath: IndexPath, type: Cell.Type) -> Cell {
    guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
      fatalError("Could not dequeue cell of type \(Cell.self) with identifier \(identifier)")
    }
    return cell
  }

  // MARK: - Register cells

  func registerClasses(types: UICollectionViewCell.Type...) {
    types.forEach { registerClass(type: $0) }
  }

  private func registerClass<Cell: UICollectionViewCell>(type: Cell.Type) {
    register(type, forCellWithReuseIdentifier: String(describing: type))
  }

  func registerClass(type: UICollectionReusableView.Type, for supplementaryView: CollectionViewSupplementaryViewType) {
    register(type, forSupplementaryViewOfKind: supplementaryView.identifier, withReuseIdentifier: String(describing: type))
  }

  func dequeueReusableSupplementaryView<SupplementaryView: UICollectionReusableView>(kind: CollectionViewSupplementaryViewType, type: SupplementaryView.Type, for indexPath: IndexPath) -> SupplementaryView {
    let identifier = String(describing: type)

    guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind.identifier, withReuseIdentifier: identifier, for: indexPath) as? SupplementaryView else {
      fatalError("Could not dequeue supplementary view of kind \(kind.identifier) with type \(SupplementaryView.self) for identifier \(identifier)")
    }

    return supplementaryView
  }
}
