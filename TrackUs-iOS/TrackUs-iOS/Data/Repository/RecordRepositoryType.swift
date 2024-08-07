//
//  RecordRepositoryType.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/7/24.
//

import Combine

protocol RecordRepositoryType {
    func uploadRecord(_ record: Record) -> AnyPublisher<Void, Never>
    func fetchRecord() -> AnyPublisher<[Record], Never>
}
