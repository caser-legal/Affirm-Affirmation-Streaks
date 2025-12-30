import Foundation
import SwiftData

struct AffirmationSeeder {
    static func seedAffirmations(context: ModelContext) {
        let affirmations = getAllAffirmations()
        for (text, category) in affirmations {
            let affirmation = Affirmation(text: text, category: category)
            context.insert(affirmation)
        }
    }
    
    static func getAllAffirmations() -> [(String, AffirmationCategory)] {
        var all: [(String, AffirmationCategory)] = []
        all.append(contentsOf: selfLoveAffirmations.map { ($0, .selfLove) })
        all.append(contentsOf: confidenceAffirmations.map { ($0, .confidence) })
        all.append(contentsOf: gratitudeAffirmations.map { ($0, .gratitude) })
        all.append(contentsOf: successAffirmations.map { ($0, .success) })
        all.append(contentsOf: healthAffirmations.map { ($0, .health) })
        all.append(contentsOf: relationshipsAffirmations.map { ($0, .relationships) })
        all.append(contentsOf: morningAffirmations.map { ($0, .morning) })
        all.append(contentsOf: eveningAffirmations.map { ($0, .evening) })
        return all
    }
    
    static let selfLoveAffirmations = [
        "I am worthy of love and respect",
        "I accept myself unconditionally",
        "I am enough just as I am",
        "I deserve happiness and joy",
        "I love and appreciate my body",
        "I am proud of who I am becoming",
        "I forgive myself for past mistakes",
        "I am deserving of all good things",
        "I honor my needs and feelings",
        "I am beautiful inside and out",
        "I choose to be kind to myself",
        "I am worthy of my own love",
        "I embrace my unique qualities",
        "I am complete within myself",
        "I trust my journey",
        "I am at peace with who I am",
        "I celebrate my individuality",
        "I am gentle with myself",
        "I deserve self-compassion",
        "I am my own best friend",
        "I honor my boundaries",
        "I am worthy of taking up space",
        "I love myself deeply",
        "I am perfectly imperfect",
        "I embrace all parts of myself",
        "I am deserving of rest",
        "I choose self-love daily",
        "I am valuable and important",
        "I treat myself with kindness",
        "I am worthy of my dreams"
    ]
    
    static let confidenceAffirmations = [
        "I believe in my abilities",
        "I am confident and capable",
        "I trust myself completely",
        "I am strong and resilient",
        "I can achieve anything I set my mind to",
        "I am brave and courageous",
        "I face challenges with confidence",
        "I am worthy of success",
        "I trust my decisions",
        "I am powerful beyond measure",
        "I radiate confidence",
        "I am unstoppable",
        "I believe in my potential",
        "I am fearless in pursuit of my goals",
        "I trust my inner wisdom",
        "I am bold and assertive",
        "I embrace new challenges",
        "I am confident in my skin",
        "I speak with confidence",
        "I am worthy of respect",
        "I stand tall and proud",
        "I am capable of great things",
        "I trust my instincts",
        "I am confident in my choices",
        "I embrace my power",
        "I am secure in who I am",
        "I face fear with courage",
        "I am worthy of admiration",
        "I believe in myself fully",
        "I am confident and calm"
    ]
    
    static let gratitudeAffirmations = [
        "I am grateful for this moment",
        "I appreciate the abundance in my life",
        "I am thankful for my health",
        "I find joy in simple things",
        "I am blessed with wonderful people",
        "I appreciate my journey",
        "I am grateful for new opportunities",
        "I cherish every experience",
        "I am thankful for growth",
        "I appreciate my unique gifts",
        "I am grateful for love in my life",
        "I find beauty everywhere",
        "I am thankful for today",
        "I appreciate my strength",
        "I am grateful for lessons learned",
        "I cherish my relationships",
        "I am thankful for my home",
        "I appreciate every breath",
        "I am grateful for nature",
        "I find gratitude in challenges",
        "I am thankful for my body",
        "I appreciate my mind",
        "I am grateful for peace",
        "I cherish quiet moments",
        "I am thankful for abundance"
    ]
    
