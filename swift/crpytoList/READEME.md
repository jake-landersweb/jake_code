# Refreshable Crypto Data Into SwiftUI List

Today I am going to show you how to fetch crypto data from a public api, serialize it into a swift object, display it into a list, and make the lsit refreshable. Lets begin!

## Client

First, you need to define the objects we will use to hold the crypto data in.

We can use the [CoinCap Api](https://docs.coincap.io) to freely fetch bitcoin prices in a 1m interval.

Here is what the json response looks like for bitcoin:

```
{"data":[{"priceUsd":"34880.1704778472291349","time":1624560300000,"circulatingSupply":"18741856.0000000000000000","date":"2021-06-24T18:45:00.000Z"},{"priceUsd":"34878.3866490829225675","time":1624560360000,"circulatingSupply":"18741856.0000000000000000","date":"2021-06-24T18:46:00.000Z"},{"priceUsd":"34885.8041414565858166","time":1624560420000,"circulatingSupply":"18741856.0000000000000000","date":"2021-06-24T18:47:00.000Z"},{"priceUsd":"34873.8122685577117982","time":1624560480000,"circulatingSupply":"18741856.0000000000000000","date":"2021-06-24T18:48:00.000Z"}], timestamp: 1624646664453}
```

So, our objects will look like this:

```swift
import Foundation

class CryptoData: Decodable, Identifiable {
    let priceUsd: String
    let time: Int
    let circulatingSupply: String
    let date: String
}

class CryptoResponse: Decodable {
    let data: [CryptoData]
    let timestamp: Int
}
```

Then, to use thes objects we can create an observable object client class. This will allow us to hold the data in a place that is accessable by more than just this one view. Also, it keeps the api fetching code out of the way of our view.

```swift
class Client: ObservableObject {
    @Published var btcData: [CryptoData] = []

    let btcUrl = "https://api.coincap.io/v2/assets/bitcoin/history?interval=m1"

    // init the data
    init() {
        async {
            // get data
            let data = await fetchData(url: btcUrl)
            DispatchQueue.main.async {
                // bind data
                withAnimation(.spring()) {
                    self.btcData = data
                }
            }
        }
    }

    // fetch the crypto data with a url
    func fetchData(url: String) async -> [CryptoData] {
        do {
            // create url
            let _url = URL(string: url)!
            print("1")
            // fetch
            let (data, _) = try await URLSession.shared.data(from: _url)
            print(data)
            // decode
            let fetchedData: CryptoResponse = try JSONDecoder().decode(CryptoResponse.self, from: data)
            print("successfully found data")
            // slice the list and return
            return fetchedData.data.reversed()
        } catch {
            // handle error
            print("There was an error getting the data")
            return []
        }
    }
}
```

## View

Now that we have the data, all we need to do is create the view!

```swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var client = Client()

    var body: some View {
        NavigationView {
            List(client.btcData) { item in
                VStack(alignment: .leading) {
                    Text("\(_convertToDouble(item.priceUsd))")
                        .font(.headline)
                    Text(item.date)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("BTC Price")
            .refreshable {
                client.btcData = await client.fetchData(url: client.btcUrl)
            }
        }
    }

    private func _convertToDouble(_ input: String) -> Double {
        return Double(input) ?? 0.0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

And thats it! You are now free to conquer the world with this btc data.

---

[Source Code](https://github.com/jake-landersweb/jake_code/tree/main/swift/cryptoList/CryptoList.swift)
