//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit

/// Controller to show and search for Characters
final class RMCharacterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        Task {
            do {
                let res = try await RMService().execute(RMRequest(endpoint: .character), expecting: RMGetCharactersResponse.self)
                print("Total: \(res.info.pages)")
                print("Page result count: \(res.results.count)")
            } catch {
                print(error)
            }
        }
    }
}
