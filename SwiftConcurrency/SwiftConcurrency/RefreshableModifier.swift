//
//  RefreshableModifier.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/29.
//

import SwiftUI

final class RefreshableModifierDataService {

    func getData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        return ["Apple", "Orange", "Banana"].shuffled()
    }
}

@MainActor
final class RefreshableModifierViewModel: ObservableObject {

    @Published private(set) var items: [String] = []
    let manager = RefreshableModifierDataService()

//    func loadData() {
//        Task {
//            do {
//                items = try await manager.getData()
//            } catch {
//                print(error)
//            }
//        }
//    }

    func loadData() async {
        do {
            print("getData() 전")
            items = try await manager.getData()
            print("getData() 후")
        } catch {
            print(error)
        }
    }
}

struct RefreshableModifier: View {

    @StateObject private var viewModel = RefreshableModifierViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .refreshable { // 호출하는 함수가 무엇이든 비동기 함수로 만든다
//                viewModel.loadData()
                await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
//            .onAppear {
////                viewModel.loadData()
//            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

struct RefreshableModifier_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableModifier()
    }
}
