//
//  Array+Extension.swift
//  SlidingPuzzleView
//
//  Created by kokonak on 2023/02/06.
//  Copyright © 2023 KOKONAK. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
