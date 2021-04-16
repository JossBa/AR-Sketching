//
//  String+Localization.swift
//  AR-Sketch
//
//  Created by Josephine Battiston on 01.08.20.
//  Copyright © 2020 Josephine Battiston. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
