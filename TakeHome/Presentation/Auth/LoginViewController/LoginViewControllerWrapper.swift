//
//  LoginViewControllerWrapper.swift
//  TakeHome
//
//  Created by jermaine daniel on 15/06/2026.
//

import SwiftUI

struct LoginViewControllerWrapper: UIViewControllerRepresentable {
    let viewModel: LoginViewModel
    let locale: Locale
    let loginMode: LoginMode

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = LoginViewController(viewModel: viewModel, locale: locale)
        controller.updateLoginMode(loginMode)
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.prefersLargeTitles = true
        return navigation
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        guard let controller = uiViewController.viewControllers.first as? LoginViewController else {
            return
        }
        controller.updateLocale(locale)
        controller.updateLoginMode(loginMode)
    }
}
