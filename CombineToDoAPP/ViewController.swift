//
//  ViewController.swift
//  CombineToDoAPP
//
//  Created by Amol Pawar on 05/07/22.
//

import UIKit
import Combine

class ViewController: UIViewController, UITableViewDataSource {

    var tableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()

    var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add New item", for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    var items = [String]()
    var itemsPublish = PassthroughSubject<String, Never>()
    var anyCancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            addButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        addButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)

        itemsPublish
            .filter { $0.count > 3 }
            .sink { [unowned self] value in
                self.items.append(value)
                self.tableView.reloadData()
            }.store(in: &anyCancellable)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        cell?.textLabel?.text = items[indexPath.row]
        return cell ?? UITableViewCell()
    }

    @objc func showAlert() {
        let vc = BlogPostViewCotroller()
//        vc.itemsPublish.sink { value in
//            self.itemsPublish.send(value)
//        }.store(in: &anyCancellable)
        self.present(vc, animated: true, completion: nil)

    }
}

class AddViewController: UIViewController {
    var itemsPublish = PassthroughSubject<String, Never>()
    var textField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.borderStyle = .roundedRect
        return textfield
    }()

    var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add New item", for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 400),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: textField.centerXAnchor)
        ])
        addButton.addTarget(self, action: #selector(addValue), for: .touchUpInside)
    }

    @objc func addValue() {
        let value = textField.text ?? ""
        itemsPublish.send(value)
        textField.text = ""
    }
}

struct BlogPost {
    let title: String
}

extension Notification.Name {
    static let newPost = Notification.Name("newPost")
}

class BlogPostViewCotroller: UIViewController {

    var textField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.borderStyle = .roundedRect
        return textfield
    }()

    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add New item", for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    var cancel = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(addButton)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 400),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
        ])
        addButton.addTarget(self, action: #selector(addValue), for: .touchUpInside)
        //NotificationCenter.Publisher(center: .default, name: .newPost, object: nil)
        let notificatioPulisher = NotificationCenter.Publisher(center: .default, name: .newPost, object: nil)
            .map { notification in
                return (notification.object as? BlogPost)?.title
            }.assign(to: \.text, on: label).store(in: &cancel)

//        let subscriber = Subscribers.Assign(object: label, keyPath: \.text)
//        notificatioPulisher.subscribe(subscriber)
    }

    @objc func addValue() {
        let value = textField.text ?? "Coming soon"
        NotificationCenter.default.post(name: .newPost, object: BlogPost(title: value))
        textField.text = ""
    }
}
