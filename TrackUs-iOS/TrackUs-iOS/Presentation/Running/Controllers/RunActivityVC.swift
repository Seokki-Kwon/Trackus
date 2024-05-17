//
//  RunActivityVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//
// TODO: - 스와이프 구현
// tanslation x값을 측정
// 버튼의 center.x값을 이동한 값만큼 추가

import UIKit
import MapKit

final class RunActivityVC: UIViewController {
    // MARK: - Properties
    private var mapView: MKMapView!
    private let locationService = LocationService.shared
    private var isActive = true
    private var timer: Timer?
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3"
        label.font = UIFont.boldSystemFont(ofSize: 58)
        label.textColor = .white
        return label
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 20
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "잠시 후 러닝이 시작됩니다!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        [countLabel, label].forEach {st.addArrangedSubview($0)}
        view.addSubview(st)
        st.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        st.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    private lazy var swipeBox: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.layer.cornerRadius = 35
        let label = UILabel()
        label.text = "밀어서 러닝 종료"
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(actionButton)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.isHidden = true
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.layer.cornerRadius = 25
        btn.backgroundColor = .white
        let image = UIImage(systemName: "pause.fill")
        
        btn.setImage(image, for: .normal)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pangestureHandler))
        btn.addGestureRecognizer(panGesture)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var kilometerLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0 km"
        label.font = UIFont.italicSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isLayoutMarginsRelativeArrangement = true // margin 적용
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        sv.layer.cornerRadius = 10
        
        let label = UILabel()
        label.text = "🏃‍♂️ 현재까지 거리"
        sv.backgroundColor = .white
        sv.isHidden = true
        [label, kilometerLabel].forEach {sv.addArrangedSubview($0)}
        return sv
    }()
    
    private let calorieValue: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        return label
    }()
    
    private let paceValue: UILabel = {
        let label = UILabel()
        label.text = "-'--''"
        return label
    }()
    
    private let timeValue: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        return label
    }()
    
    private let altitudeValue: UILabel = {
        let label = UILabel()
        label.text = "0.0m"
        return label
    }()
    
    private let cadenceValue: UILabel = {
        let label = UILabel()
        label.text = "-"
        return label
    }()
    
    private lazy var runInfoStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing
        let calorieStackVIew = makeCircleStView()
        let calorieImage = UIImageView()
        calorieImage.image = UIImage(resource: .fireIcon)
        
        let calorieLabel = UILabel()
        calorieLabel.text = "소모 칼로리"
        calorieLabel.font = UIFont.systemFont(ofSize: 12)
        [calorieImage, calorieLabel, calorieValue].forEach {calorieStackVIew.addArrangedSubview($0)}
        
        let paceStackVIew = makeCircleStView()
        let paceImage = UIImageView()
        paceImage.image = UIImage(resource: .pulseIcon)
        
        let paceLabel = UILabel()
        paceLabel.font = UIFont.systemFont(ofSize: 12)
        paceLabel.text = "페이스"
        [paceImage, paceLabel, paceValue].forEach {paceStackVIew.addArrangedSubview($0)}
        
        let timeStackVIew = makeCircleStView()
        let timeImage = UIImageView()
        timeImage.image = UIImage(resource: .stopwatchIcon)
        let timeLabel = UILabel()
    
        timeLabel.text = "경과 시간"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        [timeImage, timeLabel, timeValue].forEach {timeStackVIew.addArrangedSubview($0)}
        
        [calorieStackVIew, paceStackVIew, timeStackVIew].forEach { sv.addArrangedSubview($0) }
        sv.isHidden = true
        return sv
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setMapRegion()
        setConstraint()
        setTimer()
    }
    
    // MARK: - UI Methods
    func setConstraint() {
        self.view.addSubview(overlayView)
        self.view.addSubview(swipeBox)
        self.view.addSubview(topStackView)
        self.view.addSubview(runInfoStackView)
        
        NSLayoutConstraint.activate([
            swipeBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            swipeBox.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            swipeBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            swipeBox.heightAnchor.constraint(equalToConstant: 70),
            
            actionButton.leadingAnchor.constraint(equalTo: swipeBox.leadingAnchor, constant: 10),
            actionButton.topAnchor.constraint(equalTo: swipeBox.topAnchor, constant: 10),
            actionButton.bottomAnchor.constraint(equalTo: swipeBox.bottomAnchor, constant: -10),
            
            topStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            topStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -20),
            
            runInfoStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            runInfoStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            runInfoStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 20),
            
        ])
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    func setMapRegion() {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        if let currentLocation = locationService.currentLocation {
            mapView.setRegion(.init(center: currentLocation, span: defaultSpanValue), animated: true)
        }
    }
    
    func updatedOnStart() {
        self.overlayView.isHidden = true
        self.swipeBox.isHidden = false
        self.topStackView.isHidden = false
        self.runInfoStackView.isHidden = false
        self.actionButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func updatedOnPause() {
        self.actionButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let number = self.countLabel.text!.asNumber
            if number == 1 {
                self.updatedOnStart()
                self.timer?.invalidate()
            }
            self.countLabel.text = (number - 1).asString
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            self.countLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
    }
    
    func goToResultVC() {
        HapticManager.shared.hapticImpact(style: .medium)
        let resultVC = RunningResultVC()
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    }
    
    // MARK: - Actions
    @objc func pangestureHandler(sender: UIPanGestureRecognizer) {
        let minX = actionButton.bounds.width / 2 + 10
        let translation = sender.translation(in: actionButton)
        
        let newX = actionButton.center.x + translation.x
        let maxX = swipeBox.bounds.maxX - CGFloat(35)
        actionButton.center.x = max(minX, min(newX, maxX))
        sender.setTranslation(CGPoint.zero, in: actionButton)
        
        if sender.state == .ended && newX > maxX * 0.9 {
            goToResultVC()
        } else if sender.state == .ended  {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.actionButton.center.x = minX
            }
        }
    }
    
    @objc func buttonTapped() {
        if isActive {
            updatedOnPause()
        } else {
            updatedOnStart()
        }
        HapticManager.shared.hapticImpact(style: .light)
        isActive.toggle()
    }
    

}

extension RunActivityVC {
    func makeCircleStView() -> UIStackView {
        let circleDiameter: CGFloat = 88.0
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = circleDiameter / 2.0
        view.clipsToBounds = true
        view.distribution = .equalSpacing
        view.alignment = .center
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        view.isLayoutMarginsRelativeArrangement = true
        view.widthAnchor.constraint(equalToConstant: circleDiameter).isActive = true
        view.heightAnchor.constraint(equalToConstant: circleDiameter).isActive = true
        return view
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}

extension String {
    var asNumber: Int {
        guard let number = Int(self) else { return 0 }
        return number
    }
}
