import UIKit
import SwiftUI
import Combine

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private var locale: Locale
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let errorLabel = UILabel()
    private let signInButton = UIButton(type: .system)
    private let biometricButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var keyboardObservers: [NSObjectProtocol] = []

    init(viewModel: LoginViewModel, locale: Locale) {
        self.viewModel = viewModel
        self.locale = locale
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        configureKeyboardHandling()
        bindViewModel()
        applyPresentationMode()
        startLogoAnimation()
    }

    deinit {
        keyboardObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardObserversIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await viewModel.attemptAutomaticBiometricUnlock() }
    }

    func updateLocale(_ locale: Locale) {
        self.locale = locale
        applyPresentationMode()
    }

    func updateLoginMode(_ mode: LoginMode) {
        applyPresentationMode()
    }

    private func applyPresentationMode() {
        if viewModel.isUnlockMode {
            title = AppLocalization.string("Unlock", locale: locale)
        } else {
            title = AppLocalization.string("Sign In", locale: locale)
        }
        navigationItem.largeTitleDisplayMode = .always
        applyLocalizedStrings()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])

        logoImageView.image = UIImage(systemName: "bag.fill")
        logoImageView.tintColor = view.tintColor
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .center

        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        configureTextField(usernameField, contentType: .username, isSecure: false)
        configureTextField(passwordField, contentType: .password, isSecure: true)

        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signInButton.configuration = .filled()
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        biometricButton.addTarget(self, action: #selector(biometricTapped), for: .touchUpInside)
        biometricButton.configuration = .gray()
        biometricButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        activityIndicator.hidesWhenStopped = true

        let logoStack = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel])
        logoStack.axis = .vertical
        logoStack.spacing = 12
        logoStack.alignment = .center

        let buttonStack = UIStackView(arrangedSubviews: [signInButton, biometricButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12

        contentStack.addArrangedSubview(logoStack)
        contentStack.setCustomSpacing(32, after: logoStack)
        contentStack.addArrangedSubview(usernameField)
        contentStack.addArrangedSubview(passwordField)
        contentStack.addArrangedSubview(errorLabel)
        contentStack.addArrangedSubview(buttonStack)

        signInButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor)
        ])

        applyLocalizedStrings()
    }

    private func configureKeyboardHandling() {
        scrollView.keyboardDismissMode = .interactive
        usernameField.delegate = self
        passwordField.delegate = self
        usernameField.returnKeyType = .next
        passwordField.returnKeyType = .go

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
    }

    private func registerKeyboardObserversIfNeeded() {
        guard keyboardObservers.isEmpty else { return }

        let center = NotificationCenter.default
        keyboardObservers = [
            center.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.handleKeyboardFrameChange(notification)
            }
        ]
    }

    private func unregisterKeyboardObservers() {
        keyboardObservers.forEach { NotificationCenter.default.removeObserver($0) }
        keyboardObservers.removeAll()
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func handleKeyboardFrameChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let keyboardFrameInView = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY)
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom)
        let options = UIView.AnimationOptions(rawValue: curveValue << 16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.scrollView.contentInset.bottom = bottomInset
            self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        }

        scrollActiveFieldIntoView(animated: true)
    }

    private func scrollActiveFieldIntoView(animated: Bool) {
        guard let field = [usernameField, passwordField].first(where: { $0.isFirstResponder }) else {
            return
        }

        let targetFrame = field.convert(field.bounds, to: scrollView)
            .insetBy(dx: 0, dy: -32)
            .union(signInButton.convert(signInButton.bounds, to: scrollView))
        scrollView.scrollRectToVisible(targetFrame, animated: animated)
    }

    private func configureTextField(_ field: UITextField, contentType: UITextContentType, isSecure: Bool) {
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.textContentType = contentType
        field.isSecureTextEntry = isSecure
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        field.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.renderState()
            }
            .store(in: &cancellables)

        viewModel.$canUseBiometrics
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.renderBiometricButton()
            }
            .store(in: &cancellables)

        viewModel.$biometryName
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.renderBiometricButton()
            }
            .store(in: &cancellables)

        viewModel.$loginMode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyPresentationMode()
            }
            .store(in: &cancellables)
    }

    private func applyLocalizedStrings() {
        titleLabel.text = AppLocalization.string("TakeHome Shop", locale: locale)

        if viewModel.isUnlockMode {
            subtitleLabel.text = AppLocalization.string(
                "Use Face ID or your password to continue.",
                locale: locale
            )
        } else {
            subtitleLabel.text = AppLocalization.string(
                "Demo credentials: demo / password123",
                locale: locale
            )
        }

        usernameField.placeholder = AppLocalization.string("Username", locale: locale)
        passwordField.placeholder = AppLocalization.string("Password", locale: locale)

        let primaryActionTitle = viewModel.isUnlockMode
            ? AppLocalization.string("Continue", locale: locale)
            : AppLocalization.string("Sign In", locale: locale)
        signInButton.configuration?.title = primaryActionTitle
        renderBiometricButton()
        renderState()
    }

    private func renderState() {
        signInButton.isEnabled = viewModel.isLoginEnabled
        biometricButton.isEnabled = viewModel.viewState != .loading

        switch viewModel.viewState {
        case .idle:
            activityIndicator.stopAnimating()
            signInButton.configuration?.title = viewModel.isUnlockMode
                ? AppLocalization.string("Continue", locale: locale)
                : AppLocalization.string("Sign In", locale: locale)
            errorLabel.isHidden = true
        case .loading:
            activityIndicator.startAnimating()
            signInButton.configuration?.title = nil
            errorLabel.isHidden = true
        case .error(let messageKey):
            activityIndicator.stopAnimating()
            signInButton.configuration?.title = viewModel.isUnlockMode
                ? AppLocalization.string("Continue", locale: locale)
                : AppLocalization.string("Sign In", locale: locale)
            errorLabel.text = AppLocalization.string(messageKey, locale: locale)
            errorLabel.isHidden = false
        }
    }

    private func renderBiometricButton() {
        biometricButton.isHidden = !viewModel.canUseBiometrics
        guard viewModel.canUseBiometrics else { return }

        let biometry = AppLocalization.string(viewModel.biometryName, locale: locale)
        let formatKey = viewModel.isUnlockMode
            ? "Unlock with %@"
            : "Sign in with %@"
        let title = String(
            format: AppLocalization.string(formatKey, locale: locale),
            biometry
        )
        var config = UIButton.Configuration.gray()
        config.title = title
        config.image = UIImage(systemName: viewModel.biometrySystemImage)
        config.imagePadding = 8
        biometricButton.configuration = config
    }

    private func startLogoAnimation() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            options: [.repeat, .autoreverse, .allowUserInteraction],
            animations: { [weak self] in
                self?.logoImageView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
        )
    }

    @objc private func textFieldChanged() {
        viewModel.username = usernameField.text ?? ""
        viewModel.password = passwordField.text ?? ""
        renderState()
    }

    @objc private func signInTapped() {
        HapticFeedback.play(.light)
        viewModel.username = usernameField.text ?? ""
        viewModel.password = passwordField.text ?? ""
        Task { await viewModel.login() }
    }

    @objc private func biometricTapped() {
        HapticFeedback.play(.light)
        Task { await viewModel.loginWithBiometrics() }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollActiveFieldIntoView(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if viewModel.isLoginEnabled {
                signInTapped()
            }
        }
        return true
    }
}

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