    static let successAffirmations = [
        "I am destined for success",
        "I attract opportunities effortlessly",
        "I am worthy of achieving my goals",
        "I create my own success",
        "I am focused and determined",
        "I turn obstacles into opportunities",
        "I am a magnet for prosperity",
        "I achieve everything I desire",
        "I am committed to my growth",
        "I celebrate my achievements",
        "I am on the path to greatness",
        "I attract success naturally",
        "I am worthy of abundance",
        "I create value in everything I do",
        "I am driven by purpose",
        "I embrace challenges as growth",
        "I am successful in all I do",
        "I attract wealth and prosperity",
        "I am worthy of recognition",
        "I achieve my goals with ease",
        "I am a successful person",
        "I create opportunities daily",
        "I am destined for greatness",
        "I attract positive outcomes",
        "I am worthy of my success"
    ]
    
    static let healthAffirmations = [
        "I am healthy and vibrant",
        "I nourish my body with love",
        "I am full of energy",
        "I honor my body's needs",
        "I am getting stronger every day",
        "I choose health and wellness",
        "I am grateful for my health",
        "I listen to my body",
        "I am healing and growing",
        "I treat my body with respect",
        "I am full of vitality",
        "I make healthy choices",
        "I am at peace with my body",
        "I nurture my wellbeing",
        "I am strong and healthy",
        "I honor my physical needs",
        "I am energized and alive",
        "I choose wellness daily",
        "I am grateful for my strength",
        "I love taking care of myself"
    ]
    
    static let relationshipsAffirmations = [
        "I attract loving relationships",
        "I am worthy of deep connections",
        "I give and receive love freely",
        "I am surrounded by supportive people",
        "I communicate with love and clarity",
        "I attract positive relationships",
        "I am deserving of healthy love",
        "I nurture my relationships",
        "I am open to giving and receiving",
        "I attract genuine connections",
        "I am loved and appreciated",
        "I create harmonious relationships",
        "I am worthy of true friendship",
        "I attract kind and caring people",
        "I communicate my needs clearly",
        "I am surrounded by love",
        "I build meaningful connections",
        "I am deserving of respect",
        "I attract loyal friends",
        "I am open to love"
    ]
    
    static let morningAffirmations = [
        "Today is full of possibilities",
        "I wake up with gratitude",
        "This day is a gift",
        "I am ready for a wonderful day",
        "I embrace today with joy",
        "I am energized and motivated",
        "Today I choose happiness",
        "I am excited for what's ahead",
        "I start this day with purpose",
        "I am grateful for this morning",
        "Today I will shine",
        "I am ready to make today great",
        "I welcome this new day",
        "I am filled with morning energy",
        "Today is my day to thrive",
        "I am blessed with a new beginning",
        "I embrace today's opportunities",
        "I am positive and optimistic",
        "Today I will be my best self",
        "I am grateful to be alive",
        "I start fresh today",
        "I am ready for success",
        "Today brings new blessings",
        "I am motivated and focused",
        "I embrace this beautiful morning"
    ]
    
    static let eveningAffirmations = [
        "I am grateful for today",
        "I release the day with peace",
        "I did my best today",
        "I am proud of my efforts",
        "I let go of today's worries",
        "I am at peace with myself",
        "I release what no longer serves me",
        "I am grateful for rest",
        "I embrace peaceful sleep",
        "I am thankful for today's lessons",
        "I release tension and stress",
        "I am ready for restful sleep",
        "I let go with gratitude",
        "I am at peace with today",
        "I embrace the quiet night",
        "I am grateful for this day",
        "I release and relax",
        "I am deserving of rest",
        "I let go of the day",
        "I am peaceful and calm",
        "I embrace healing sleep",
        "I am thankful for growth",
        "I release today with love",
        "I am ready for tomorrow",
        "I rest in gratitude"
    ]
}
