//
//  ViewModelable.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/6/24.
//

import Combine

protocol ViewModelable {
    associatedtype Action
    associatedtype State
    
    func send(_ action: Action)
}
