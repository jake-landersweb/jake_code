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
