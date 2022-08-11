//
//  FormViewController.swift
//  CombineToDoAPP
//
//  Created by Amol Pawar on 05/07/22.
//

import UIKit
import Combine

class FormViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    @Published private var acceptedTerms: Bool = false
    @Published private var acceptedPrivacy: Bool = false
    @Published private var name: String = ""

    private var buttonSubscriber: AnyCancellable?

    var validToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($acceptedTerms, $acceptedPrivacy, $name).map { term, privacy, name in
            return term && privacy && !name.isEmpty
        }.eraseToAnyPublisher()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        text.delegate = self
        buttonSubscriber = validToSubmit
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: submitButton)
    }

    @IBAction func acceptTerms(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }

    @IBAction func acceptPrivacy(_ sender: UISwitch) {
        acceptedPrivacy = sender.isOn
    }

    @IBAction func nameChanged(_ sender: UITextField) {
        name = sender.text ?? ""
    }

    @IBAction func submitAction(_ sender: Any) {

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
