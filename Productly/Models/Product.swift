//
//  Product.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-20.
//
import Foundation


struct Price: Codable, Hashable {
    var amount: String
    var currencyCode: String
    func formatted() -> String {
        return "$" + amount + " " + currencyCode
    }
}
struct PriceRange: Codable, Hashable {
    var maxVariantPrice: Price
    var minVariantPrice: Price
    func formatted() -> String {
        if minVariantPrice.amount == maxVariantPrice.amount {
            "$" + maxVariantPrice.amount + " " + maxVariantPrice.currencyCode
        } else {
            "$" + minVariantPrice.amount + " - $" + maxVariantPrice.amount + " " + maxVariantPrice.currencyCode
        }
        
    }
}
struct ImageLink: Identifiable, Codable, Hashable {
    var id: String
    var url: String
}
struct Option: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var values: [String]
}
struct SelectedOption: Codable, Comparable, Hashable {
    static func < (lhs: SelectedOption, rhs: SelectedOption) -> Bool {
        lhs.name < rhs.name
    }
    var name: String
    var value: String
}
struct MediaImage: Identifiable, Codable, Hashable {
    var id: String
    var url: String
    var altText: String?
    var width: Int
    var height: Int
}
struct Media: Codable, Hashable {
    var mediaContentType: String
    var image: MediaImage
}
struct ProductDetail: Identifiable, Codable, Hashable {
    var id: String
    var handle: String
    var options: [Option]
}
struct Variant: Identifiable, Codable, Equatable, Hashable {
    static func == (lhs: Variant, rhs: Variant) -> Bool {
        lhs.id == rhs.id
    }    
    var id: String
    var title: String
    var quantityAvailable: Int
    var availableForSale: Bool
    var price: Price
    var compareAtPrice: Price?
    var sku: String
    var selectedOptions: [SelectedOption]
    var image: ImageLink
    var product: ProductDetail
    var amountInCart: Int = 1
    var productTitle: String = ""
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        quantityAvailable = try container.decode(Int.self, forKey: .quantityAvailable)
        availableForSale = try container.decode(Bool.self, forKey: .availableForSale)
        price = try container.decode(Price.self, forKey: .price)
        compareAtPrice = try container.decode(Price?.self, forKey: .compareAtPrice)
        sku = try container.decode(String.self, forKey: .sku)
        selectedOptions = try container.decode([SelectedOption].self, forKey: .selectedOptions)
        image = try container.decode(ImageLink.self, forKey: .image)
        product = try container.decode(ProductDetail.self, forKey: .product)
        amountInCart = 1
        productTitle = ""
        
    }
}
struct Product: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var description: String
    var descriptionHtml: String
    var availableForSale: Bool
    var handle: String
    var productType: String
    var tags: [String]
    var vendor: String
    var priceRange: PriceRange
    var compareAtPriceRange: PriceRange
    var images: [ImageLink]
    var options: [Option]
    var requiresSellingPlan: Bool
    var onlineStoreUrl: String
    var media: [Media]
    var variants: [Variant]
    var collections: [String]
    
    func getFirstImageURL() -> String {
        if images.count == 0 {
            return ""
        } else {
            return images[0].url
        }
    }
    func getFirstVariant() -> Variant {
        var foundVariant: Variant = variants[0]
        foundVariant.productTitle = title
        return foundVariant
    }
    func getVariant(with selectedOptions: [SelectedOption]) async -> Variant {
        var foundVariant: Variant = variants[0]
        for variant in variants {
            let same = selectedOptions.containsSameElements(as: variant.selectedOptions)
            if same {
                foundVariant = variant
                foundVariant.productTitle = title
            }
        }
        return foundVariant
    }
}
