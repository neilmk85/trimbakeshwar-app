import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppData {
  AppData._();

  // ── Navigation ──────────────────────────────
  static const List<String> navTitles = [
    'Trimbakeshwar',
    'Guruji',
    'Temple',
    'Pooja',
    'Gallery',
    'Contact',
  ];

  static const List<IconData> navIcons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.temple_hindu_rounded,
    Icons.auto_awesome_rounded,
    Icons.photo_library_rounded,
    Icons.contact_phone_rounded,
  ];

  // ── Pooja List (8 cards) ────────────────────
  static const List<Map<String, dynamic>> poojas = [
    {
      'name': 'Narayan Nagbali',
      'icon': Icons.auto_awesome,
      'desc':
          'Performed for the liberation of ancestors and removal of ancestral curses.',
      'duration': '3 Days',
      'color': AppColors.poojaBlue,
      'info':
          'Narayan Nagbali is a 3-day ritual performed at Trimbakeshwar, the only authorized place for this ceremony. It addresses two separate issues — Nagbali removes the sin of killing a snake (especially a cobra), and Narayan Nagbali is performed to get rid of debts owed to ancestors and liberate their souls.',
      'beforeInstructions': <String>[
        'Take a holy bath before arriving at the temple',
        'Wear clean, traditional attire (dhoti for men, saree for women)',
        'Observe a fast (at least partial) on the day of commencement',
        'Avoid non-vegetarian food and alcohol for 3 days prior',
        'Bring all required family members as the ritual involves the entire family',
      ],
      'afterInstructions': <String>[
        'Maintain celibacy for 3 days post ritual',
        'Avoid non-vegetarian food and alcohol for 11 days',
        'Perform daily prayers and light a lamp at home',
        'Donate to Brahmins as instructed by the priest',
        'Offer water to the Peepal tree daily for 11 days',
      ],
      'thingsToBring': <String>[
        'White dhoti and saree (traditional attire)',
        'Fruits, flowers, and coconuts',
        'Puja samagri as advised by the priest',
        'Identity proof documents',
        'Booking confirmation receipt',
      ],
    },
    {
      'name': 'Kalsarpa Shanti',
      'icon': Icons.all_inclusive,
      'desc':
          'Remedy for Kalsarpa Dosha in one\'s horoscope for peace and prosperity.',
      'duration': '1 Day',
      'color': AppColors.poojaTeal,
      'info':
          'Kalsarpa Dosha occurs when all planets are positioned between Rahu and Ketu in a person\'s horoscope. This powerful Shanti pooja performed at Trimbakeshwar neutralizes the malefic effects of this dosha, bringing peace, prosperity, and removing obstacles in life.',
      'beforeInstructions': <String>[
        'Take a holy bath in the morning before the pooja',
        'Wear clean clothes — preferably white or light-colored',
        'Carry your horoscope details (date, time, place of birth)',
        'Observe fast until the pooja is completed',
        'Arrive at least 30 minutes before the scheduled time',
      ],
      'afterInstructions': <String>[
        'Offer milk to a snake idol or live snake if possible',
        'Light a lamp with sesame oil on Saturdays',
        'Donate black sesame seeds and iron items to the poor',
        'Chant "Om Namah Shivaya" 108 times daily for 40 days',
        'Avoid harming any snake or reptile',
      ],
      'thingsToBring': <String>[
        'Horoscope chart (kundali)',
        'Black sesame seeds (til)',
        'Blue or black cloth',
        'Puja samagri as specified by the pandit',
        'Coconut, fruits, and flowers',
      ],
    },
    {
      'name': 'Tripindi Shraddha',
      'icon': Icons.local_fire_department,
      'desc':
          'Sacred ritual to provide peace to departed souls of three generations.',
      'duration': '1 Day',
      'color': AppColors.poojaPurple,
      'info':
          'Tripindi Shraddha is a powerful ritual performed to provide peace to the departed souls of three generations of ancestors. When the souls of ancestors are troubled or dissatisfied, it causes obstacles in the life of their descendants. This ritual pacifies those souls and removes generational blockages.',
      'beforeInstructions': <String>[
        'Observe partial fast on the day of the ritual',
        'Take a holy bath early in the morning',
        'Wear traditional white or cream-colored clothes',
        'Bring details of deceased family members (names if known)',
        'Avoid consuming non-vegetarian food and alcohol before the ritual',
      ],
      'afterInstructions': <String>[
        'Feed crows as they are believed to carry messages to ancestors',
        'Donate food to Brahmins',
        'Light a diya (lamp) daily for 15 days',
        'Offer water to the Peepal tree for 15 days',
        'Perform tarpan (offering of water) to ancestors',
      ],
      'thingsToBring': <String>[
        'Black sesame seeds',
        'White rice',
        'Banana leaves',
        'Flowers and incense sticks',
        'Puja samagri as advised',
      ],
    },
    {
      'name': 'Rudra Abhishek',
      'icon': Icons.water_drop,
      'desc':
          'Holy bathing ceremony of Lord Shiva\'s Jyotirlinga with sacred items.',
      'duration': '2-3 Hours',
      'color': AppColors.poojaGreen,
      'info':
          'Rudra Abhishek is the ceremonial bathing of the Shiva Linga with sacred substances such as milk, honey, ghee, yogurt, and water. Performed with Vedic chanting of the Rudra mantras, it is believed to please Lord Shiva and bestow his blessings for health, prosperity, and removal of negativity.',
      'beforeInstructions': <String>[
        'Take a bath and wear clean clothes before arriving',
        'Observe fast or eat only sattvic food on the day',
        'Maintain a calm and devotional mindset',
        'Arrive punctually as the ritual begins at specific auspicious times',
        'Inform the priest of specific wishes or sankalpa in advance',
      ],
      'afterInstructions': <String>[
        'Distribute prasad (milk, fruits) to devotees',
        'Chant "Om Namah Shivaya" throughout the day',
        'Avoid anger and negative emotions for the day',
        'Visit the Jyotirlinga for darshan after the abhishek',
        'Light a camphor lamp at home in the evening',
      ],
      'thingsToBring': <String>[
        'Milk (at least 1 litre)',
        'Honey, ghee, and yogurt',
        'Sacred Ganga jal (Ganges water)',
        'Bilva (bel) leaves',
        'White and yellow flowers',
      ],
    },
    {
      'name': 'Mahamrityunjay Jaap',
      'icon': Icons.self_improvement,
      'desc':
          'Chanting of the powerful Mahamrityunjay mantra for health and longevity.',
      'duration': '1 Day',
      'color': AppColors.poojaRed,
      'info':
          'The Mahamrityunjay Mantra is one of the most powerful mantras in the Vedas, dedicated to Lord Shiva as the conqueror of death. The Jaap ritual involves repetitive chanting of this mantra 125,000 times by trained pandits. It is performed for health, longevity, and protection from untimely death.',
      'beforeInstructions': <String>[
        'Take a holy bath before the ritual',
        'Wear red or orange clothing if possible',
        'Carry the name and details of the person for whom the jaap is performed',
        'Observe at least partial fast on the day',
        'Maintain a calm and reverent attitude throughout the ceremony',
      ],
      'afterInstructions': <String>[
        'Perform havan (fire ritual) at the conclusion of the jaap',
        'Distribute prasad to all attendees',
        'Feed Brahmins as dakshina for the jaap',
        'Chant the Mahamrityunjay mantra at least 11 times daily thereafter',
        'Offer water to the Shiva Linga daily for 11 days',
      ],
      'thingsToBring': <String>[
        'Rudraksha mala for personal chanting',
        'Flowers — particularly marigold',
        'Sandalwood paste (chandan)',
        'Bhasma (sacred ash)',
        'Puja samagri as specified by the pandit',
      ],
    },
    {
      'name': 'Vastu Shanti',
      'icon': Icons.home_work,
      'desc':
          'Pooja to remove Vastu doshas and bring positive energy to your home.',
      'duration': '4-5 Hours',
      'color': AppColors.poojaOrange,
      'info':
          'Vastu Shanti is a sacred ritual performed to harmonize the energies of a living or working space according to Vastu Shastra principles. It removes negative energies, corrects Vastu defects, and invites positive vibrations, health, and prosperity into the premises.',
      'beforeInstructions': <String>[
        'Clean the house or premises thoroughly before the ritual',
        'Inform the priest about the specific Vastu concerns',
        'Ensure all family members are present during the ritual',
        'Prepare a clean space for the ritual setup',
        'Bring floor plan or photographs of the property if the ritual is not at the site',
      ],
      'afterInstructions': <String>[
        'Place a Vastu yantra at the main entrance',
        'Light a lamp at the northeast corner of the house daily',
        'Avoid structural changes for 40 days',
        'Plant tulsi (holy basil) in the northeast direction',
        'Keep the main entrance clean and well-lit at all times',
      ],
      'thingsToBring': <String>[
        'Property documents or photographs',
        'Specific Vastu yantra (as advised by pandit)',
        'Copper vessel (kalash)',
        'Flowers, fruits, and incense',
        'Puja samagri as specified',
      ],
    },
    {
      'name': 'Laghu Rudra Pooja',
      'icon': Icons.temple_hindu,
      'desc':
          'A shorter version of Rudra Pooja invoking the blessings of Lord Shiva.',
      'duration': '1 Day',
      'color': AppColors.poojaDeepPurple,
      'info':
          'Laghu Rudra Pooja is a condensed yet highly potent form of Rudra Pooja, performed by invoking Lord Shiva\'s divine blessings. It involves the recitation of the Shri Rudram eleven times, making it a powerful ceremony for removing obstacles, gaining divine grace, and achieving overall wellbeing.',
      'beforeInstructions': <String>[
        'Observe fast or eat only sattvic food on the day of the pooja',
        'Take a holy bath and wear clean traditional clothes',
        'Bring your sankalpa (wish or intent) to share with the priest',
        'Maintain celibacy on the day of the pooja',
        'Arrive on time as the ritual follows strict auspicious timings',
      ],
      'afterInstructions': <String>[
        'Offer coconut and flowers at the Shiva temple after the pooja',
        'Chant "Om Namah Shivaya" 108 times daily for 11 days',
        'Donate to Brahmins or the underprivileged',
        'Avoid non-vegetarian food for 3 days after the pooja',
        'Light an oil lamp at home every evening for 11 days',
      ],
      'thingsToBring': <String>[
        'White flowers (especially dhatura)',
        'Bel leaves (bilva patra)',
        'Milk and water for abhishek',
        'Sandalwood paste and camphor',
        'Puja samagri as specified by the priest',
      ],
    },
    {
      'name': 'Navgrah Shanti',
      'icon': Icons.stars,
      'desc':
          'Pooja to pacify the nine planets and reduce malefic effects in horoscope.',
      'duration': '4-5 Hours',
      'color': AppColors.poojaDarkTeal,
      'info':
          'Navgrah Shanti is performed to pacify the nine planets (Navagrahas) and minimize their malefic effects on one\'s life. Based on one\'s horoscope, specific planetary positions can cause obstacles, delays, or health issues. This ritual offers relief by invoking the blessings of all nine planetary deities.',
      'beforeInstructions': <String>[
        'Carry your complete horoscope (kundali) with exact birth details',
        'Take a holy bath and wear clean clothes',
        'Observe fast or eat only light food on the day',
        'Arrive early to discuss specific planetary issues with the pandit',
        'Avoid non-vegetarian food and alcohol for 3 days prior',
      ],
      'afterInstructions': <String>[
        'Wear the gemstone or yantra recommended by the pandit',
        'Donate items specific to the malefic planet (e.g., iron for Saturn)',
        'Light a ghee lamp on the day associated with the afflicting planet',
        'Chant the specific graha mantra 108 times daily',
        'Feed cows and birds regularly for 40 days after the ritual',
      ],
      'thingsToBring': <String>[
        'Horoscope chart with exact birth details',
        'Nine types of grains (navadhanya)',
        'Nine colored flowers',
        'Coconut, fruits, and sweets',
        'Puja samagri as specified by the pandit',
      ],
    },
  ];

  // ── Gallery Items ───────────────────────────
  static const List<Map<String, dynamic>> galleryItems = [
    {'name': 'Trimbakeshwar Temple', 'icon': Icons.temple_hindu, 'color': AppColors.poojaBlue},
    {'name': 'Jyotirlinga Darshan', 'icon': Icons.auto_awesome, 'color': AppColors.poojaDeepPurple},
    {'name': 'Brahmagiri Mountain', 'icon': Icons.terrain, 'color': AppColors.poojaGreen},
    {'name': 'Godavari Origin', 'icon': Icons.water, 'color': AppColors.poojaTeal},
    {'name': 'Kushavarta Teerth', 'icon': Icons.water_drop, 'color': AppColors.webBlue},
    {'name': 'Temple Architecture', 'icon': Icons.architecture, 'color': Color(0xFF4E342E)},
    {'name': 'Rudra Abhishek', 'icon': Icons.local_fire_department, 'color': AppColors.poojaRed},
    {'name': 'Evening Aarti', 'icon': Icons.nightlight_round, 'color': AppColors.poojaOrange},
    {'name': 'Nandi Mandap', 'icon': Icons.pets, 'color': Color(0xFF37474F)},
    {'name': 'Temple Entrance', 'icon': Icons.door_front_door, 'color': Color(0xFF5D4037)},
    {'name': 'Sacred Shivling', 'icon': Icons.circle, 'color': AppColors.navyDeep},
    {'name': 'Kumbh Mela', 'icon': Icons.groups, 'color': AppColors.poojaDarkTeal},
  ];

  // ── Temple Timings ──────────────────────────
  static const List<Map<String, String>> templeTimings = [
    {'event': 'Morning Darshan', 'time': '5:30 AM - 9:00 PM'},
    {'event': 'Afternoon Break', 'time': '12:00 PM - 4:00 PM'},
    {'event': 'Evening Darshan', 'time': '4:00 PM - 8:30 PM'},
    {'event': 'Rudrabhishek', 'time': '5:00 AM - 5:30 AM'},
  ];

  // ── Guruji Expertise ────────────────────────
  static const List<String> gurujiExpertise = [
    'Narayan Nagbali',
    'Kalsarpa Shanti',
    'Tripindi Shraddha',
    'Rudra Abhishek',
    'Mahamrityunjay Jaap',
    'Vastu Shanti',
    'Griha Pravesh',
    'Satyanarayan Pooja',
  ];

  // ── Guruji Stats ────────────────────────────
  static const List<Map<String, String>> gurujiStats = [
    {'number': '25+', 'label': 'Years\nExperience'},
    {'number': '10K+', 'label': 'Poojas\nPerformed'},
    {'number': '5K+', 'label': 'Happy\nDevotees'},
  ];
}
