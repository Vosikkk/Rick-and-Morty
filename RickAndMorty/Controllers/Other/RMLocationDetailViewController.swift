//
//  RMLocationDetailViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 01.07.2024.
//

import UIKit

final class RMLocationDetailViewController: UIViewController {

    private let location: RMLocation
    
    init(location: RMLocation) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Location"
        view.backgroundColor = .systemBackground
    }
}
