# Productly-App-Clip
SwiftUI App Clip Product Preview


## Setup instructions & How to run the app

1. Clone Repo
2. Open project in XCode
3. Set the target to ProductlyClip
4. You can update the Invocation Url by editing the AppClip's scheme
	- ( Product > Scheme > Edit Scheme... > Run > Arguments > Environment Variables )
	- Only check 1 _XCAppClipURL variable
5. Run the AppClip!

## Required environment variables

To test successful paths:
	- https://shop.reactivapp.com/collections/all
	- https://shop.reactivapp.com/product/unisex-hoodie
	- https://shop.reactivapp.com/product/unisex-heavy-blend-full-zip-hooded-sweatshirt-black

To test unsuccessful paths:
	- https://shop.reactivapp.com/product/bad-url
	- https://shop.reactivapp.com/bad-url
	- https://testing-bad-url.com/

## High-level architecture

- Built following MVVM structure.
	- Views display Model data, which is fetched and served to the Views via View Models.

- APIService + ProductService built with scalability & testability in mind.
	- ProductService is easily swapped out for a Test / mock Service that also conform to APIService<APIServiceRequest> & ProductServiceProtocol

- CachedAsyncImage & NSCache used for local image caching.
	- Would consider image caching libraries for production ready app

- Unit Testing & UI Testing created for project, but not setup with meaningful tests yet
	- Swapping Environment Variables is currently the best way to test the app

## Assumptions & Decisions:

Error Logging: 
- In a production ready app I would setup an error & crash reporting service like Sentry.

Local Database Persistance:
- In a production ready version of this app with more than 4 products available, there would be a much greater need for a local database.

CatalogView:
- Since there are only 4 products available in the demo, I went ahead with using SwiftUI's List(), but for production ready apps, I would definitely consider a more performant custom implementation (something like https://nilcoalescing.com/blog/CustomLazyListInSwiftUI/)
- Since there are only 4 products available in the demo, I didn't add pagination, search, sort & filter but a production ready version of this app would have all 4. ( As I tried not to add any additional features )
- From a design perspective, the inconsistent lengths between product titles led me to remove the titles from the list items in this view.

ProductView:
- In a production ready app, I would hookup the product view to not let the user to add items to their cart that either availableForSale=false, currentlyNotInStock=true or quantityAvailable < 1, as well as use quantityAvailable as a max cartItem limit per variant. I debated adding this functionality, but since currently in the demo data, there's only 1 product with variants that have quantityAvailable > 0, I figured it would be better not implemented so I could test adding multiple products
- From a design perspective, I decided not to use the navigation bar as products with longer names were being cut off, however in a production ready app, I would want to ensure that my custom implementation of the navigation works with accessibility features

CartView:
- Since the demo data doesn't have anything for taxes or shipping, I didn't add those fields to the cart.

Robust URL Routing:
- A '404 page' is setup to handle 'bad' URLs. 
- 'Bad' urls constitute:
	- host is not shop.reactivapp.com
	- correct host, /product/{product-handle} no product found for handle
	- correct host, not /collection/all or /product


## ~AI Usage, Decision Log &~ Tradeoffs
While I understand that the use of AI was encouraged for this project, my machine currently lacks the RAM required to use & integrate AI into my workflow just yet, so due to this I did not use AI tools for the planning, creation, design or development of this project. 
Also due to these RAM issues, I do not have previews setup in my codebase to avoid additional RAM usage.

One key technical tradeoff incurred from not using AI is that I ran out of time to add accessibility modifiers needed to use voice over controls.

With more time I would add the accessibility modifiers, add a database for local storage of product data, set up Unit & UI Tests, and add pagination, search, sort & filter functions to the CatalogView. 


