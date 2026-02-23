//
//  Catalog.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//

import SwiftUI

struct CatalogItemView: View {
    var product: Product
    
    var body: some View {
        VStack {
            CachedAsyncImage(
                url: URL(string: product.getFirstImageURL())!,
                content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                },
                placeholder: {
                    GroupBox {
                        ProgressView()
                    }
                }
            )
            if product.compareAtPriceRange.minVariantPrice.amount != "0.0" {
                Text(product.compareAtPriceRange.formatted())
                    .strikethrough()
                    .foregroundStyle(.gray)
                    .opacity(0.6)
            }
            
            Text(product.priceRange.formatted())
                .foregroundStyle(.reactivGreen)
        }
    }
}

struct CatalogView: View {
    @EnvironmentObject private var productModel: ProductViewModel
    @EnvironmentObject private var cartModel: CartViewModel
    @State var isCartOpen = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                switch productModel.state {
                case .idle, .loading:
                    VStack {
                        GroupBox {
                            VStack {
                                ProgressView()
                                Text("Loading Products")
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                case .empty:
                    VStack {
                        GroupBox {
                            VStack {
                                Text("Products failed to load. Please check on your internet connection and try again!")
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                case .badUrl:
                    VStack {
                        GroupBox {
                            VStack {
                                Text("404")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(.gray)
                                Text("The url, product or collection you're looking for doesn't exist.")
                                    .foregroundStyle(.gray)
                                Button(action: {
                                    Task {
                                        await productModel.fetchProducts()
                                    }
                                }) {
                                    GroupBox {
                                        Text("Continue to Store")
                                            .fontWeight(.heavy)
                                            .foregroundStyle(
                                                .white
                                            )
                                    }
                                    .backgroundStyle( .reactivGreen.gradient.shadow(.inner(color: .white, radius: 4)) )
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loadedWithData:
                    List(productModel.products) { product in
                        CatalogItemView(product: product)
                            .onTapGesture {
                                Task {
                                    await productModel.setSelected(id: product.id)
                                }
                            }
                    }
                    .listRowSpacing(8.0)
                    .navigationDestination(isPresented:  $productModel.productViewOpen) {
                        if let product = productModel.product {
                            let variant = product.getFirstVariant()
                            ProductView(product: product, variant: variant, imageUrl: URL(string: variant.image.url)!)
                        }
                    }
                }
                
                CartBottomButton()
            }
            .frame(maxHeight: .infinity)
        }.tint(.reactivGreen)
        .environmentObject(productModel)
        .environmentObject(cartModel)
    }   
}

