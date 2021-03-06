//
//  LoginViewController.swift
//  AnywhereFitness
//
//  Created by Mark Poggi on 4/27/20.
//  Copyright © 2020 Christopher Devito. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var signupLabel: UILabel!

    // MARK: - Properties
    var userController = UserController()
    var loginType: LoginType?
    var role: Role?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if loginType == LoginType.signIn {
            emailTextField.isHidden = true
            nameTextField.isHidden = true
            nameLabel.isHidden = true
            emailLabel.isHidden = true
            signupLabel.text = "Sign In"
        }
    }

    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.isEmpty == false,
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false, let role = role
            else { return }

        if loginType == .signUp {
            guard let email = emailTextField.text,
            email.isEmpty == false,
            let name = nameTextField.text,
                name.isEmpty == false else { return }
            UserDefaults.standard.set("\(name)", forKey: UserDefaultKeys.user.rawValue)
            let user = UserLogin(username: username, email: email, password: password,
                                 gender: Gender.male.rawValue, displayName: name, roles: [role.rawValue])

            userController.signUp(with: user) { (error) in

                if let error = error {
                    NSLog("Error occurred during sign up: \(error)")
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Sign Up Successful",
                                                                message: "Now please log in", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: {
                            self.loginType = .signIn
                        })
                        UserDefaults.standard.set("token", forKey: "bearerToken")
                    }
                }
            }
        } else {
            let user = UserSignIn(username: username, password: password, role: role.rawValue)
            userController.signIn(with: user) { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Sign In Failed",
                                message: "Please try again later.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    print(error)
                    return
                }

                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Sign In Successful",
                                                            message: "Lets go work out!", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.performSegue(withIdentifier: (role == Role.client) ? "ClientSegue" : "InstructorSegue",
                                      sender: self)
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
