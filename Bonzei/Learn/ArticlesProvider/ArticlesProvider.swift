//
//  ArticlesProvider.swift
//  Bonzei
//
//  Created by Tomasz on 30/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

protocol ArticlesProvider {
    func getAll() -> [Article]?
}
