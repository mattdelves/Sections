//
//  Layout.swift
//  Sections
//
//  Created by Matthew Delves on 12/6/18.
//  Copyright © 2018 Reformed Software. All rights reserved.
//

import UIKit

final class ConcreteLayout: SectionFlowLayout<ConcreteSections, HeaderView> { }

protocol Sections: RawRepresentable {
  init?(rawValue: Int)

  var background: UIColor { get }
}

enum ConcreteSections: Int, CaseIterable, Sections {
  case one
  case two
  case three

  var background: UIColor {
    switch self {
    case .one:
      return .red
    case .two:
      return .green
    case .three:
      return .blue
    }
  }
}

final class SectionBackgroundReusableView: UICollectionReusableView {
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)

    guard let sectionAttributes = layoutAttributes as? SectionBackgroundLayoutAttributes else { return }

    backgroundColor = sectionAttributes.color
  }
}

final class SectionBackgroundLayoutAttributes: UICollectionViewLayoutAttributes {
  var color: UIColor = .white

  override func copy(with zone: NSZone?) -> Any {
    guard let copiedAttributes = super.copy(with: zone) as? SectionBackgroundLayoutAttributes else {
      return super.copy(with: zone)
    }

    copiedAttributes.color = color
    return copiedAttributes
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let otherAttributes = object as? SectionBackgroundLayoutAttributes, color == otherAttributes.color else {
      return false
    }

    return super.isEqual(object)
  }
}

class SectionFlowLayout<SectionType: Sections, HeaderType: UICollectionReusableView>: UICollectionViewLayout {
  var headerAttributes: [UICollectionViewLayoutAttributes] = []
  var decorationAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
  var itemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
  var allAttributes: [UICollectionViewLayoutAttributes] = []
  var layoutRect: CGRect = .zero
  var hasSectionHeaders: Bool = true

  private var contentHeight: CGFloat = 0.0

  private var collectionViewWidth: CGFloat {
    return collectionView?.frame.width ?? 0.0
  }
  override public var collectionViewContentSize: CGSize {
    return CGSize(width: collectionViewWidth, height: contentHeight)
  }

  override func prepare() {
    super.prepare()

    register(
      SectionBackgroundReusableView.self,
      forDecorationViewOfKind: String(describing: SectionBackgroundReusableView.self)
    )

    headerAttributes = calculateHeaderAttributes()

    itemAttributes = calculateItemAttributes().reduce(into: [:]) { newAttribues, cellAttributes in
      newAttribues[cellAttributes.indexPath] = cellAttributes
    }
    decorationAttributes = calculateDecorationAttributes(from: itemAttributes.map { $0.value })
    allAttributes = [headerAttributes, itemAttributes.map { $0.value }].flatMap { $0 }
  }

  func calculateHeaderAttributes() -> [UICollectionViewLayoutAttributes] {
    let dummyHeader = UINib(nibName: String(describing: HeaderType.self), bundle: Bundle(for: type(of: self))).instantiate(withOwner: HeaderType(), options: nil).first as? UIView
    let size = CGSize(
      width: collectionViewWidth,
      height: dummyHeader?.frame.height ?? 0.0
    )

    let headerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewSupplementaryViewType.header.identifier, with: IndexPath(item: 0, section: 0))
    headerAttribute.frame = CGRect(origin: .zero, size: size)

    return [headerAttribute]
  }

  func calculateDecorationAttributes(from attributes: [UICollectionViewLayoutAttributes]) -> [IndexPath: UICollectionViewLayoutAttributes] {
    return attributes.filter { $0.representedElementCategory == UICollectionView.ElementCategory.cell }.reduce(into: [:]) { newAttributes, cellAttributes in
      if let attribute = createDecorationAttribute(cellAttributes) {
        newAttributes[cellAttributes.indexPath] = attribute
      }
    }
  }

  func createDecorationAttribute(_ attribute: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
    guard attribute.frame.origin.x == 0.0, let section = SectionType(rawValue: attribute.indexPath.section) else { return nil }

    guard let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return nil }

    let spacing = delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: attribute.indexPath.section) ?? 0.0

    let decorationAttributes: SectionBackgroundLayoutAttributes = SectionBackgroundLayoutAttributes(
      forDecorationViewOfKind: String(describing: SectionBackgroundReusableView.self),
      with: attribute.indexPath
    )

    decorationAttributes.color = section.background
    decorationAttributes.zIndex = attribute.zIndex - 1

    let decorationWidth = collectionViewWidth
    let decorationHeight = attribute.frame.size.height + spacing
    decorationAttributes.frame = CGRect(
      x: 0,
      y: attribute.frame.origin.y,
      width: decorationWidth,
      height: decorationHeight
    )

    return decorationAttributes
  }

  func calculateItemAttributes() -> [UICollectionViewLayoutAttributes] {
    let sections = collectionView?.numberOfSections ?? 0
    guard let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else { return [] }
    var height: CGFloat = headerAttributes.last?.frame.maxY ?? 0.0

    let attributes = (0..<sections).flatMap { section -> [UICollectionViewLayoutAttributes] in
      let items = collectionView.numberOfItems(inSection: section)

      guard items > 0 else { return [] }

      if hasSectionHeaders {
        let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewSupplementaryViewType.sectionHeader.identifier, with: IndexPath(item: 0, section: section))

        let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? .zero

        sectionHeaderAttributes.frame = CGRect(origin: CGPoint(x: 0, y: height), size: size)
        height = sectionHeaderAttributes.frame.maxY

        headerAttributes.append(sectionHeaderAttributes)
      }

      let spacing = delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? 0.0

      return (0..<items).map { item -> UICollectionViewLayoutAttributes in
        let indexPath = IndexPath(item: item, section: section)
        let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? .zero
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = CGRect(origin: CGPoint(x: 0, y: height), size: size)
        height = attribute.frame.maxY + spacing
        return attribute
      }
    }

    contentHeight = height
    return attributes
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var attributes = allAttributes.filter { $0.frame.intersects(rect) }
    let decorations = decorationAttributes.filter { $0.value.frame.intersects(rect) }.map { $0.value }
    attributes.append(contentsOf: decorations)
    layoutRect = rect
    return attributes
  }

  override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return decorationAttributes[indexPath]
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return itemAttributes[indexPath]
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return collectionView?.bounds != newBounds
  }

  override func invalidateLayout() {
    super.invalidateLayout()

    itemAttributes = [:]
    decorationAttributes = [:]
    allAttributes = []
  }
}
