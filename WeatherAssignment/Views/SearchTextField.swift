//
//  SearchTextField.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 20/01/26.
//

import SwiftUI
import UIKit

struct SearchTextField: UIViewRepresentable {

    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .search
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.clearButtonMode = .whileEditing
        textField.delegate = context.coordinator

        // Left search icon
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        iconView.frame = CGRect(x: 8, y: 0, width: 20, height: 24)
        iconContainer.addSubview(iconView)
        textField.leftView = iconContainer
        textField.leftViewMode = .always

        // Adjust height by setting content inset
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, UITextFieldDelegate {
        private let parent: SearchTextField

        init(_ parent: SearchTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            parent.onSubmit()
            return true
        }
    }
}
