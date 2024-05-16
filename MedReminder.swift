import Foundation

// Simulated "database" for storing user and medication information
var users: [String: [String: Any]] = [:]
var sideEffectsData: [String: [String]] = [:]

func registerUser() -> String {
    print("\n--- Register New User ---")
    print("Please enter your name: ", terminator: "")
    let name = readLine()!
    print("Please enter your age: ", terminator: "")
    let age = readLine()!
    if users[name] != nil {
        print("Welcome back, \(name)!")
        return name
    }
    users[name] = ["name": name, "age": age, "medications": []]
    print("User \(name) registered successfully!\n")
    return name
}

func addMedication(user: String) {
    print("\n--- Add Medication ---")
    print("Enter the name of the medicine: ", terminator: "")
    let medName = readLine()!
    print("How many pills do you have in total? ", terminator: "")
    guard let totalPills = Int(readLine()!) else {
        print("Invalid input for total pills. Please enter a valid number.")
        return
    }
    print("How many pills per dose? ", terminator: "")
    guard let pillsPerDose = Int(readLine()!) else {
        print("Invalid input for pills per dose. Please enter a valid number.")
        return
    }
    print("How many hours between doses? ", terminator: "")
    guard let intervalHours = Int(readLine()!) else {
        print("Invalid input for interval hours. Please enter a valid number.")
        return
    }
    let nextDoseTime = Date().addingTimeInterval(TimeInterval(intervalHours) * 3600)
    
    let medication: [String: Any] = [
        "name": medName,
        "originalTotalPills": totalPills,  // Store original total for history
        "totalPills": totalPills,
        "pillsPerDose": pillsPerDose,
        "nextDoseTime": nextDoseTime,
        "doseTaken": 0  // Track the total number of pills taken
    ]
    if var userMedications = users[user]?["medications"] as? [[String: Any]] {
        userMedications.append(medication)
        users[user]?["medications"] = userMedications
    }
    print("Medication \(medName) added successfully!\n")
}

func showSchedule(user: String) {
    print("\n--- Current Medication Schedule ---")
    if let userMedications = users[user]?["medications"] as? [[String: Any]] {
        for med in userMedications {
            let nextDoseStr = (med["nextDoseTime"] as! Date).description(with: .current)
            let pillsLeft = med["totalPills"] as! Int
            let warningMsg = pillsLeft <= 3 ? " (Warning: Low on medication!)" : ""
            print("\(med["name"]!) - Next dose: \(nextDoseStr) - Pills taken: \(med["doseTaken"]!) - Pills left: \(pillsLeft)\(warningMsg)")
        }
    }
}

func takePills(user: String) {
    showSchedule(user: user)
    print("Enter the name of the medicine you are taking: ", terminator: "")
    let medName = readLine()!
    if let userMedications = users[user]?["medications"] as? [[String: Any]] {
        for medIndex in 0..<userMedications.count {
            if userMedications[medIndex]["name"] as? String == medName {
                var updatedMed = userMedications[medIndex]
                let totalPills = updatedMed["totalPills"] as! Int
                let pillsPerDose = updatedMed["pillsPerDose"] as! Int
                if totalPills >= pillsPerDose {
                    let updatedTotalPills = totalPills - pillsPerDose
                    updatedMed["totalPills"] = updatedTotalPills
                    let doseTaken = updatedMed["doseTaken"] as! Int
                    updatedMed["doseTaken"] = doseTaken + pillsPerDose
                    var updatedUserMeds = userMedications
                    updatedUserMeds[medIndex] = updatedMed
                    users[user]?["medications"] = updatedUserMeds
                    let warningMsg = updatedTotalPills <= 3 ? " (Warning: Low on medication!)" : ""
                    print("You have taken \(pillsPerDose) pills of \(medName). Pills left: \(updatedTotalPills)\(warningMsg)")
                    return
                } else {
                    print("Not enough pills left to take a dose of \(medName).")
                    return
                }
            }
        }
    }
    print("Medication not found.")
}

