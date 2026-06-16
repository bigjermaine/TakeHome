import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
    }

    @Published var username = ""
    @Published var password = ""
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var canUseBiometrics = false
    @Published private(set) var biometryName = ""
    @Published private(set) var loginMode: LoginMode = .signIn

    private let loginUseCase: LoginUseCase
    private let biometricLoginUseCase: AuthenticateWithBiometricsUseCase
    private let router: AppRouter
    private var hasAttemptedAutomaticUnlock = false

    init(
        loginUseCase: LoginUseCase,
        biometricLoginUseCase: AuthenticateWithBiometricsUseCase,
        router: AppRouter
    ) {
        self.loginUseCase = loginUseCase
        self.biometricLoginUseCase = biometricLoginUseCase
        self.router = router
        refreshBiometricAvailability()
    }

    var isUnlockMode: Bool {
        loginMode == .unlock
    }

    var isLoginEnabled: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.isEmpty
            && viewState != .loading
    }

    var biometrySystemImage: String {
        switch biometryName {
        case "Face ID":
            return "faceid"
        case "Touch ID":
            return "touchid"
        default:
            return "lock.fill"
        }
    }

    func prepareForPresentation(mode: LoginMode) {
        loginMode = mode
        viewState = .idle
        hasAttemptedAutomaticUnlock = false
        if mode == .signIn {
            username = ""
            password = ""
        }
        refreshBiometricAvailability()
    }

    func refreshBiometricAvailability() {
        canUseBiometrics = biometricLoginUseCase.canUseBiometrics
        biometryName = biometricLoginUseCase.biometryName
    }

    func attemptAutomaticBiometricUnlock() async {
        guard isUnlockMode, canUseBiometrics, !hasAttemptedAutomaticUnlock else { return }
        hasAttemptedAutomaticUnlock = true
        await loginWithBiometrics()
    }

    func login() async {
        guard validateInputs() else { return }

        viewState = .loading
        do {
            _ = try await loginUseCase.execute(
                credentials: AuthCredentials(username: username, password: password)
            )
            viewState = .idle
            HapticFeedback.play(.success)
            router.showMain()
        } catch let error as AuthError {
            viewState = .error(error.localizationKey)
            HapticFeedback.play(.error)
        } catch {
            viewState = .error(error.localizedDescription)
            HapticFeedback.play(.error)
        }
    }

    func loginWithBiometrics() async {
        viewState = .loading
        do {
            _ = try await biometricLoginUseCase.execute()
            viewState = .idle
            HapticFeedback.play(.success)
            router.showMain()
        } catch let error as AuthError {
            viewState = .error(error.localizationKey)
            HapticFeedback.play(.error)
        } catch {
            viewState = .error(error.localizedDescription)
            HapticFeedback.play(.error)
        }
    }

    private func validateInputs() -> Bool {
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            viewState = .error("Username is required.")
            HapticFeedback.play(.error)
            return false
        }
        if password.isEmpty {
            viewState = .error("Password is required.")
            HapticFeedback.play(.error)
            return false
        }
        return true
    }
}
