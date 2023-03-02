//
//  View++.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func errorAlert<E: LocalizedError, Content: View>(_ error: Binding<E?>, @ViewBuilder actions: @escaping (E, @escaping () -> Void) -> Content) -> some View {
        let wrappedValue = error.wrappedValue
        let title = wrappedValue?.errorDescription ?? ""
        alert(title, isPresented: .constant(wrappedValue != nil), presenting: wrappedValue) { err in
            actions(err) {
                error.wrappedValue = nil
            }
        } message: { error in
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            }
        }
    }
}