func updateMedication(user: String) {
    print("\n--- Update Medication ---")
    print("Enter the name of the medicine you want to update: ", terminator: "")
    let medName = readLine()!
    
    if var userMedications = users[user]?["medications"] as? [[String: Any]] {
        for medIndex in 0..<userMedications.count {
            if userMedications[medIndex]["name"] as? String == medName {
                print("Enter new total pills count: ", terminator: "")
                guard let newTotalPills = Int(readLine()!) else {
                    print("Invalid input for total pills. Please enter a valid number.")
                    return
                }
                print("Enter new pills per dose count: ", terminator: "")
                guard let newPillsPerDose = Int(readLine()!) else {
                    print("Invalid input for pills per dose. Please enter a valid number.")
                    return
                }
                print("Enter new interval hours: ", terminator: "")
                guard let newIntervalHours = Int(readLine()!) else {
                    print("Invalid input for interval hours. Please enter a valid number.")
                    return
                }
                
                // Update medication details
                userMedications[medIndex]["totalPills"] = newTotalPills
                userMedications[medIndex]["pillsPerDose"] = newPillsPerDose
                userMedications[medIndex]["nextDoseTime"] = Date().addingTimeInterval(TimeInterval(newIntervalHours) * 3600)
                
                users[user]?["medications"] = userMedications
                print("Medication \(medName) updated successfully!")
                return
            }
        }
        print("Medication not found.")
    }
}

func readSideEffectsCSV(filePath: String) {
    do {
        let csvFileContents = try String(contentsOfFile: filePath)
        let csvLines = csvFileContents.components(separatedBy: .newlines)
        for line in csvLines {
            let lineComponents = line.components(separatedBy: ",")
            if lineComponents.count >= 43 { // number of columns
                let medName = lineComponents[1]
                let sideEffects = Array(lineComponents[7..<47]) // Extract side effects columns
                sideEffectsData[medName] = sideEffects.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            }
        }
    } catch {
        print("Error reading CSV file:", error)
    }
}

func printSideEffectsForMedication(medName: String) {
    if let sideEffects = sideEffectsData[medName] {
        print("\nSide Effects for \(medName):")
        for effect in sideEffects {
            print("- \(effect)")
        }
    } else {
        print("No side effects found for \(medName).")
    }
}

func mainMenu() -> String {
    print("\n--- Main Menu ---")
    print("1. Register User or Login")
    print("2. Add Medication")
    print("3. Show Medication Schedule")
    print("4. Take Pills")
    print("5. View Pills History")
    print("6. Update Medication")
    print("7. Delete Medication")
    print("8. Print Side Effects for Medication")
    print("9. Exit")

    print("Enter choice: ", terminator: "")
    return readLine()!
}

func viewPillsHistory(user: String) {
    print("\n--- Pills History ---")
    if let userMedications = users[user]?["medications"] as? [[String: Any]] {
        for med in userMedications {
            let originalTotal = med["originalTotalPills"] as! Int
            let pillsTaken = med["doseTaken"] as! Int
            let pillsLeft = med["totalPills"] as! Int
            print("\(med["name"]!) - Original Total Pills: \(originalTotal), Total Pills Taken: \(pillsTaken), Pills Left: \(pillsLeft)")
        }
    }
}

func deleteMedication(user: String) {
    print("\n--- Delete Medication ---")
    print("Enter the name of the medication you want to delete: ", terminator: "")
    let medName = readLine()!
    if var userMedications = users[user]?["medications"] as? [[String: Any]] {
        userMedications = userMedications.filter { ($0["name"] as? String)?.lowercased() != medName.lowercased() }
        users[user]?["medications"] = userMedications
        print("Medication \(medName) deleted successfully!\n")
    } else {
        print("No medications found for deletion.")
    }
}



func main() {
    // Load side effects data from CSV file
    readSideEffectsCSV(filePath: "/Users/khaznahalhajri/Desktop/aplprojectlvlv/aplprojectlvlv/sideEff.csv")
    
    var currentUser: String? = nil
    while true {
        let choice = mainMenu()
        switch choice {
        case "1":
            currentUser = registerUser()
        case "2":
            if let currentUser = currentUser {
                addMedication(user: currentUser)
            } else {
                print("Please register a user first!")
            }
        case "3":
            if currentUser != nil {
                showSchedule(user: currentUser!)
            } else {
                print("No user registered!")
            }
        case "4":
            if currentUser != nil {
                takePills(user: currentUser!)
            } else {
                print("No user registered or medication added!")
            }
        case "5":
            if currentUser != nil {
                viewPillsHistory(user: currentUser!)
            } else {
                print("No user registered or medication added!")
            }
        case "6":
            if currentUser != nil {
                updateMedication(user: currentUser!)
            } else {
                print("No user registered or medication added!")
            }
        case "7":
            if currentUser != nil {
                deleteMedication(user: currentUser!)
            } else {
                print("No user registered!")
            }
        case "8":
            print("\n--- Side Effects ---")
            print("Enter the name of the medication: ", terminator: "")
            let medName = readLine()!
            printSideEffectsForMedication(medName: medName)
        case "9":
            print("Exiting program.")
            return
        default:
            print("Invalid choice, please try again!")
        }
    }
}

main()
