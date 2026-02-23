//
//  ProductlyClipApp.swift
//  ProductlyClip
//
//  Created by Eric Eddy on 2026-02-20.
//

import SwiftUI

@main
struct ProductlyClipApp: App {
    @StateObject private var productModel = ProductViewModel()
    @StateObject private var cartModel = CartViewModel()
    let allowedHost = "shop.reactivapp.com"
    
    var body: some Scene {
        WindowGroup {
            CatalogView()
                .environmentObject(productModel)
                .environmentObject(cartModel)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
                
        }
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        if let webpage = userActivity.webpageURL, let component = URLComponents(url: webpage, resolvingAgainstBaseURL: true ) {
            if component.host != allowedHost {
                Task {
                    await productModel.setBadUrlState()
                }
                return
            }
            let components = webpage.pathComponents
            let count = components.count
            if count < 2 {
                Task {
                    await productModel.setBadUrlState()
                }
                return
            } else {
                let path1 = components[count - 2]
                let path2 = components[count - 1]
                if path1 == "product" {
                    Task {
                        await productModel.setSelectedByHandle(path2)
                    }
                } else if path1 == "collections" && path2 == "all" {
                    Task {
                        await productModel.fetchProducts()
                    }
                } else {
                    // Do nothing, clip will load all collections
                    Task {
                        await productModel.setBadUrlState()
                    }
                }
            }
            
            
            
        }
    }
}
