//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/13.
//

import SwiftUI

/*
Async Let
*/

struct AsyncLet: View {

    @State private var images: [UIImage] = []
    @State private var navigationTitle: String = ""
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let 🐳")
            .onDisappear {
                self.images.removeAll()
            }
            .onAppear {
                /*
                 1. Task 안은 직렬 실행 - 완성 캡처하기
                 */
//                Task {
//                    let image1 = try await fetchImage()
//                    self.images.append(image1)
//
//                    let image2 = try await fetchImage()
//                    self.images.append(image2)
//
//                    let image3 = try await fetchImage()
//                    self.images.append(image3)
//
//                    let image4 = try await fetchImage()
//                    self.images.append(image4)
//                }

                /*
                2. 병렬 실행되도록 하나의 Task로 나누기
                 코드가 길어지고, 작업을 취소하려면 번거롭다
                 */
//                Task {
//                    let image1 = try await fetchImage()
//                    self.images.append(image1)
//                }
//
//                Task {
//                    let image2 = try await fetchImage()
//                    self.images.append(image2)
//                }
//
//                Task {
//                    let image3 = try await fetchImage()
//                    self.images.append(image3)
//                }
//
//                Task {
//                    let image4 = try await fetchImage()
//                    self.images.append(image4)
//                }

                /*
                 3. 여러 작업을 호출하고 정확히 동시에 실행되도록 하기
                 화면에 한번에 나타날 수 있어 깔끔하다
                 개수가 많을 때는 Task Group을 살펴보자
                 Task를 취소하거나, 우선 순위를 부여할 때도 하위 async let에 모두 적용됨
                 */
                Task {
                    do {
                        async let fetchImage1 = fetchImage() // no await keyword
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()

                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4) // one await keyword
//                        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
//
//                        // 왜 await 앞에 try 붙이면 안 됑?
//
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                    } catch {

                    }
                }
            }
        }
    }

    func fetchTitle() async ->  String {
        return "New Title"
    }

    func fetchImage() async throws -> UIImage {
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

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}
