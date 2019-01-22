//
//  UserViewController.swift
//  rxconiq
//
//  Created by Boska on 2019/1/22.
//  Copyright © 2019 boska. All rights reserved.
//

import UIKit
import RxAlamofire
import RxSwift
import RxCocoa
import Cartography

class UserViewModel {
  let user = BehaviorRelay.init(value: User())
  let decoder = JSONDecoder()
  let disposeBag = DisposeBag()

  init() {
    _ = requestData(.get, "http://demo5481020.mockable.io/userinfo")
      .map { try self.decoder.decode(User.self, from: $0.1) }
      .asDriver(onErrorJustReturn: User())
      .drive(user)
  }
}
class UserViewController: UIViewController {
  var disposeBag = DisposeBag()
  let viewModel: UserViewModel
  let userLabel = UILabel()

  init(viewModel: UserViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    view.addSubview(userLabel)
    userLabel.textAlignment = .center
    userLabel.numberOfLines = 0
    view.backgroundColor = .white
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    viewModel.user
      .debug("📁")
      .map {
        """
        \($0.name) \($0.surname)
        \($0.birthdate)
        \($0.nationality)
        """
      }
      .bind(to: userLabel.rx.text)
      .disposed(by: disposeBag)

    viewModel.user
      .map { "Hello, \($0.name)" }
      .bind(to: self.rx.title)
      .disposed(by: disposeBag)

  }
  func setupConstraints() {

    constrain(userLabel, self.view) { userLabel, view in
      userLabel.edges == view.edges
    }
  }
}
