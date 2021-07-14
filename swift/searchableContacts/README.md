# SwiftUI 3: Searchable Contacts With Async/Await

The new async features in iOS15 are amazing! Combine that with the ability to search through a list with the new searchable tag on lists, and you got a great way to build fast, simple and intuitive UI!

## Example

<<Insert pics>>


As you can see, a simple good looking UI can be achieved with little code.

## Client

The client is used to fetch and manage the data you grab from the internet. In this example, I am using a json file locally that looks like this:

```json
{
    "status": 200,
    "message": "Successfully fetched contacts.",
    "body": [
        {
          "first": "Belinda",
          "last": "Oconnor",
          "phone": "(905) 437-2764",
          "email": "belindaoconnor@vurbo.com"
        },
        {
          "first": "Mckenzie",
          "last": "Rios",
          "phone": "(977) 533-2407",
          "email": "mckenzierios@vurbo.com"
        },
        ...
    ]
}
```

This file in included in the github.

Now for the actual swift code to fetch this data. I used a helpful url to give the data fetching some artificial delay:

```swift
enum LoadingStatus {
    case loading
    case success
    case error
}

class Client: ObservableObject {
    @Published var loadingStatus = LoadingStatus.loading
    
    init() {
        async {
            await fetchData()
        }
    }
    
    @Published var contacts: [Contact]?
    private var response: Response? {
        didSet {
            if response!.status == 200 {
                print(response!.message)
                contacts = response!.body!
                loadingStatus = .success
            } else {
                print(response!.message)
                loadingStatus = .error
            }
        }
    }
    
    func fetchData() async {
        DispatchQueue.main.async {
            self.loadingStatus = .loading
        }
        // url that will wait 2 seconds to return
        let request = URLRequest(url: URL(string: "https://httpbin.org/delay/2")!)
        let _ = try! await URLSession.shared.data(for: request)
        // get the data from the file
        guard let url = Bundle.main.url(forResource: "data.json", withExtension: nil) else {
            DispatchQueue.main.async {
                self.loadingStatus = .error
            }
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(Response.self, from: data)
            DispatchQueue.main.async {
                self.response = response
            }
        } catch {
            print("There was an error fetching or decoding the data")
            DispatchQueue.main.async {
                self.loadingStatus = .error
            }
            return
        }
    }
}

struct Contact: Codable {
    var first: String
    var last: String
    var email: String
    var phone: String
}

struct Response: Codable {
    let status: Int
    let message: String
    let body: [Contact]?
}

extension Color {
    static func random() -> Color {
        return Color(
            red:   .random(in: 0..<1),
           green: .random(in: 0..<1),
           blue:  .random(in: 0..<1)
        )
    }
}

```

## UI Code

Now for the UI, the entire view is in a NavigationView and List. This is very important, because if your loading cells and actual cells are in different lists, you get a jarring UI change.

```swift
struct ContentView: View {
    @StateObject var client = Client()
    
    @State private var search = ""
    
    var body: some View {
        NavigationView {
            List {
                switch client.loadingStatus {
                case .loading:
                    ForEach(0..<25) { item in
                        ContactLoadCell()
                    }
                case .success:
                    ForEach(searchResults, id: \.email) { contact in
                        ContactCell(contact: contact)
                    }
                case .error:
                    Text("Error")
                }
            }
            .navigationTitle("Contacts")
            .refreshable {
                await client.fetchData()
            }
            .searchable(text: $search) {
                
            }
        }
        .environmentObject(client)
    }
    
    var searchResults: [Contact] {
        if client.contacts == nil {
            return []
        } else if search.isEmpty {
            return client.contacts!
        } else {
//            return client.contacts!.filter { $0.first.contains(search) || $0.last.contains(search) }
            return client.contacts!.filter { $0.email.contains(search.lowercased()) || $0.phone.contains(search) }
        }
    }
}

struct ContactCell: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var client: Client
    
    var contact: Contact
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.random())
                    .frame(width: 60, height: 60)
                Text("\(String(contact.first.uppercased().prefix(1)))")
                    .font(.system(.title))
                    .foregroundColor(Color.white)
            }
            VStack(alignment: .leading) {
                Text("\(contact.first) \(contact.last)")
                    .font(.system(.headline))
                Group {
                    Text("\(contact.email)")
                        .font(.system(.caption))
                    Text("\(contact.phone)")
                        .font(.system(.caption))
                }
                .foregroundColor(colorScheme == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
            }
        }
    }
}

struct ContactLoadCell: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var client: Client
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Capsule()
                    .frame(height: 10)
                Capsule()
                    .frame(width: UIScreen.main.bounds.width / 3, height: 10)
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

And there it is, in around 200 lines of code you have a fully functioning contact list.

## Source

[Github](https://github.com/jake-landersweb/jake_code/tree/main/swift/searchableContacts)