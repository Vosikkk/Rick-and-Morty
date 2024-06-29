//
//  RMSettingsView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 28.06.2024.
//

import SwiftUI

struct RMSettingsView: View {
    
    let viewModel: RMSettingsViewViewModel
    
    init(viewModel: RMSettingsViewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.cellViewModels) { vm in
            row(vm: vm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.onTapHandler(vm.type)
                }
        }
    }
    
    @ViewBuilder
    private func row(vm: RMSettingsCellViewModel) -> some View {
        HStack(spacing: Constants.spacing) {
            if let image = vm.image {
                icon(of: image, vm: vm)
            }
            Text(vm.title)
        }
    }
    
    
    private func icon(of image: UIImage, vm: RMSettingsCellViewModel) -> some View {
        Image(uiImage: image)
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(Color(vm.color))
            .aspectRatio(contentMode: .fit)
            .frame(
                width: Constants.Icon.width,
                height: Constants.Icon.height
            )
            .padding(Constants.Icon.inset)
            .background(
                RoundedRectangle(
                    cornerRadius: Constants.Icon.cornerRadius
                )
                .fill(.clear)
                .stroke(Color(vm.color),
                        lineWidth: Constants.Icon.lineWidth)
            )
            .padding([.bottom, .top],
                     Constants.Icon.additionalInset
            )
    }
}

private extension RMSettingsView {
    
    struct Constants {
        
        static let spacing: CGFloat = 15
        
        struct Icon {
            static let width: CGFloat = 20
            static let height: CGFloat = 20
            static let inset: CGFloat = 5
            static let additionalInset: CGFloat = 4
            
            static let cornerRadius: CGFloat = 8
            static let lineWidth: CGFloat = 2
        }
    }
}

#Preview {
    RMSettingsView(
        viewModel: .init(
            cellViewModels: RMSettingsOption.allCases.compactMap {
                .init(type: $0) { option in
                    print(option.displayTitle)
                }
      })
    )
}
