//
//  MVVM.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/29.
//

import SwiftUI

final class MyManagerClass {

    func getData() async throws -> String {
        return "Some Data!"
    }
}

actor MyManagerActor {

    func getData() async throws -> String {
        return "Some Data!"
    }
}

@MainActor
final class MVVMViewModel: ObservableObject {

    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()

    @Published private(set) var myData = "Starting text"
    private var tasks: [Task<Void, Never>] = []

    func cancelTasks() {
        tasks.forEach { $0.cancel() }
        tasks = []
    }

    func onCallToActinoButtonPressed() {
        let task = Task {
            do {
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
                /*
                 다른 actor로부터 getData()를 하지만, 이때 데이터를 반환할 때는 Main Actor로 돌아옴
                 */
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
}

struct MVVM: View {

    @StateObject private var viewModel = MVVMViewModel()

    var body: some View {
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActinoButtonPressed()
            }
        }
    }
}

struct MVVM_Previews: PreviewProvider {
    static var previews: some View {
        MVVM()
    }
}
