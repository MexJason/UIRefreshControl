//
//  ViewController.swift
//  RefreshControlv2
//
//  Created by YouTube on 10/14/22.
//

import UIKit

class ViewController: UIViewController {

    let tableView = UITableView()
    let networkManager = NetworkManager()
    
    var people = [People]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTable()
        
        Task {
            await fetchData()
        }
        
    }

    private func configureTable() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func fetchData() async {
        await MainActor.run {
            people.removeAll()
            tableView.reloadData()
        }
        do {
            let ppl = try await networkManager.fetchPeople()
            self.people = ppl
            await MainActor.run {
                tableView.reloadData()
                tableView.refreshControl?.endRefreshing()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func didRefreshTable() {
        Task {
            await fetchData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].name
        return cell
    }
}
