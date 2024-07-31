//
//  Coordinator.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 24.07.2024.
//

import UIKit
    
protocol CoordinatedController: UIViewController {
    var coordinator: MainCoordinator? { get set }
}


protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

extension Coordinator where Self: MainCoordinator {
     func push(_ vc: CoordinatedController) {
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(vc, animated: true)
    }
    
    func setItselfAsCoordinator(in vc: CoordinatedController) {
        vc.coordinator = self
    }
}

protocol EpisodeDetail {
    func episodeDetail(episodeURL: URL?)
}

protocol LocationDetail {
    func locationDetail(location: RMLocation)
}

protocol CharacterDetail {
    func characterDetail(character: RMCharacter)
}

protocol Search {
    func search(config: RMSearchViewController.Config)
}

protocol SearchPicker {
    func searchOptionPicker(
        option: RMSearchInputViewViewModel.DynamicOption,
        selection: @escaping (String) -> Void
    )
}


final class MainCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    private let service: Service
    
    private let tabItem: TabItems
    
    init(navigationController: UINavigationController, service: Service, tabItem: TabItems) {
        self.navigationController = navigationController
        self.service = service
        self.tabItem = tabItem
        setNavigationController()
    }
    
    
    func start() {
        let vc = setVC()
        vc.title = tabItem.title
        setItselfAsCoordinator(in: vc)
        vc.navigationItem.largeTitleDisplayMode = .automatic
        navigationController.setViewControllers([vc], animated: true)
    }
    
   
    private func setVC() -> CoordinatedController {
        switch tabItem {
        case .characters:
            RMCharacterViewController(service: service)
        case .locations:
            RMLocationViewController(service: service)
        case .episodes:
            RMEpisodeViewController(service: service)
        case .settings:
            RMSettingsViewController()
        }
    }
    
    
    private func setNavigationController() {
        navigationController.tabBarItem = UITabBarItem(
            title: tabItem.title,
            image: tabItem.image,
            tag: tabItem.rawValue)
        navigationController.navigationBar.prefersLargeTitles = true
    }
}

extension MainCoordinator: SearchPicker {
    
    func searchOptionPicker(
        option: RMSearchInputViewViewModel.DynamicOption,
        selection: @escaping (String) -> Void
    ) {
        let vc = RMSearchOptionPickerViewController(option, selection: selection)
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        navigationController.present(vc, animated: true)
    }
}

extension MainCoordinator: EpisodeDetail {
    
    func episodeDetail(episodeURL: URL?) {
        let vc = RMEpisodeDetailViewController(url: episodeURL, service: service)
        setItselfAsCoordinator(in: vc)
        push(vc)
    }
}

extension MainCoordinator: LocationDetail {
    
    func locationDetail(location: RMLocation) {
        let vc = RMLocationDetailViewController(location: location, service: service)
        setItselfAsCoordinator(in: vc)
        push(vc)
    }
}

extension MainCoordinator: CharacterDetail {
    
    func characterDetail(character: RMCharacter) {
        let vc = RMCharacterDetailViewController(
            viewModel: .init(
                character: character,
                service: service
            ),
            service: service
        )
        setItselfAsCoordinator(in: vc)
        vc.title = character.name
        push(vc)
    }
}

extension MainCoordinator: Search {
    func search(config: RMSearchViewController.Config) {
        let vc = RMSearchViewController(config: config, service: service)
        setItselfAsCoordinator(in: vc)
        push(vc)
    }
}


