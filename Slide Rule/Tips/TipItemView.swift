//
//  TipItemView.swift
//  Slide Rule
//
//  Copyright (c) 2024 Rowan Richards
//
//  This file is part of Ultimate Slide Rule
//
//  Ultimate Slide Rule is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by the
//  Free Software Foundation, either version 3 of the License, or 
//  (at your option) any later version.
//
//  Ultimate Slide Rule is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
//  See the GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License along with this program.
//  If not, see <https://www.gnu.org/licenses/>.
//
//  Created by Rowan on 9/9/24.
//

import SwiftUI
import StoreKit

struct TipItemView: View {
    @EnvironmentObject private var store: TipStore
    
    var item: Product
    
    @Binding var isSuccess: Bool
    
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
                    let result = await store.purchase(item)
                    if result {
                        isSuccess = true
                    }
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
