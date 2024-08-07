//
//  TrackingResultViewController.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/7/24.
//

import UIKit
import SnapKit
import Then

final class TrackingResultViewController: UIViewController {
    
    private let viewModel: TrackingViewModel
    
    private lazy var saveButton = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        $0.backgroundColor = .purple
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    init(viewModel: TrackingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc func saveButtonTapped() {
        viewModel.send(.saveButtonTap)
    }    
}
