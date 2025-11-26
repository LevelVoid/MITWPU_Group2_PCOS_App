import Foundation

//Symptoms enums
enum Spotting{
    case red, brown
}

enum Discharge{
    case dry, sticky, creamy, watery, eggWhite, unusual, positionCervix, textureChange, other
}

enum Pain{
    case abdominalCramp, tenderBreasts, lowerBackPain, headache, vulvarPain, other
}

enum SkinAndHair{
    case acne, hairLoss, skinDarkening, hirsutism
}

enum Lifestyle{
    case fatigue, insomnia, depressed, anxiety
}

enum GutHealth{
    case bloating, constipation, diarrhoea, gas, heartburn
}

enum BreastHealth{
    case fine, engorgement, lump, dimple, redness, cracks, pain, nippleDischarge
}


//Diet enums
enum ImpactTags: String, Codable, CaseIterable {

    // Cycle / Symptom
    case bloatingTrigger
    case bloatingReducer
    case crampTrigger
    case crampReducer
    case periodPainTrigger
    case periodPainReducer

    // Hormonal
    case estrogenBoosting
    case estrogenLowering
    case progesteroneSupporting
    case pcosFriendly
    case pcosTrigger
    case androgenBoosting
    case androgenLowering
    case dairySensitive
    case glutenSensitive
    case soySensitive

    // Insulin & Metabolism
    case insulinSpiking
    case insulinBalancing
    case highInsulinLoad
    case lowInsulinLoad
    case highGlycemic
    case mediumGlycemic
    case lowGlycemic

    // Macros
    case highProtein
    case lowProtein
    case highFibre
    case lowFibre
    case healthyFats
    case unhealthyFats
    case highCarb
    case lowCarb

    // Inflammation
    case antiInflammatory
    case proInflammatory

    // Mood / Energy
    case moodBoost
    case energyBoost

    // Processing
    case processed
    case ultraProcessed
    case wholeFood

    // Sugar
    case sugary
    case artificialSweetener
    case noAddedSugar

    // Stimulants
    case caffeine
    case chocolate

    // Digestive
    case gasForming
    case gutFriendly
}


struct Users{
    let id: UUID
    let name: String
    let password: String
    let dob: Date
    var height: Double
    var weight: Double
    var symptoms: [Symptoms]?
    var diet: [Food]?
    var medicines: [String]?
    

    init(id: UUID, name: String, password: String, dob: Date, height: Double, weight: Double, symptoms: [Symptoms]? = nil, diet: [Food]? = nil, medicines: [String]? = nil) {
        self.id = id
        self.name = name
        self.password = password
        self.dob = dob
        self.height = height
        self.weight = weight
        self.symptoms = symptoms
        self.diet = diet
        self.medicines = medicines
    }
    
    
}

struct Symptoms{
    var spotting: Spotting
    var discharge: Discharge
    var pain: [Pain]
    var skinAndHair: [SkinAndHair]
    var lifestyle: [Lifestyle]
    var gutHealth: [GutHealth]
    var breastHealth: BreastHealth
    var timeStamp: Date
}

struct Food{
    let id: UUID
    var name: String
    var image: String?
    var timeStamp: Date
    var quantity: Double
    var proteinContent: Double
    var carbsContent: Double
    var fatsContent: Double
    var fibreContent: Double
    var tags: [ImpactTags]
    var calories: Double{
        return (proteinContent * 4) + (carbsContent * 4) + (fatsContent * 9)
    }
}





