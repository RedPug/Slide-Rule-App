//
//  TipStore.swift
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

import Foundation
import StoreKit

typealias PurchaseResult = Product.PurchaseResult
typealias TransactionLister = Task<Void, Error>

enum TipsError: LocalizedError {
    case failedVerification
    case system(Error)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case .system(let err):
            return err.localizedDescription
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification
    case system(Error)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case .system(let err):
            return err.localizedDescription
        }
    }
}

enum TipsAction: Equatable {
    case successful
    case failed(TipsError)
    
    static func == (lhs: TipsAction, rhs: TipsAction) -> Bool {
            
        switch (lhs, rhs) {
        case (.successful, .successful):
            return true
        case (let .failed(lhsErr), let .failed(rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
class TipStore: ObservableObject {
    
    @Published private(set) var items = [Product]()
    @Published private(set) var action: TipsAction? {
        didSet {
            switch action {
            case .failed:
                hasError = true
            default:
                hasError = false
            }
        }
    }
    @Published var hasError = false
    
    private var transactionListener: TransactionLister?
    
    var error: TipsError? {
        switch action {
        case .failed(let err):
            return err
        default:
            return nil
        }
    }
    
    init() {
        
        transactionListener = configureTransactionListener()
        
        Task {
            await retrieveProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }

    func purchase(_ item: Product) async {
        
        do {
            
            let result = try await item.purchase()
            
            try await handlePurchase(from: result)
            
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }
    
    /// Call to reset the action state within the store
    func reset() {
        action = nil
    }
    
    /// Create a listener for transactions that don't come directly via the purchase function
    func configureTransactionListener() -> TransactionLister {
        
        Task { [weak self] in
            
            do {
               
                for await result in Transaction.updates {
                    
                    let transaction = try self?.checkVerified(result)
                    
                    self?.action = .successful
                    
                    await transaction?.finish()
                }
                
            } catch {
                self?.action = .failed(.system(error))
            }
        }
    }
    
    /// Get all of the products that are on offer
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: tipProductIdentifiers)
            items = products.sorted(by: { $0.price < $1.price })
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }
    
    /// Handle the result when purchasing a product
    func handlePurchase(from result: PurchaseResult) async throws {
        
        switch result {
            
        case .success(let verification):
            print("Purchase was a success, now it's time to verify their purchase")
            let transaction = try checkVerified(verification)
          
            action = .successful
            
            await transaction.finish()
            
        case .pending:
            print("The user needs to complete some action on their account before they can complete purchase")
            
        case .userCancelled:
            print("The user hit cancel before their transaction started")
            
        default:
            print("Unknown error")
            
        }
    }
    
    /// Check if the user is verified with their purchase
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("The verification of the user failed")
            throw TipsError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
