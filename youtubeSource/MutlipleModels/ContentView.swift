//
//  ContentView.swift
//  Multiple Sheets
//
//  Created by Jake Landers on 7/4/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var controller = SheetController()
    
    var body: some View {
        if controller.showHome {
            Home()
        } else {
            WelcomeScreen(controller: controller)
                .accentColor(.red)
        }
    }
}

struct Home: View {
    var body: some View {
        Text("Home")
    }
}

struct WelcomeScreen: View {
    @ObservedObject var controller: SheetController
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Background()
            VStack {
                Image("netflix")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                // style buttons ....
                Button(action: {
                    controller.sheet = .createAccount(controller: controller)
                }, label: {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                })
                Button(action: {
                    controller.sheet = .login(controller: controller)
                }, label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .light ? Color.black.opacity(0.15) : Color.white.opacity(0.3))
                        .foregroundColor(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                })
            }
            .padding(.horizontal)
            .padding(.vertical, 50)
            .frame(width: UIScreen.main.bounds.width)
        }
        .sheet(isPresented: $controller.showSheet, content: {
            controller.sheetView()
        })
    }
}

// make viwe for login pages
// time to customize ...
struct Login: View {
    @ObservedObject var controller: SheetController
    var isCreate: Bool
    
    enum Field {
        case email
        case password
        case repeatPassword
    }
    // for controlling the field ...
    @FocusState private var focusedField: Field?
    
    @State var email: String = ""
    @State var password: String = ""
    @State var repeatPassword: String = ""
    
    @State var errorText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Email", text: $email)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                    SecureField("Password", text: $password)
                        .submitLabel(isCreate ? .next : .go)
                        .focused($focusedField, equals: .password)
                    if isCreate {
                        SecureField("Repeat Password", text: $repeatPassword)
                            .submitLabel(.go)
                            .focused($focusedField, equals: .repeatPassword)
                    }
                }
                Section {
                    Button(isCreate ? "Create Account" : "Login", action: {
                        action()
                    })
                        .foregroundColor(.red)
                }
                if errorText != "" {
                    Section {
                        Text(errorText).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isCreate ? "Create Account" : "Login")
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit {
                // for performing what to do when user clicks go on keyboard
                switch focusedField {
                case .email:
                    focusedField = .password
                case .password:
                    isCreate ? focusedField = .repeatPassword : action()
                default:
                    action()
                }
            }
        }
    }
    
    // input validation
    func action() {
        withAnimation {
            if email == "" {
                errorText = "Email cannot be empty"
            } else if !email.contains(".co") || !email.contains("@") {
                errorText = "Email is invalid"
            } else if password == "" {
                errorText = "Password cannot be empty"
            } else if password.count < 3 {
                errorText = "Password is too short"
            } else if isCreate && password != repeatPassword {
                errorText = "Passwords do not match"
            } else {
                print("form is valid")
                errorText = ""
                controller.showHome = true
            }
        }
    }
}

// make fancy background
struct Background: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Group {
                colorScheme == .light ? Color.black.opacity(0.15) : Color.white.opacity(0.15)
            }
            VStack {
                Group {
                    colorScheme == .light ? Color.white : Color.black
                }
                .frame(height: UIScreen.main.bounds.height / 2)
                Spacer()
            }
            Group {
                colorScheme == .light ? Color.black.opacity(0.15) : Color.white.opacity(0.15)
            }
            .frame(width: 1000, height: UIScreen.main.bounds.height / 3)
            .rotationEffect(Angle(degrees: -45))
        }
        .rotationEffect(Angle(degrees: -30))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
