//
//  StrongSelf.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/28.
//

import SwiftUI

/*
How to manage strong & weak references with Async Await
*/

final class StrongSelfDataService {

    func getData() async -> String {
        return "Updated data!"
    }
}

final class StrongSelfViewModel: ObservableObject {

    @Published var data = "Some title!"
    let dataService = StrongSelfDataService()

    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>] = []

    func cancelTasks() {
        someTask?.cancel()
        someTask = nil

        myTasks.forEach { $0.cancel() }
        myTasks = []
    }

    /*
     Q. 요기서 self.data를 참조할 때 왜 참조를 관리하지 않나요?
     A. 일단 updateData() 함수 자체는 다른 선언을 하지 않았으므로 강한 참조
        getData()가 비동기 함수이므로 얼마나 오래 걸릴지 모른다. 즉시 실행될 수도 있고, 5분 있다 실행될 수도 있다.
        그동안 StrongSelfViewModel이 할당 해제될 가능성이 있다.
        강한 참조이므로 이 함수가 완료될 때까지 StrongSelfViewModel은 해제될 수 없음
     */
    // Strong Reference
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }

    /*
     updateData()와 완전히 동일한 기능을 함
     self를 붙이는 것의 필요성 -> 파라미터로 동일한 이름을 사용할 때
     파라미터인지 클래스 안의 프로퍼티인지 구분하는 것 정도?
     개인적으로 봐왔던 코드들에선 self를 꼭 사용할 때만 쓰고 지양하는 경우가 많았음
     */
    // Strong Reference
    func updateData2(data: String) {
        Task {
            self.data = await dataService.getData()
        }
    }

    // Strong Reference
    func updateData3() {
        Task { [self] in
            self.data = await dataService.getData()
        }
    }

    // weak reference
    /*
     Q. 이 함수도 잘 작동하는데... 닉 선생님은 왜 이때까지 약한 참조를 쓰지 않았나여?
     A. reference가 Task 안에 있기 때문임!
        우리는 Task로 참조를 관리할 수 있다.
        참조를 제거하려면 해당 작업을 취소하면 됨
     */
    func updateData4() {
        /*
         Reference to property 'dataService' in closure requires explicit use of 'self' to make capture semantics explicit; this is an error in Swift 6
         */
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }

    /*
     We don't need to mangage week/strong
     we can manage the Task!
     */
    func updateData5() {
        someTask = Task {
            self.data = await dataService.getData()
        }
    }

    // we can manage the task
    func updateData6() {
        let task1 = Task {
            self.data = await dataService.getData()
        }

        myTasks.append(task1)

        let task2 = Task {
            self.data = await dataService.getData()
        }

        myTasks.append(task2)
    }

    // we purposely do not cancel tasks to keep strong reference
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }

        Task.detached { // 분리된 Task로 사용
            self.data = await self.dataService.getData()
        }
    }

    func updateData8() async {
        self.data = await self.dataService.getData()
    }
}

struct StrongSelf: View {

    @StateObject private var viewModel = StrongSelfViewModel()

    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                /*
                 이 task는 SwiftUI View에 의해 관리되어 자동으로 취소됨
                 */
                await viewModel.updateData8()
            }
    }
}

struct StrongSelf_Previews: PreviewProvider {
    static var previews: some View {
        StrongSelf()
    }
}
