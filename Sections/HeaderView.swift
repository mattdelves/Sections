//
//  HeaderView.swift
//  Sections
//
//  Created by Matthew Delves on 12/6/18.
//  Copyright © 2018 Reformed Software. All rights reserved.
//

import UIKit

@IBDesignable class HeaderView: UICollectionReusableView {

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  private func configure() {
    setupXib()
  }

}

extension HeaderView: XibView { }
