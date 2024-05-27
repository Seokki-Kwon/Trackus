//
//  RunningResultVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit
import MapKit
class RunningResultVC: UIViewController {
    
    // MARK: - Properties
    private var mapView: MKMapView!
    private lazy var saveButton: UIButton = {
        let bt = MainButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = .mainBlue
        bt.title = "기록저장"
        return bt
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🏃‍♂️ 종로3가 에서 러닝 - 오후 12:32"
        label.textColor = .gray1
        return label
    }()
    
    private lazy var kmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3.33 KM"
        if let descriptor = UIFont.systemFont(ofSize: 40, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        } else {
            label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        }
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.isScrollEnabled = false
        return tb
    }()
    
    private lazy var detailButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        bt.semanticContentAttribute = .forceRightToLeft
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bt.setTitle("상세보기", for: .normal)
        bt.setTitleColor(.gray1, for: .normal)
        
        return bt
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupMapView()
        setConstraint()
    }
    
    // MARK: - Helpers
    func setConstraint() {
        view.addSubview(titleLabel)
        view.addSubview(kmLabel)
        view.addSubview(tableView)
        view.addSubview(detailButton)
        view.addSubview(mapView)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            kmLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            kmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: kmLabel.bottomAnchor, constant: 20),
            tableView.heightAnchor.constraint(equalToConstant: 200),
            
            detailButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            detailButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            mapView.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 20),
            mapView.heightAnchor.constraint(equalToConstant: 230),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(RunInfoCell.self, forCellReuseIdentifier: RunInfoCell.identifier)
    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 10
        mapView.showsUserLocation = false
    }
}

extension RunningResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RunInfoCell.identifier, for: indexPath) as? RunInfoCell else {
            return UITableViewCell()
        }

        return cell
    }
}
