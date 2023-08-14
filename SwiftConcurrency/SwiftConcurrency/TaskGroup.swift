//
//  TaskGroup.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/14.
//

import SwiftUI

/*
Task Group
*/

class TaskGroupDataManager {

    /*
     async let이 4번이 아니라, 10번, 50번이 된다면 확장성이 좋지 않음
     */
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/200")

        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)

        return [image1, image2, image3, image4]
    }

    /*
     Task group 사용해 보기
     child task는 당연히 fetchImage()일 것
    */
//    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
//        return try await withThrowingTaskGroup(of: UIImage.self) { group in
//            var images: [UIImage] = []
//
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//
//            for try await image in group {
//                images.append(image)
//            }
//
//            return images
//        }
//    }

    /*
     Task group을 사용하는 이유 - 수동으로 작업을 추가할 필요 없이 많은 작업을 추가할 수 있음
     */
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200"
        ]

        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = [] // image 개수 == urlStrings 개수임을 알 수 있음
            images.reserveCapacity(urlStrings.count) // 충분한 공간 예약 -> 아주 약간의 성능 향상

            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                    // 실패했을 때, 전체 작업 실패보다 nil을 반환하게 하기 위해 옵셔널로 변경
                }
            }

            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }

            return images
        }
    }

    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL ) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupViewModel: ObservableObject {

    @Published var images: [UIImage] = []
    let manager = TaskGroupDataManager()

    func getImages() async {
//        if let images = try? await manager.fetchImagesWithAsyncLet() {
//            self.images.append(contentsOf: images)
//        }

        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroup: View {

    @StateObject private var viewModel = TaskGroupViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]


    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 🐳")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroup_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroup()
    }
}
