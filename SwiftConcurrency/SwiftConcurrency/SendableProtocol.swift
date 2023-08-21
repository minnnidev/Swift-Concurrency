//
//  SendableProtocol.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/21.
//

import SwiftUI

/*
Sendable Protocol
- Value types
- Reference types with no mutable storage
*/

actor CurrentUserManager {

    // 1. value-semantic types (string)
//    func updateDatabase(userInfo: String) {
//
//    }

    // 2. struct
    func updateDatabase(userInfo: MyUserInfo) {

    }
}

// 2. struct - value type
struct MyUserInfo: Sendable {
    let name: String
}

// 3. class - reference type이지만, final 키워드를 적어주면 다른 클래스가 상속 불가
// -> 클래스 내의 프로퍼티는 변경되지 않는다(let), 다른 참조가 생기지 않는다
final class MyClassUserInfo: Sendable {
    let name: String

    init(name: String) {
        self.name = name
    }
}

// 4. class - 다른 참조는 생기지 않지만, var로 선언함으로써 프로퍼티 값이 변경될 수 있음
//final class MyClassUserInfo1: Sendable {
//    var name: String
//
//    init(name: String) {
//        self.name = name
//    }
//}

// 5. 4번의 해결 방법 - @unchecked 키워드 + custom DispatchQueue 만들어 주기
// @unchecked -> 컴파일러에게 이 Sendable을 체크하지 말라고 함. 프로그래머가 sendable인지 직접 체크하여 보장하겠다
final class MyClassUserInfo1: @unchecked Sendable {
    private var name: String
    let queue = DispatchQueue(label: "queue")

    init(name: String) {
        self.name = name
    }

    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}


class SendableViewModel: ObservableObject {

    let manager = CurrentUserManager()

    func updateCurrentUserInfo() async {
//        let info = "User Info"
//        await manager.updateDatabase(userInfo: info)
        let info = MyUserInfo(name: "user info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableProtocol: View {

    @StateObject private var viewModel = SendableViewModel()

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SendableProtocol_Previews: PreviewProvider {
    static var previews: some View {
        SendableProtocol()
    }
}
