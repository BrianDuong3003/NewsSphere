//
//  AppConstants.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 5/3/25.
//

import Foundation
import UIKit

struct AppConstants {
    struct API {
        static let baseUrl = "https://newsdata.io/api/1"
        static let accessToken = "pub_86016149f3b0a46a0ea78f184382814c13719"
        
        struct Endpoints {
            static let latest = "/latest"
            static let archive = "/archive"
        }
        
        struct Parameters {
            static let apiKey = "apikey" 
            static let query = "q"
            static let country = "country"
            static let region = "region"
            static let category = "category"
            static let language = "language"
            static let fromDate = "from_date"
            static let toDate = "to_date"
            static let domain = "domain" // specific source
            static let page = "page"
            static let size = "size"
        }
    }
}
