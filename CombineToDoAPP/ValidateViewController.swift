//
//  ValidateViewController.swift
//  CombineToDoAPP
//
//  Created by Amol Pawar on 05/07/22.
//

import UIKit
import Combine

class ValidateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!


    @Published private var userName: String = ""
    @Published private var password: String = ""
    @Published private var confirmPassword = ""


    var validatedUsername: AnyPublisher<String?, Never> {
        return $userName
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { username  in
                return Future { promise in
                    self.usernameAvailable(username) { available in
                        promise(.success(available ? username : nil))
                    }
                }
            }.eraseToAnyPublisher()
    }

    func usernameAvailable(_ username: String, completion: (Bool) -> Void) {
        completion(true) // Our fake asynchronous backend service
    }

    var validatedPassword: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($password, $confirmPassword)
            .map { password, confirmPassword in
                guard password == confirmPassword, password.count > 0 else {
                    return nil
                }
                return password
            }
            .map {
                ($0 ?? "") == "password1" ? nil : $0
            }
            .eraseToAnyPublisher()
    }

    var validatedCredentials: AnyPublisher<(String, String)?, Never> {
        return Publishers.CombineLatest(validatedUsername, validatedPassword)
            .receive(on: DispatchQueue.main)
            .map { username, password in
                guard let uname = username, let pwd = password else { return nil }
                return (uname, pwd)
            }
            .eraseToAnyPublisher()
    }

    var anyCancellabel: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        anyCancellabel = validatedCredentials
            .map { $0 != nil}
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: createAccountButton)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = textField.text ?? ""
        let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)

        if userNameTextField == textField { userName = text }
        if passwordTextField == textField { password = text }
        if confirmPasswordTextField == textField { confirmPassword = text }

        return true
    }
}
