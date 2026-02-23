//
//  ProductViewModel.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//

import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    enum ProductsState {
        case idle
        case loading
        case loadedWithData
        case empty
        case badUrl
    }
    @Published public var products: [Product] = [Product]()
    @Published public var product: Product?
    @Published public var productViewOpen = false
    @Published public var state: ProductsState = .idle
    
    public func setBadUrlState() async {
        state = .badUrl
    }
    
    public func fetchProducts() async {
//        print("fetchProducts")
        if state == .loading { return } // avoid any re-running of the call while data is loading
        if products.count == 0 {
            state = .loading
            products = await ProductService.shared.getProducts()
            if products.count == 0 {
                state = .empty
            } else {
                state = .loadedWithData
            }
        } else {
            state = .loadedWithData
        }
    }
    
    public func setSelectedByHandle(_ handle: String? ) async {
//        print("setSelectedByHandle")
        await fetchProducts()
        guard let handle = handle else {
            state = .badUrl
            product = nil
            productViewOpen = false
            return
        }
        
        let p = products.filter { $0.handle == handle }
        if p.count > 0 {
            product = p[0]
            productViewOpen = true
        } else {
            state = .badUrl
        }
        
        
    }
    
    public func setSelected( id: String? ) async {
//        print("setSelected")
        await fetchProducts()
        guard let id = id else {
            product = nil
            productViewOpen = false
            return
        }
        let p = products.filter { $0.id == id }
        if p.count > 0 {
            product = p[0]
            productViewOpen = true
        }
    }
    
}
