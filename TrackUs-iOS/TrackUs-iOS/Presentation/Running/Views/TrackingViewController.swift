//
//  TrackingViewController.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/6/24.
//

import UIKit
import SnapKit
import Then
import Combine

final class TrackingViewController: UIViewController {
    
// MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: TrackingViewModel
    
    private let distanceLabel = UILabel().then {
        $0.text = "0.00"
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    private let timeLabel = UILabel().then {
        $0.text = "00:00:00"
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let calorieLabel = UILabel().then {
        $0.text = "0.0"
    }
    
    private let paceLabel = UILabel().then {
        $0.text = "0'00"
    }
    
    private lazy var startButton = UIButton().then {
        $0.setTitle("Start", for: .normal)
        $0.backgroundColor = .red
        $0.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    private lazy var stopButton = UIButton().then {
        $0.setTitle("Stop", for: .normal)
        $0.backgroundColor = .green
        $0.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
    }
    
    private let pauseButton = UIButton().then {
        $0.setTitle("Pause", for: .normal)
        $0.backgroundColor = .blue
    }
    
    private let buttonContainerView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }

    // MARK: - LifeCylcle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
        bind()
    }
    
    init(viewModel: TrackingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension TrackingViewController {
    
    private func setupLayout() {
        view.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(distanceLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(calorieLabel)
        calorieLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(timeLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(paceLabel)
        paceLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(calorieLabel.snp.bottom).offset(10)
        }
        
        startButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(50)
        }
        
        stopButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(50)
        }
        
        pauseButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(50)
        }
        
        view.addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        buttonContainerView.addArrangedSubview(startButton)
        buttonContainerView.addArrangedSubview(stopButton)
        buttonContainerView.addArrangedSubview(pauseButton)
    }
}

// MARK: - Data
extension TrackingViewController {
    
    private func bind() {
        viewModel.state.isTrackingMode
            .sink { isTrackingMode in
                print(isTrackingMode)
            }
            .store(in: &cancellables)
        
        viewModel.state.elapsedTime
            .withUnretained(self)
            .sink { (owner, count) in
                owner.timeLabel.text = count.toHHMMSSTimeFormat
            }
            .store(in: &cancellables)
    }
}

// MARK: - Helpers
extension TrackingViewController {
    @objc func startButtonTapped() {
        viewModel.send(.startButtonTap)
    }
    
    @objc func stopButtonTapped() {
        viewModel.send(.stopButtonTap)
    }
}
