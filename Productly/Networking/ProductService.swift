//
//  ProductService.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//
import Foundation
import Network

class ProductService: APIService<ProductServiceRequest>, ProductServiceProtocol {
    static let shared = ProductService()
    
    func getProducts() async -> [Product] {
        do {
            let response = try await request([Product].self, router: .getProducts)
            return response
        } catch let error {
            
            print(error)
            return [Product]()
        }
    }

}

protocol ProductServiceProtocol {
    func getProducts() async -> [Product]
}
enum ProductServiceRequest: APIServiceRequest {
    case getProducts
    
    var config: any APIServiceConfig {
        ProductServiceConfig()
    }
    var endpoint: String {
        switch self {
        case .getProducts:
            "6f379a4730ceb3c625afbcb0427ca9db7f7f3b8b/testProducts.json"
        }
    }
    var method: String {
        "GET"
    }
    var composedURL: String {
        config.baseURL + endpoint
    }
}
struct ProductServiceConfig: APIServiceConfig {
    var baseURL = "https://gist.githubusercontent.com/tsopin/22b7b6b32cef24dbf3dd98ffcfb63b1a/raw/"
}
