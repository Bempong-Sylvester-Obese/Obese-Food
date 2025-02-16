import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseService {
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let foodsCollection = "obese_foods"
    
    func addUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection(usersCollection).document(user.id.uuidString).setData(from: user)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func fetchUser(byId userId: UUID, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection(usersCollection).document(userId.uuidString).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(.success(user))
                } catch let error {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "UserNotFound", code: 404, userInfo: nil)))
            }
        }
    }
    
    func addObeseFood(food: ObeseFood, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection(foodsCollection).document(food.id.uuidString).setData(from: food)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func fetchObeseFoods(completion: @escaping (Result<[ObeseFood], Error>) -> Void) {
        db.collection(foodsCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.failure(NSError(domain: "NoData", code: 404, userInfo: nil)))
                return
            }
            
            let foods: [ObeseFood] = documents.compactMap { document in
                return try? document.data(as: ObeseFood.self)
            }
            completion(.success(foods))
        }
    }
}
