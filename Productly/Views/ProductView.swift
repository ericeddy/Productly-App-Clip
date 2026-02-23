//
//  ProductView.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//

import SwiftUI

struct ProductOptionView: View {
    var option: Option
    var selectedOption: SelectedOption
    var optionSelected: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(option.name)
                .font(.system(size: 12))
                .foregroundStyle(.gray)
            HStack {
                ForEach(option.values, id: \.self) { value in
                    let isSelected = value == selectedOption.value
                    GroupBox {
                        Text(value)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .onTapGesture {
                                if !isSelected {
                                    optionSelected(option.name, value)
                                }
                            }
                    }
                    .backgroundStyle( (isSelected ? .reactivGreen : Color(.systemGroupedBackground) ).gradient.shadow(.inner(color: .white, radius: 4)) )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
struct ProductView: View {
    @EnvironmentObject private var productModel: ProductViewModel
    @EnvironmentObject private var cartModel: CartViewModel
    
    var product: Product
    @State var variant: Variant
    @State var imageUrl: URL
    @State var imgID = UUID()
    
    func getSelectedOption(for optionName: String) -> SelectedOption {
        for selectedOption in variant.selectedOptions {
            if selectedOption.name == optionName {
                return selectedOption
            }
        }
        print("Selected Option for: (" + optionName + ") not found")
        return SelectedOption(name: "", value: "")
    }
    
    func handleOptionSelected(_ selectedOption: SelectedOption) {
        var options = [selectedOption]
        for option in variant.selectedOptions {
            if option.name != selectedOption.name {
                options.append(option)
            }
        }
        Task {
            var newVariant =  await product.getVariant(with: options)
            newVariant.productTitle = product.title
            variant = newVariant
            imageUrl = URL(string: variant.image.url)!
            imgID = UUID()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action:{
                    Task {
                        await productModel.setSelected(id: nil)
                    }
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.reactivGreen)
                }
                .frame(alignment: .leading)
                Text(product.title)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action:{ }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.reactivGreen)
                }
                .frame(alignment: .trailing)
                .opacity(0)
            }
            .frame(maxWidth: .infinity)
            
            ScrollView {
                VStack {
                    CachedAsyncImage(
                        url: imageUrl,
                        content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                        },
                        placeholder: {
                            GroupBox {
                                ProgressView()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 320)
                        }
                    )
                    .frame(maxHeight: 320)
                    .id(imgID)
                   
                    HStack {
                        VStack {
                            if let comparePrice = variant.compareAtPrice, comparePrice.amount != "0.0" {
                                Text(comparePrice.formatted())
                                    .font(.system(size: 12))
                                    .strikethrough()
                                    .foregroundStyle(.gray)
                                    .opacity(0.6)
                            }
                            
                            Text(variant.price.formatted())
                                .foregroundStyle(.reactivGreen)
                        }
                        
                        Button(action: {
                            Task {
                                print(product.title)
                                print(variant.productTitle)
//                                variant.productTitle = product.title // need this so variants can display the product title
                                await cartModel.addItemToCart(variant)
                            }
                        }) {
                            GroupBox {
                                Text("Add to Cart")
                                    .fontWeight(.heavy)
                                    .foregroundStyle(
                                        .white
                                    )
                            }
                            .backgroundStyle( .reactivGreen.gradient.shadow(.inner(color: .white, radius: 4)) )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    VStack {
                        ForEach(product.options, id: \.self) { option in
                            if option.values.count > 1 {
                                ProductOptionView(option: option, selectedOption: getSelectedOption(for: option.name)) { name, value in
                                    let option = SelectedOption(name: name, value: value)
                                    handleOptionSelected(option)
                                }
                            }
                        }
                    }
                    
                    Text(product.description)
                        .font( .system(size: 12) )
                        .foregroundStyle(.gray)
                        .padding()
                }
            }
            
            CartBottomButton()
        }
        .padding()
        .toolbar(.hidden, for: .navigationBar)
    }
}
