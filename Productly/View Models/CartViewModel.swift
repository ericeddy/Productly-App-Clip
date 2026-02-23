//
//  CartViewModel.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//

import Foundation

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [Variant] = [Variant]()
    @Published var cartTotal: Price = Price(amount: "0", currencyCode: "CAD")
    @Published var itemsInCartCount: Int = 0
    
    func addItemToCart(_ variant: Variant) async {
        if let index = cartItems.firstIndex(where: { variant.id == $0.id }) {
            
            var found = cartItems[index]
            found.amountInCart = found.amountInCart + 1
            print(found)
            
            cartItems[index] = found
        } else {
            
            cartItems.append(variant)
        }
        await updateCartTotal()
    }
    
    func removeFromCart(_ id: String, _ delete: Bool) async {
        guard let index = cartItems.firstIndex(where: { $0.id == id  }) else {
            return
        }
        var item = cartItems[index]
        if !delete && item.amountInCart > 1 {
            item.amountInCart = item.amountInCart - 1
            cartItems[index] = item
        } else {
            cartItems.remove(at: index)
        }
        
        await updateCartTotal()
    }
    
    func updateCartTotal() async {
        let total = cartItems.reduce(0.0) { sum, product in
            return sum + ((Double(product.price.amount) ?? 0) * Double(product.amountInCart) )
        }
        let itemCount = cartItems.reduce(0) { sum, product in
            print(product.amountInCart)
            return sum + product.amountInCart
        }
        let totalString = String(format: "%.2f", total)
        cartTotal = Price(amount: totalString, currencyCode: "CAD")
        itemsInCartCount = itemCount
    }
}
