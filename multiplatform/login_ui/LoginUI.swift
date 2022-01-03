//
//  LoginUI.swift
//
//  This is a sample page for loginUI that works on both iOS and macOS
//
//  Created by Jake Landers on 1/2/22.
//

import Foundation
import SwiftUI


class LoginModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    let color1 = Color.red
    let color2 = Color.orange
    
    func onSubmit() {
        print("submitted ...")
    }
    
    func forgotPassword() {
        print("forgot password ...")
    }
}

struct LoginUI: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var model = LoginModel()
    
    @FocusState var focused: Field?
    
    // available text fields
    enum Field {
        case name
        case email
        case password
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // all fields with background of a linear gradient to allow for dynamic sizing before wave
            fields
                .padding(32)
                .background(LinearGradient(gradient: Gradient(colors: [model.color1, model.color2]), startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea(.keyboard)
            // wave with same color as bottom of gradient to blend
            Image("wave")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(model.color2)
                .frame(height: 100)
            // spacer
            Rectangle().frame(width: 0, height: 16)
            // google and apple sign in buttons
            signInButtons
            // space from bottom of screen
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor(colorScheme: colorScheme))
        .onTapGesture {
            // hide keyboard on tap
            hideKeyboard()
        }
    }
    
    private var fields: some View {
        VStack(spacing: 16) {
            // name field
            FieldWrapper(field: $model.name, isFocused: focused == .name, label: "Name", icon: "person", color1: model.color1, color2: model.color2)
                .focused($focused, equals: .name)
                .submitLabel(.next)
            // if on iOS, show a different keyboard
            #if canImport(UIKit)
                .textContentType(.givenName)
            #endif
            // email field
            FieldWrapper(field: $model.email, isFocused: focused == .email, label: "Email", icon: "mail", color1: model.color1, color2: model.color2)
                .focused($focused, equals: .email)
                .submitLabel(.next)
            // if on iOS, show a different keyboard
            #if canImport(UIKit)
                .textContentType(.emailAddress)
            #endif
            // password field
            FieldWrapper(field: $model.password, isFocused: focused == .password, label: "Password", icon: "lock", obscure: true, color1: model.color1, color2: model.color2)
                .focused($focused, equals: .password)
                .textContentType(.password)
                .submitLabel(.go)
            // login button
            Button(action: {
                model.onSubmit()
            }) {
                Text("Submit")
                    .foregroundColor(Color.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.0001))    // to make entire button clickable
                    .overlay(
                        // add a white border around button
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 16)
            Button(action: {
                model.forgotPassword()
            }) {
                Text("Forgot your password?")
                    .foregroundColor(Color.black)
                    .opacity(0.5)
                    .font(.system(size: 14, weight: .light))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onSubmit {
            // when defined submit key is clicked, perform a different action
            switch focused {
            case .name:
                focused = .email
            case .email:
                focused = .password
            default:
                // login code here
                model.onSubmit()
            }
        }
    }
    
    #if os(macOS)
    // show HStack sign in buttons on macOS
    private var signInButtons: some View {
        HStack(spacing: 16) {
            // google
            googleButton
            // apple
            appleButton
        }
        .padding(.horizontal, 32)
    }
    #else
    // show VStack sign in buttons on every other platform
    private var signInButtons: some View {
        VStack(spacing: 16) {
            // google
            googleButton
            // apple
            appleButton
        }
        .padding(.horizontal, 32)
    }
    #endif
    
    private var googleButton: some View {
        Button(action: {
            print("sign in with google")
        }) {
            signInButtonHelper(image: "google", label: "Sign in with Google", labelColor: (colorScheme == .light ? Color.black : Color.white).opacity(0.7), imageBg: colorScheme == .light ? Color.clear : Color.white, cellBg: colorScheme == .light ? Color.white : Color(.sRGB, red: 66/255, green: 133/255, blue: 244/255, opacity: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var appleButton: some View {
        Button(action: {
            print("sing in with apple")
        }) {
            signInButtonHelper(image: "apple", label: "Sign in with Apple", labelColor: Color.black, imageBg: Color.clear, cellBg: Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // wrapper for sign in buttons to help with code reusability
    private func signInButtonHelper(image: String, label: String, labelColor: Color, imageBg: Color, cellBg: Color) -> some View {
        return ZStack(alignment: .center) {
            // logo
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(imageBg)
                    Image(image)
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .frame(width: 40, height: 40)
                Spacer()
            }
            .padding(.leading, 5)
            // text
            Text(label)
                .foregroundColor(labelColor)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(cellBg)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

// basic field wrapper to give some built in functionality with icons and shapes
struct FieldWrapper: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var field: String
    var isFocused: Bool
    let label: String
    let icon: String
    var obscure = false
    var color1 = Color.blue
    var color2 = Color.green
    
    var body: some View {
        HStack(spacing: 16) {
            // show highlighted icon when field is actively being edited
            if isFocused {
                LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .top, endPoint: .bottom)
                    .mask(Image(systemName: icon))
                    .frame(width: 32)
            } else {
                Image(systemName: icon)
                    .frame(width: 32)
            }
            // show obscure text field when specified
            if obscure {
                SecureField(label, text: $field)
                    .textFieldStyle(PlainTextFieldStyle())
            } else {
                TextField(label, text: $field)
                    .textFieldStyle(PlainTextFieldStyle())
            }
        }
        .accentColor(color2)    // text line color
        .padding(16)
        .frame(height: 50)
        .background(cellColor(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
}

// static colors
fileprivate func backgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color(.sRGB, red: 240/255, green: 240/255, blue: 250/255, opacity: 1) : Color(.sRGB, red: 40/255, green: 40/255, blue: 40/255, opacity: 1)
}

fileprivate func textColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.black : Color.white
}

fileprivate func cellColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.white : Color(.sRGB, red: 80/255, green: 80/255, blue: 80/255, opacity: 1)
}

extension View {
    func hideKeyboard() {
        #if canImport(UIKit)
        // hide keyboard on iOS devices
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #elseif os(macOS)
        // hide keyboard on macOS
        NSApp.keyWindow?.makeFirstResponder(nil)
        #endif
        // do nothing on any other device
    }
}

#if os(macOS)
// remove ring around NSTextFields on MacOS
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
#endif
