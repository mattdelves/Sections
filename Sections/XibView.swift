//
//  XibView.swift
//  Sections
//
//  Created by Matthew Delves on 12/6/18.
//  Copyright © 2018 Reformed Software. All rights reserved.
//

import UIKit

protocol XibView {
  func setupXib()
  func constrainView(_ view: UIView)
  func loadFromXib() -> UIView?
}

extension XibView where Self: UIView {
  func setupXib() {
    if let xibView = loadFromXib() {
      addSubview(xibView)
      constrainView(xibView)
    }
  }

  func constrainView(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false

    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[view]|",
        options: [.alignAllCenterX, .alignAllCenterY],
        metrics: nil,
        views: ["view": view]
      )
    )

    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[view]|",
        options: [.alignAllCenterX, .alignAllCenterY],
        metrics: nil,
        views: ["view": view]
      )
    )
  }

  func loadFromXib() -> UIView? {
    let xibView = UINib(nibName: String(describing: Self.self), bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil).first as? UIView
    return xibView
  }
}

