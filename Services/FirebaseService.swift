import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// A service class that handles all Firebase Firestore operations for the Obese Food application.
/// This class provides methods for managing user and food data in the Firestore database.
class FirebaseService {
    /// The Firestore database instance
    private let db = Firestore.firestore()
    /// Collection name for storing user data
    private let usersCollection = "users"
    /// Collection name for storing obese food data
    private let foodsCollection = "obese_foods"
    
    /// Adds a new user to the Firestore database
    /// - Parameters:
    ///   - user: The user object to be added
    ///   - completion: A completion handler that returns a Result type
    ///   - Result: Returns void on success, Error on failure
    func addUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection(usersCollection).document(user.id.uuidString).setData(from: user)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
  
    /// Fetches a user from the Firestore database by their UUID
    /// - Parameters:
    ///   - userId: The UUID of the user to fetch
    ///   - completion: A completion handler that returns a Result type
    ///   - Result: Returns User object on success, Error on failure
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
    
    /// Adds a new obese food item to the Firestore database
    /// - Parameters:
    ///   - food: The ObeseFood object to be added
    ///   - completion: A completion handler that returns a Result type
    ///   - Result: Returns void on success, Error on failure
    func addObeseFood(food: ObeseFood, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection(foodsCollection).document(food.id.uuidString).setData(from: food)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    /// Fetches all obese food items from the Firestore database
    /// - Parameter completion: A completion handler that returns a Result type
    /// - Result: Returns an array of ObeseFood objects on success, Error on failure
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