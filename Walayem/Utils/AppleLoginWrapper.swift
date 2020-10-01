//
//  AppleLoginWrapper.swift
//  Walayem
//
//  Created by ITRS-348 on 08/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import AuthenticationServices
//import CryptoKit
import FirebaseAuth

protocol AppleLoginProtocol: class {
    func appleLoginComplete(token: String)
}

@available(iOS 13, *)
class AppleLoginWrapper: NSObject {
    
    static var shared: AppleLoginWrapper?
    fileprivate var currentNonce: String?
    
    fileprivate static weak var appleLoginDelegate: AppleLoginProtocol?
    
    static func setLoginWrapper(appleLoginDelegate: AppleLoginProtocol) {
        if AppleLoginWrapper.shared == nil {
            shared = AppleLoginWrapper()
            self.appleLoginDelegate = appleLoginDelegate
        }
    }
    
    var viewController: UIViewController?
    var isCheckRequest = false
    
    private override init() {}
    
    func setUpWrapper(viewController: UIViewController) {
        self.viewController = viewController
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        appleIDProvider.getCredentialState(forUserID: KeyChainWrapper.shared?.getValue(key: KeychainKeys.USER_KEY) ?? "") { [weak self] (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                self?.isCheckRequest = true
                self?.authorizationRequest()
                break
            case .revoked, .notFound:
                //                try? self?.signOut()
                self?.authorizationRequest()
                break
            default:
                break
            }
        }
    }
    
    func authorizationRequest() {
        //        let nonce = randomNonceString()
        //        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        //        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

@available(iOS 13.0, *)
extension AppleLoginWrapper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Get user data with Apple ID credentitial
            
            let userId = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
                        
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let authToken = appleIDCredential.authorizationCode else {
                print("Unable to fetch auth token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            guard let authTokenString = String(data: authToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(authToken.debugDescription)")
                return
            }
            
            if isCheckRequest {
                //            let applePassword = passwordCredential.password
                do {
                    let jsonText = KeyChainWrapper.shared?.getValue(key: userId) ?? ""
                    let data = jsonText.data(using: .utf8)!
                    let userObject = try JSONDecoder().decode(UserKeychainObject.self, from: data)
                    
//                    let alert = UIAlertController.init(title: "Login Data Retrieved", message: jsonText, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                    viewController?.present(alert, animated: true, completion: nil)
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                let userKeychainObject: [String: String] = UserKeychainObject(email: userEmail ?? "", firstName: userFirstName ?? "", lastName: userLastName ?? "", identityToken: idTokenString).asDictionary()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userKeychainObject, options: .prettyPrinted)
                    let theJSONText = String(data: jsonData, encoding: .utf8) ?? ""
                    KeyChainWrapper.shared?.setKeychainValue(key: userId, value: theJSONText)
                    
//                    let alert = UIAlertController.init(title: "Login Data Initial", message: theJSONText, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                    viewController?.present(alert, animated: true, completion: nil)
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            AppleLoginWrapper.appleLoginDelegate?.appleLoginComplete(token: authTokenString)
            
            
            //            // Initialize a Firebase credential.
            //            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            //
            //            // Sign in with Firebase.
            //
            //            Auth.auth().signIn(with: credential) { (authResult, error) in
            //
            //                if let error = error {
            //                    print(error.localizedDescription)
            //                    return
            //                }
            //
            //                let value = response.result.value as! [String : Any]
            //                if let sessionId = value["result"] as? String
            //                {
            //                    UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
            //                    self.loadUserDetails()
            //                }
            //                else
            //                {
            //                    self.progressAlert?.dismiss(animated: false, completion: {
            //                        self.showMessagePrompt("An account with the provided email address already exists.")
            //                    })
            //                }
            //
            //                if userFirstName != nil && userFirstName != "" {
            //                    let changeRequest = authResult?.user.createProfileChangeRequest()
            //                    changeRequest?.displayName = userFirstName
            //                    changeRequest?.commitChanges(completion: { (error) in
            //
            //                        if let error = error {
            //                            print(error.localizedDescription)
            //                        } else {
            //                            print("Updated display name: \(Auth.auth().currentUser!.displayName!)")
            //                        }
            //                    })
            //                }
            //
            //                AppleLoginWrapper.appleLoginDelegate?.appleLoginComplete()
            
            // User is signed in to Firebase with Apple.
            // ...
        }
        // Write your code here
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if isCheckRequest {
            isCheckRequest = false
            authorizationRequest()
        }
        
        DLog(message: error.localizedDescription)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

@available(iOS 13.0, *)
extension AppleLoginWrapper: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (viewController?.view.window!)!
    }
}

