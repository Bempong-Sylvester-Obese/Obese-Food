import Foundation
import Firebase
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var errorHandler: ErrorHandler?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthenticationStatus()
    }
    
    func setErrorHandler(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }
    
    private func checkAuthenticationStatus() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.currentUser = user
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.errorHandler?.handle(.authenticationError(error.localizedDescription))
                } else {
                    self?.isAuthenticated = true
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.errorHandler?.handle(.authenticationError(error.localizedDescription))
                } else {
                    // Update user profile with name
                    if let user = result?.user {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = name
                        changeRequest.commitChanges { error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    self?.errorMessage = error.localizedDescription
                                    self?.errorHandler?.handle(.authenticationError(error.localizedDescription))
                                } else {
                                    self?.isAuthenticated = true
                                    self?.errorMessage = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
            errorHandler?.handle(.authenticationError(error.localizedDescription))
        }
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.errorHandler?.handle(.authenticationError(error.localizedDescription))
                } else {
                    self?.errorMessage = "Password reset email sent"
                }
            }
        }
    }
}
