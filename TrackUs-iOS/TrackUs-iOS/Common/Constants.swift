//
//  Constants.swift
//  TrackUs-iOS
//
//  Created by 권석기 on 8/7/24.
//

import Foundation
import Firebase

enum Constants {
    struct FirebaseCollection {
        static let record = Firestore.firestore().collection("records")
    }
}
