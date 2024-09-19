//
//  TipItemView.swift
//  Slide Rule
//
//  Created by Rowan on 9/9/24.
//

import SwiftUI
import StoreKit

struct TipItemView: View {
    @EnvironmentObject private var store: TipStore
    
    var item: Product
    
    var body: some View {
        HStack(){
            VStack(spacing:3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(Color.theme.background)
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
                    .foregroundStyle(Color.theme.background)
                    .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .topLeading)
            }
            
            Spacer()
            
            Button{
                Task {
                    await store.purchase(item)
                }
            }label:{
                Text(item.displayPrice)
                    .foregroundStyle(Color.theme.background)
            }
            .tint(.blue)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(Color.theme.text, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
