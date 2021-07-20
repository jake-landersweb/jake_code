# SwiftUI 3: AsyncImage with Dyanmic Codable Session

iOS15 gave us a new view called AsyncImage. This view has been around for a long time in flutter, called NetworkImage. This allows you to fetch an image from the internet in real time while also showing preview and error views if anything were to go wrong. I decided to use a public image api for this.

<<Images>>

[Video Link](https://youtu.be/G3HiWe1d4Mg)

## Database

I decided to wrap the calls up in a super helpful data fetching function i wrote that is capable of returning dynamic types so you do not need to write the same function tons of times. I will expand on this idea further in another video/article.

```swift
enum methods {
    static let get = "GET"
}

enum Database {
    static let baseUrl = URL(string: "http://shibe.online/api")!
}

extension Database {
    static func request<T: Codable>(_ path: String, method: String) async -> T? {
        guard let url = URL(string: "\(baseUrl)\(path)") else {
            print("failed to create url components")
            return nil
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method
            // if doing a PUT or POST method, add:
            // request.httpBody = (object of type Data) = a object that has been encoded with a JSONEncoder().
            let (response, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: response)
            return data
        } catch {
            print("FATAL -- issue serializing request: \(error)")
            return nil
        }
    }
}
```
> Database.swift

## Client

Using this function, fetching data from the internet is a breeze.

```swift
class Client: ObservableObject {
    @Published var shibes: [String]?
    @Published var birds: [String]?
    @Published var cats: [String]?
    
    func fetchShibes() async {
        shibes = await Database.request("/shibes?count=25&urls=true&httpsUrls=true", method: methods.get)
    }
    
    func fetchBirds() async {
        birds = await Database.request("/birds?count=25&urls=true&httpsUrls=true", method: methods.get)
    }
    
    func fetchCats() async {
        cats = await Database.request("/cats?count=25&urls=true&httpsUrls=true", method: methods.get)
    }
}
```
> Client.swift

## View

Lastly, we can use these objects to paint our async image. First, we need to figure out how async image works. Here is a simple example.

```swift
AsyncImage(url: URL(string: image)) { phase in
    if let image = phase.image {
        image.resizable().aspectRatio(contentMode: .fit)
    } else if phase.error != nil {
        // error
        Color.red
    } else {
        // placeholder
        ImagePlaceHolder()
    }
}
.frame(height: 200)
.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
.padding(.horizontal)
```

We can use this in our dynamic view, like so.

```swift
struct ImageList: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var images: [String]?
    var title: String
    
    var body: some View {
        NavigationView {
            Group {
                if images != nil {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(images!, id:\.self) { image in
                                AsyncImage(url: URL(string: image)) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } else if phase.error != nil {
                                        // error
                                        Color.red
                                    } else {
                                        // placeholder
                                        ImagePlaceHolder()
                                    }
                                }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(.horizontal)
                            }
                        }
                    }
                    .background(colorScheme == .light ? Color(red: 245/255, green: 245/255, blue: 250/255, opacity: 1) : Color.black)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(title)
        }
    }
}
```

Throw in a nice image placeholder:

```swift
struct ImagePlaceHolder: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3)
            ProgressView()
        }
        .opacity(isAnimating ? 0.5 : 1)
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

And finally a host to wrap it all up.

```swift
struct ContentView: View {
    @StateObject var client = Client()
    
    var body: some View {
        TabView {
            ImageList(images: $client.shibes, title: "Shibes")
                .tabItem {
                    Label("Shibes", systemImage: "bolt")
                }
                .task {
                    await client.fetchShibes()
                }
            ImageList(images: $client.birds, title: "Birds")
                .tabItem {
                    Label("Birds", systemImage: "flame")
                }
                .task {
                    await client.fetchBirds()
                }
            ImageList(images: $client.cats, title: "Cats")
                .tabItem {
                    Label("Cats", systemImage: "leaf")
                }
                .task {
                    await client.fetchCats()
                }
        }
    }
}
```

And thats it! The task modifier on a view lets you asynchronously call a function on view appear, and is almost identical to:

```swift
.onAppear {
    async {
        await function()
    }
}
```

## Source Code:

[Github](https://github.com/jake-landersweb/jake_code/tree/main/swift/asyncImage)