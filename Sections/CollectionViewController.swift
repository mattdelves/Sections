//
//  CollectionViewController.swift
//  Sections
//
//  Created by Matthew Delves on 12/6/18.
//  Copyright © 2018 Reformed Software. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

  enum Section {
    case sideA
    case sideB
  }

  var currentSection: Section = .sideA

  var data: [Section: [Int]] = [
    .sideA: [1, 2, 3, 4, 5, 6, 7],
    .sideB: [1, 2, 3]
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Register cell classes
    self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    // Do any additional setup after loading the view.
    collectionView.registerClass(type: HeaderView.self, for: .header)
    if let layout = collectionView.collectionViewLayout as? ConcreteLayout {
      layout.hasSectionHeaders = false
    }
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return ConcreteSections.allCases.count
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return data[currentSection]?.count ?? 0
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

    // Configure the cell
    cell.backgroundColor = .white

    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let supplementaryKind = CollectionViewSupplementaryViewType(kind: kind) else { fatalError("Unknown kind. Can't dequeue") }

    switch supplementaryKind {
    case .header:
      let header = collectionView.dequeueReusableSupplementaryView(kind: .header, type: HeaderView.self, for: indexPath)
      return header
    default:
      fatalError("Not implemented")
    }
  }
}

extension CollectionViewController {
  @IBAction func panic() {
    collectionView?.performBatchUpdates({
      var existingPaths: [IndexPath] = []
      ConcreteSections.allCases.forEach { section in
        let items = collectionView.numberOfItems(inSection: section.rawValue)
        let paths = (0..<items).map { item -> IndexPath in
          return IndexPath(item: item, section: section.rawValue)
        }
        existingPaths.append(contentsOf: paths)
      }
      switch currentSection {
      case .sideA:
        currentSection = .sideB
      case .sideB:
        currentSection = .sideA
      }

      print("Existing paths: \(existingPaths)")

      var newPaths: [IndexPath] = []
      ConcreteSections.allCases.forEach { section in
        let items = 3 //collectionView.numberOfItems(inSection: section.rawValue)
        let paths = (0..<items).map { item -> IndexPath in
          return IndexPath(item: item, section: section.rawValue)
        }
        newPaths.append(contentsOf: paths)
      }

      print("New paths: \(newPaths)")

      collectionView.deleteItems(at: existingPaths)
      collectionView.insertItems(at: newPaths)
    }, completion: { _ in
      // maybe something here?
    })
  }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let section = ConcreteSections(rawValue: indexPath.section) else { return .zero }

    let width = collectionView.frame.width - 20

    switch section {
    case .one:
      return CGSize(width: width, height: 50)
    case .two:
      return CGSize(width: width, height: 70)
    case .three:
      return CGSize(width: width, height: 80)
    }
  }
}
