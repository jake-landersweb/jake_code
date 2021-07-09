# SwiftUI 3: Bank UI With Load Placeholder

The SwiftUI build in ProgressView is great and all, but sometimes you need something a little more immsersive. Thats where having a preview of what is going to be loaded comes in to play! This is a simple demonstration of fetching data from json, displaying a preview while it loads, and then showing the actual content when ready.

<<insert pics>>

## Client

First, we need a way to fetch the data and store it in objects for use in swiftUI code.

```swift
class Client: ObservableObject {
    @Published var loadingStatus: LoadingStatus = LoadingStatus.initial
    
    @Published var account: Account?
    private var accountResponse: AccountResponse? {
        didSet {
            if accountResponse != nil {
                if accountResponse!.status == 200 {
                    print("successfully fetched account data!")
                    account = accountResponse!.body
                    loadingStatus = .success
                } else {
                    print(accountResponse!.message)
                    loadingStatus = .failure
                }
            } else {
                print("There was a fatal error fetching account data.")
                loadingStatus = .failure
            }
        }
    }
    
    init() {
        fetchWithDelay()
    }
    
    func fetchWithDelay() {
        loadingStatus = .loading
        // add artificial network lag
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            async {
                await self.fetchData()
            }
        }
    }
    
    func fetchData() async {
        DispatchQueue.main.async {
            self.loadingStatus = .loading
        }
        
        // get the data from the url
        guard let url = Bundle.main.url(forResource: "data.json", withExtension: nil) else {
            DispatchQueue.main.async {
                self.loadingStatus = .failure
            }
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(AccountResponse.self, from: data)
            DispatchQueue.main.async {
                self.accountResponse = response
            }
        } catch {
            print("There was an error fetching or decoding the data")
            DispatchQueue.main.async {
                self.loadingStatus = .failure
            }
            return
        }
        
        // if fetching from data base use this:
//        guard let url = URL(string: "") else {
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoder = JSONDecoder()
//            let response = try decoder.decode(AccountResponse.self, from: data)
//            accountResponse = response
//        } catch {
//            print("There was an error fetching or decoding the data")
//            loadingStatus = .failure
//            return
//        }
    }
    
    // for generating a color based on the vendor
    func randomColor(seed: String) -> Color {
        
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return Color(red: r, green: g, blue: b)
    }
}

class AccountResponse: Codable {
    let status: Int
    let message: String
    let body: Account?
}

class Account: Codable {
    let name: String
    let currentBalance: Double
    let transactions: [Transaction]
}

class Transaction: Codable {
    let type: Int
    let vendor: String
    let amount: Double
    let date: String
}

enum LoadingStatus {
    case initial
    case loading
    case success
    case failure
}
```

## Loading Cell

Now, we need to create what our loading cell will look like. For this example, I am going to have the opacity oscillate between 0.5 and 1 to give user feedback that something is actually happening.

```swift
struct LoadingCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 10)
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width / 2, height: 10)
            }
        }
        .opacity(isAnimating ? 0.5 : 1)
        .foregroundColor(colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}
```

## View

Finally, lets put it all together.

```swift
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var client = Client()
    var body: some View {
        NavigationView {
            Group {
                switch client.loadingStatus {
                case .loading:
                    loading
                case .success:
                    success
                case .initial:
                    loading
                case .failure:
                    Text("Failure")
                }
            }
            .navigationTitle("Transactions")
        }
    }
    
    private var success: some View {
        Group {
            if client.account != nil {
                List {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(client.account!.name)
                                .fontWeight(.bold)
                                .font(.system(.title2))
                            HStack {
                                Text("Account Balance:")
                                Spacer(minLength: 0)
                                Text("\(client.account!.currentBalance, specifier: "%.2f")")
                            }
                            .foregroundColor(colorScheme == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                        }
                    }
                    Section {
                        ForEach(client.account!.transactions, id:\.date) { transaction in
                            VStack {
                                transactionCell(transaction: transaction)
                            }
                        }
                    }
                }
                .refreshable {
                    // if fetching data from the internet, use
//                    await client.fetchData()
                }
            } else {
                Text("There was an unknwon issue")
            }
        }
    }
    
    private func transactionCell(transaction: Transaction) -> some View {
        return HStack(spacing: 10) {
            vendorIcon(name: transaction.vendor)
            VStack(alignment: .leading) {
                Text(transaction.vendor)
                    .font(.system(size: 20, weight: .bold))
                Text(dateFormatter(passedDate: transaction.date))
                    .font(.system(.caption))
                    .foregroundColor(colorScheme == .light ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
            }
            Spacer(minLength: 0)
            Text("\(transaction.type == 0 ? "+" : "-") \(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(transaction.type == 0 ? Color.green : Color.red)
        }
    }
    
    private func vendorIcon(name: String) -> some View {
        return ZStack {
            Circle()
                .fill(client.randomColor(seed: name))
                .frame(width: 60, height: 60)
            Text("\(String(name.uppercased().prefix(1)))")
                .fontWeight(.bold)
                .font(.system(.title))
                .foregroundColor(Color.white)
                .shadow(color: colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1), radius: 3)
        }
    }
    
    private func dateFormatter(passedDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: passedDate)
        formatter.dateFormat = "E, MMM dd"
        return formatter.string(from: date!)
    }
    
    private var loading: some View {
        List {
            ForEach(0..<25, id:\.self) { item in
                LoadingCell()
            }
        }
    }
}
```

## Source

[Github](https://github.com/jake-landersweb/jake_code/tree/main/swift/BankUIDataPlaceHolder)