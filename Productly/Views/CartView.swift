//
//  CartView.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//

import SwiftUI


struct CartViewItem: View {
    var cartItem: Variant
    var removeItem: () -> Void
    var plusItemAmount: () -> Void
    var minusItemAmount: () -> Void
    
    var body: some View {
        
        HStack(spacing: 0) {
            CachedAsyncImage(
                url: URL(string: cartItem.image.url)!,
                content: { image in
                    image
                        .resizable()
                        .frame(width: 120, height: 120)
                },
                placeholder: {
                    GroupBox {
                        ProgressView()
                    }
                }
            )
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(cartItem.productTitle)
                            .foregroundStyle(.gray)
                            .font(.system(size: 12.0, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(cartItem.title)
                            .foregroundStyle(.gray)
                            .font(.system(size: 12.0, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .leading )
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        
                    
                    Button(action: removeItem) {
                        ZStack {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                                .frame(alignment: .center)
                        }.frame(width: 40, height:40, alignment: .topTrailing)
                    }.buttonStyle(.borderless)
                        .frame(width: 40, height:40, alignment: .topTrailing)
                        .padding(0)
                }.frame(maxWidth: .infinity, alignment: .top)
                    .padding(.trailing, 8)
                ZStack {
                    Text(cartItem.price.formatted())
                        .foregroundStyle(.gray)
                        .font(.system(size: 14.0, weight: .black))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 10)
                        .padding(.bottom, 24)
                    HStack {
                        Button(action: {
                            minusItemAmount()
                        }){
                            Image(systemName: "minus.circle")
                                .font(.system(size: 18.0))
                                .foregroundColor(.gray)
                                .disabled( cartItem.amountInCart < 2 )
                        }.buttonStyle(.borderless)
                            .frame(width: 40, height:40)
                        
                        let amount = "x "  + String(cartItem.amountInCart)
                        Text(amount)
                            .foregroundStyle(.gray)
                            .font(.system(size: 14.0))
                        
                        Button(action: {
                            plusItemAmount()
                        }){
                            Image(systemName: "plus.circle")
                                .font(.system(size: 18.0))
                                .foregroundColor(.gray)
                        }.buttonStyle(.borderless)
                            .frame(width: 40, height:40)
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 16)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(0)
        }.frame(maxWidth: .infinity)
        .padding(0)
    }
    
}
struct CartView: View {
    @EnvironmentObject private var cartModel: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if cartModel.cartItems.count == 0 {
                    GroupBox {
                        Text("Oh no, your cart is empty!")
                            .foregroundStyle(.gray)
                        Button(action: {
                            dismiss()
                        }) {
                            GroupBox {
                                Text("Continue Shopping")
                                    .fontWeight(.heavy)
                                    .foregroundStyle(
                                        .white
                                    )
                            }
                            .backgroundStyle( .reactivGreen.gradient.shadow(.inner(color: .white, radius: 4)) )
                        }
                    }
                } else {
                    List(cartModel.cartItems) { product in
                        CartViewItem(cartItem: product, removeItem: {
                            // might want to wrap in an "are you sure" modal
                            print("removeItem")
                            Task {
                                await cartModel.removeFromCart(product.id, true)
                            }
                        }, plusItemAmount: {
                            print("plus")
                            Task {
                                await cartModel.addItemToCart(product)
                            }
                            
                        }, minusItemAmount: {
                            print("minus")
                            Task {
                                await cartModel.removeFromCart(product.id, false)
                            }
                        }).listRowInsets(EdgeInsets())
                    }
                    .listRowSpacing(8)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Quantity: " + String(cartModel.itemsInCartCount))
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            Text("Subtotal: " + cartModel.cartTotal.formatted())
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            
                            
                        }
                        .padding(.leading, 8)
                        Spacer()
                        Button(action: {
                            // go to checkout
                        }) {
                            GroupBox {
                                Text("Checkout")
                                    .fontWeight(.heavy)
                                    .foregroundStyle(
                                        .white
                                    )
                            }
                            .backgroundStyle( .reactivGreen.gradient.shadow(.inner(color: .white, radius: 4)) )
                        }
                        .padding(.trailing, 8)
                    }
                    .padding(8)
                }
            }
            .navigationTitle("Your Cart")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss() // Dismiss the modal
                    }) {
                        Text("Close Cart")
                    }
                }
            }
        }
    }
}

struct CartBottomButton: View {
    @EnvironmentObject private var productModel: ProductViewModel
    @EnvironmentObject private var cartModel: CartViewModel
    @State var isCartOpen: Bool = false
    
    var body: some View {
        Button(action: {
            if productModel.state == .loadedWithData {
                isCartOpen = true
            }
        }) {
            HStack {
                Spacer()
                Spacer()
                let total = cartModel.cartTotal.formatted()
                VStack {
                    Text(total)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
                ZStack {
                    Image(systemName: "cart")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.reactivGreen)
                        .frame(alignment: .center)
                        .padding(8)
                        
                }
                .background()
                .overlay(cartOverlay, alignment: .topTrailing)
                .padding(.trailing, 16)
                
            }
            
        }
        .sheet(isPresented: $isCartOpen) {
            CartView()
        }
    }
    
    private var cartOverlay: some View {
        VStack {
            if cartModel.itemsInCartCount > 0 {
                Text( String(cartModel.itemsInCartCount) )
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.reactivGreen)
                    .padding(6)
                    .frame(alignment: .topTrailing)
                    .background(
                        Circle()
                            .stroke(.reactivGreen, lineWidth: 2)
                            .background(
                                Circle().fill(.white)
                            )
                            
                    )
            }
        }
        
    }
    
}
