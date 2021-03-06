//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/5/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

