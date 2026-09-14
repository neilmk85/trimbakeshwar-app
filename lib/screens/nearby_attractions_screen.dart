import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../services/language_service.dart';
import '../utils/app_images.dart';
import '../utils/app_route.dart';
import '../widgets/app_image.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';

String _catHi(String cat) {
  switch (cat) {
    case 'Nature & Trek': return 'प्रकृति और ट्रेक';
    case 'Sacred Site': return 'पवित्र स्थल';
    case 'Trek & Pilgrimage': return 'ट्रेक और तीर्थ';
    case 'Temple': return 'मंदिर';
    case 'Heritage': return 'विरासत';
    case 'Museum': return 'संग्रहालय';
    default: return cat;
  }
}

String _localCategory(String cat) =>
    LanguageService.isHindi.value ? _catHi(cat) : cat;

class NearbyAttractionsScreen extends StatelessWidget {
  const NearbyAttractionsScreen({super.key});

  static final List<_Attraction> _attractions = [
    _Attraction(
      name: 'Brahmagiri Mountain',
      description:
          'Sacred mountain from which the holy Godavari river originates. A 7 km trek leads to the summit with stunning views.',
      distance: '1 km',
      category: 'Nature & Trek',
      categoryColor: Color(0xFF2E7D32),
      assetPath: AppImages.brahmagiriParvat,
      gradientColors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
      icon: Icons.terrain_rounded,
      mapsQuery: 'Brahmagiri Mountain Trimbakeshwar',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'Brahmagiri mountain stands at an elevation of 4,248 feet (1,295 m) above sea level, located just 2 km from Trimbakeshwar town. It is one of the holiest mountains in Maharashtra and a major pilgrimage and trekking destination in the Sahyadri range.'),
        _Section(Icons.auto_awesome_rounded, 'Religious Significance',
            'According to Hindu scriptures, Brahmagiri is where Lord Brahma performed penance and where the sacred Godavari river was born. The mountain is home to several ancient temples and sacred spots revered for thousands of years. It is believed that a pilgrimage to Trimbakeshwar is incomplete without a visit to Brahmagiri.'),
        _Section(Icons.directions_walk_rounded, 'The Trek',
            'The Brahmagiri trek is approximately 7–8 km one way and typically takes 3–4 hours. The trail begins near the Trimbakeshwar temple and ascends through dense forests, ancient stone steps, and scenic viewpoints. The path is well-marked with iron railings at steep sections, making it manageable for most fitness levels.'),
        _Section(Icons.place_rounded, 'Key Sites Along the Trail',
            '• Gangadwar — The exact spot where the Godavari emerges from the rock\n• Amriteshwar Temple — Ancient Shiva temple midway up\n• Brahmagiri Summit — Panoramic 360° views of the Sahyadri ranges\n• Several small shrines and dhuni (sacred fire pits) maintained by sadhus\n• Natural water springs offering fresh water to trekkers'),
        _Section(Icons.wb_sunny_rounded, 'Best Time to Visit',
            'October to February offers the most pleasant trekking weather with clear skies and cool temperatures. Monsoon (June–September) brings lush greenery but paths become slippery and dangerous. Sunrise treks (starting at 5 AM) are especially rewarding.'),
        _Section(Icons.tips_and_updates_rounded, 'Tips for Visitors',
            '• Start early — before 6 AM for sunrise views\n• Carry at least 2 litres of water per person\n• Wear grip-sole trekking shoes\n• Avoid solo treks; go in groups\n• Mobile network is limited after the midpoint\n• Entry to the mountain is free\n• Guides are available near the temple for ₹200–₹400'),
      ],
    ),
    _Attraction(
      name: 'Kushavarta Kund',
      description:
          'A sacred tank considered the source of the Godavari river. Devotees take a holy dip here before visiting the Jyotirlinga temple.',
      distance: '0.3 km',
      category: 'Sacred Site',
      categoryColor: Color(0xFF1565C0),
      assetPath: AppImages.kushawartaKunda,
      gradientColors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
      icon: Icons.water_rounded,
      mapsQuery: 'Kushavarta Kund Trimbakeshwar',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'Kushavarta Kund is a sacred tank located just 300 metres from the Trimbakeshwar Jyotirlinga temple. It is considered the symbolic source of the River Godavari and is one of the most important ritual sites in Trimbakeshwar. The kund is always filled with pure spring-fed water and is surrounded by stone ghats on all four sides.'),
        _Section(Icons.menu_book_rounded, 'Mythological Significance',
            'According to the Padma Purana, the sage Gautama Rishi caught the Godavari river here using a blade of Kusha (sacred grass), giving this place its name — Kushavarta meaning "caught by Kusha". It is believed that the Goddess Godavari herself chose to reside permanently at this spot, making it the most sacred point of the river\'s course.'),
        _Section(Icons.water_drop_rounded, 'Rituals Performed',
            '• Snan (holy dip) — performed before entering the Jyotirlinga temple to purify oneself\n• Pind Daan — offerings made for the peace of departed ancestors\n• Tarpan — water libations offered to ancestors during Pitru Paksha\n• Asthi Visarjan — immersion of cremated ashes in the sacred water\n• Narayan Bali and Tripindi Shraddha rituals are also associated with this kund'),
        _Section(Icons.architecture_rounded, 'Architecture',
            'The kund is a large rectangular stepped tank built with black basalt stone. Stone ghats with wide steps descend into the water on all four sides. Several small shrines and temples surround the perimeter, including those dedicated to Lord Vishnu, Goddess Ganga, and Lord Ganesha. The kund was renovated and beautified in the 18th century by the Peshwas.'),
        _Section(Icons.wb_sunny_rounded, 'Best Time to Visit',
            'Early morning (4–7 AM) offers the most serene and spiritually charged experience. Amavasya (new moon day) and Purnima (full moon day) attract the largest number of devotees for special rituals. The Kumbh Mela period (held every 12 years at Trimbakeshwar) sees millions gather here.'),
        _Section(Icons.tips_and_updates_rounded, 'Visitor Information',
            '• Entry is free at all times\n• The kund is open 24 hours\n• Changing rooms and lockers are available nearby\n• Priests (pandas) are available to assist with rituals\n• Photography is generally allowed but be respectful during rituals\n• Footwear must be removed before entering the ghat area'),
      ],
    ),
    _Attraction(
      name: 'Anjneri Hill',
      description:
          'Believed to be the birthplace of Lord Hanuman. A popular trekking destination offering panoramic views of the Sahyadri mountain range.',
      distance: '7 km',
      category: 'Trek & Pilgrimage',
      categoryColor: Color(0xFFE65100),
      assetPath: AppImages.anjaneriHills,
      gradientColors: [Color(0xFFBF360C), Color(0xFFFF8A65)],
      icon: Icons.landscape_rounded,
      mapsQuery: 'Anjneri Hill Nashik',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'Anjneri Hill (also written as Anjaneri) is located approximately 7 km from Trimbakeshwar, rising to an elevation of about 4,265 feet (1,300 m). It is one of the most significant religious and trekking destinations in the Nashik region, drawing both devotees and trekking enthusiasts throughout the year.'),
        _Section(Icons.auto_awesome_rounded, 'Birthplace of Lord Hanuman',
            'Anjneri Hill is widely believed to be the Janmabhoomi (birthplace) of Lord Hanuman, the divine devotee of Lord Ram. The ancient Hanuman temple at the summit houses a swayambhu (self-manifested) idol of Lord Hanuman that is said to be thousands of years old. This belief is supported by several Puranic references and oral traditions of the region. The hill is named after Anjani Mata, the mother of Lord Hanuman.'),
        _Section(Icons.directions_walk_rounded, 'The Trek',
            'The trek to the summit is approximately 3–4 km one way and takes about 2–3 hours depending on pace and fitness. The trail begins from Anjneri village and ascends through thick deciduous forest. The first half is moderately steep with stone steps, while the upper section has rocky terrain with iron railings for safety. The summit rewards trekkers with breathtaking 360° views of the Sahyadri ranges, Trimbakeshwar town, and Nashik valley.'),
        _Section(Icons.park_rounded, 'Flora & Wildlife',
            'The Anjneri forest is a protected area rich in biodiversity. The forest supports:\n• Over 200 species of birds including eagles, kingfishers, and migratory species\n• Diverse butterflies and insects\n• Leopards, wild boar, and deer (rarely seen)\n• Rich medicinal plant diversity\n• Dense canopy of teak, flame-of-the-forest, and other indigenous trees'),
        _Section(Icons.temple_hindu_rounded, 'Summit Temple',
            'The ancient Anjani Mata temple and Hanuman temple at the summit are the main religious attractions. The Anjani Mata temple is dedicated to the mother of Lord Hanuman. Several other small shrines dot the summit plateau. Religious ceremonies are performed here on Hanuman Jayanti (Lord Hanuman\'s birthday) with thousands of devotees making the climb.'),
        _Section(Icons.wb_sunny_rounded, 'Best Time & Tips',
            '• Best months: October to February\n• Start before 6 AM to enjoy sunrise at the summit\n• Carry 2–3 litres of water; no water sources on the upper trail\n• Wear proper trekking shoes with good grip\n• Avoid trekking alone; join a group\n• The forest department charges a nominal entry fee\n• Local guides available at Anjneri village base'),
      ],
    ),
    _Attraction(
      name: 'Nivruttinath Temple',
      description:
          'Ancient temple dedicated to Sant Nivruttinath, the elder brother of Sant Dnyaneshwar and one of the most revered Warkari saints of Maharashtra.',
      distance: '0.5 km',
      category: 'Temple',
      categoryColor: Color(0xFF6A1B9A),
      assetPath: AppImages.nivruttinathTemple,
      gradientColors: [Color(0xFF4A148C), Color(0xFFAB47BC)],
      icon: Icons.temple_hindu_rounded,
      mapsQuery: 'Nivruttinath Temple Trimbakeshwar',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'The Nivruttinath Temple in Trimbakeshwar is dedicated to Sant Nivruttinath (1273–1297 CE), the eldest of the four famous saints of the Warkari Sampradaya (devotional tradition) in Maharashtra. The temple is an important pilgrimage site for followers of the Varkari tradition and attracts thousands of devotees annually.'),
        _Section(Icons.history_edu_rounded, 'About Sant Nivruttinath',
            'Sant Nivruttinath was born in Apegaon, Paithan in 1273 CE and passed away at Trimbakeshwar at the age of just 24. He was the disciple of Gahininath of the Nath tradition and the beloved guru of his younger brother, the philosopher-saint Sant Dnyaneshwar who wrote the famous Dnyaneshwari. Despite his short life, Nivruttinath composed many profound abhangas (devotional poems in Marathi) that are sung in temples across Maharashtra even today.'),
        _Section(Icons.menu_book_rounded, 'Religious Significance',
            'Nivruttinath is considered one of the founding pillars of the Bhakti (devotional) movement in Maharashtra. He introduced the Nath Sampradaya traditions into the Varkari devotional path, blending yoga, non-dualism, and devotion. His Sanjivani Samadhi (living samadhi) is believed to be at Trimbakeshwar, making this temple the site of his final spiritual liberation. Devotees believe that visiting this samadhi grants moksha (liberation).'),
        _Section(Icons.architecture_rounded, 'Temple Architecture',
            'The temple is built in the traditional Hemadpanthi style using black basalt stone, a construction technique popularised in the 13th century. The temple features intricately carved stone panels depicting scenes from the Puranas and the lives of saints. The sanctum houses a stone idol of Sant Nivruttinath in a seated meditative pose. The sabha mandap (assembly hall) has carved wooden pillars that are centuries old.'),
        _Section(Icons.celebration_rounded, 'Festivals & Events',
            '• Pushya Nakshatra (birth anniversary) — celebrated with great fervour every year\n• Kartiki Ekadashi — thousands of Warkari pilgrims visit as part of the Pandharpur Wari\n• Ashadhi Ekadashi — another major pilgrimage date\n• Daily aarti at 6 AM and 7 PM\n• Kirtan (devotional singing) performances held regularly in the temple courtyard'),
        _Section(Icons.tips_and_updates_rounded, 'Visitor Information',
            '• Temple timing: 5:30 AM to 12:00 PM and 4:00 PM to 9:00 PM\n• Entry is free for all devotees\n• Located just 500 m from the Jyotirlinga temple, easily walkable\n• Prasad (sacred food offering) is distributed during festival days\n• Photography inside the sanctum is restricted\n• Dress code: traditional attire preferred; avoid shorts and sleeveless clothing'),
      ],
    ),
    _Attraction(
      name: 'Gangadwar',
      description:
          'The exact point where the Godavari river emerges from Brahmagiri mountain — the true origin of the "Dakshin Ganga", one of India\'s most sacred rivers.',
      distance: '3 km',
      category: 'Sacred Site',
      categoryColor: Color(0xFF00695C),
      assetPath: AppImages.gangaDwar,
      gradientColors: [Color(0xFF004D40), Color(0xFF4DB6AC)],
      icon: Icons.water_drop_rounded,
      mapsQuery: 'Gangadwar Trimbakeshwar',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'Gangadwar (meaning "Gateway of the Ganga") is the sacred spot on the Brahmagiri mountain where the Godavari river first emerges from the rock as a natural spring. It marks the true geographical and spiritual source of the Godavari — the longest river in Peninsular India and one of India\'s most sacred rivers, revered as the "Dakshin Ganga" (Ganges of the South).'),
        _Section(Icons.auto_awesome_rounded, 'Spiritual Significance',
            'In Hindu cosmology, the Godavari is considered as sacred as the Ganges herself. According to the Puranas, the goddess Ganga, in the form of Godavari, chose Brahmagiri as her earthly abode at the request of the sage Gautama. Gangadwar is where this divine manifestation is most directly experienced. Taking a dip in the waters here during specific tithis (lunar dates) is believed to grant the merit of bathing at all holy rivers of India.'),
        _Section(Icons.water_drop_rounded, 'The Sacred Spring',
            'At Gangadwar, a natural spring emerges through a crack in the basalt rock, collecting in a small kund (sacred pool). The water is ice-cold, crystal clear, and flows continuously year-round. A shivalinga is installed at the water\'s source, and a small ancient temple complex surrounds the spring. The spot has an otherworldly atmosphere, especially in the early morning when mist rises from the water.'),
        _Section(Icons.directions_walk_rounded, 'How to Reach',
            'Gangadwar is accessible via the Brahmagiri trek:\n• Starting point: Near Trimbakeshwar Jyotirlinga temple\n• Distance: Approximately 3 km from the base\n• Trekking time: 1.5–2 hours one way\n• The path passes through dense forest with stone steps\n• It is a mandatory stop on the traditional Brahmagiri parikrama (circumambulation) circuit\n• The complete Brahmagiri parikrama (going up via Gangadwar and returning via a different path) takes 6–8 hours'),
        _Section(Icons.celebration_rounded, 'Special Occasions',
            '• Godavari Pushkaram — held once every 12 years, millions bathe here\n• Shravan Somvar (Mondays in the holy month of Shravan) — very auspicious\n• Makar Sankranti — special puja and dip\n• Guru Purnima — large gatherings of sadhus and devotees\n• Annual Brahmagiri parikrama organized by local trusts with thousands of participants'),
        _Section(Icons.tips_and_updates_rounded, 'Visitor Tips',
            '• Carry plenty of water for the trek as there are no shops beyond the base\n• Wear waterproof footwear — the area near the spring is wet\n• Start the trek by 6 AM to reach Gangadwar by morning\n• The spring water is safe to drink\n• Be cautious during and after monsoon — rocks are slippery\n• A priest is usually present to perform a quick puja for visitors'),
      ],
    ),
    _Attraction(
      name: 'Muktidham Temple',
      description:
          'A magnificent marble temple complex housing replicas of all 12 Jyotirlingas and all 18 chapters of the Bhagavad Gita inscribed on its walls.',
      distance: '28 km',
      category: 'Temple',
      categoryColor: Color(0xFF880E4F),
      assetPath: AppImages.muktidhamTemple,
      gradientColors: [Color(0xFF880E4F), Color(0xFFF48FB1)],
      icon: Icons.account_balance_rounded,
      mapsQuery: 'Muktidham Temple Nashik',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'Muktidham is a grand white marble temple complex located in Nashik city, approximately 28 km from Trimbakeshwar. It was built by the Muktidham Trust using Rajasthani white marble and is managed as a public charitable institution. The temple is unique in India for housing authentic replicas of all 12 Jyotirlingas, allowing devotees to complete a virtual pilgrimage to all 12 sacred shrines in a single visit.'),
        _Section(Icons.temple_hindu_rounded, 'The 12 Jyotirlingas',
            'The complex houses carefully crafted replicas of all 12 Jyotirlingas, modelled to match the original shrines:\n1. Somnath (Gujarat)\n2. Mallikarjuna (Andhra Pradesh)\n3. Mahakaleshwar (Madhya Pradesh)\n4. Omkareshwar (Madhya Pradesh)\n5. Kedarnath (Uttarakhand)\n6. Bhimashankar (Maharashtra)\n7. Kashi Vishwanath (Uttar Pradesh)\n8. Trimbakeshwar (Maharashtra)\n9. Vaidyanath (Jharkhand)\n10. Nageshwar (Gujarat)\n11. Rameshwaram (Tamil Nadu)\n12. Grishneshwar (Maharashtra)'),
        _Section(Icons.menu_book_rounded, 'Bhagavad Gita on Marble',
            'One of the most extraordinary features of Muktidham is that all 18 chapters (700 shlokas) of the Bhagavad Gita are inscribed in gold letters on white marble panels that line the walls of the temple complex. Each panel is beautifully framed and accompanied by translations. This makes the temple not just a place of worship but a living scripture — visitors can walk through and read the entire Gita as they circumambulate the complex.'),
        _Section(Icons.architecture_rounded, 'Architecture & Design',
            'The entire temple is constructed in pure white Rajasthani marble in the traditional nagara architectural style. The craftsmanship is exceptional — every pillar, wall, and ceiling is adorned with intricate floral and geometric carvings. The main sanctum has a beautifully carved sanctum tower (shikhara). The temple complex also includes:\n• A large assembly hall (sabha mandap) with carved pillars\n• Temples dedicated to Lord Ram, Sita, and Hanuman\n• Navagraha (nine planets) shrine\n• A meditation hall and serene gardens'),
        _Section(Icons.schedule_rounded, 'Visiting Information',
            '• Timing: 5:00 AM to 12:00 PM and 4:00 PM to 9:30 PM\n• Entry is free for all visitors\n• Photography is allowed throughout the complex\n• Free drinking water and toilets available\n• Located at Mumbai-Agra Highway, Nashik Road\n• Ample free parking available\n• The complex is well maintained and clean\n• Priests available for puja bookings'),
        _Section(Icons.tips_and_updates_rounded, 'Tips for Visitors',
            '• Allocate at least 2–3 hours to properly explore the entire complex\n• Visit on weekday mornings for a peaceful experience\n• The temple is especially beautiful when lit up in the evenings\n• Pair your visit with Pandavleni Caves (5 km away) and Sita Gufa for a full day trip\n• Dress code: traditional attire; remove footwear at the entrance\n• The inscribed Bhagavad Gita panels are an excellent educational resource for children'),
      ],
    ),
    _Attraction(
      name: 'Pandavleni Caves',
      description:
          'A group of 24 ancient Buddhist caves dating back to 1st century BCE, carved into the Trirashmi Hill near Nashik — a UNESCO-recognized heritage site.',
      distance: '30 km',
      category: 'Heritage',
      categoryColor: Color(0xFF4E342E),
      assetPath: AppImages.pandavleniCaves,
      gradientColors: [Color(0xFF3E2723), Color(0xFFA1887F)],
      icon: Icons.museum_rounded,
      mapsQuery: 'Pandavleni Caves Nashik',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'Pandavleni (also known as Trirashmi Buddhist Caves) is a group of 24 rock-cut caves carved into the Trirashmi Hill near Nashik city, approximately 30 km from Trimbakeshwar. These caves date from approximately 1st century BCE to 3rd century CE, placing them among the earliest examples of rock-cut architecture in India. They are protected by the Archaeological Survey of India (ASI).'),
        _Section(Icons.history_edu_rounded, 'Historical Background',
            'These caves were created during the Hinayana period of Buddhism by monks, wealthy merchants, and local rulers of the Satavahana dynasty. They served as viharas (monasteries) where monks lived, studied, and meditated, as well as chaityas (prayer halls) for worship. Inscriptions in the caves mention donations by traders, queens, and members of the royal court, providing valuable historical records of 2,000 years ago.'),
        _Section(Icons.architecture_rounded, 'Key Caves to Visit',
            '• Cave 3 (The Grand Chaitya): The largest and most impressive — a grand prayer hall with a stupa inside, ornately carved facade, and tall pillars. This is the centrepiece of the complex.\n• Cave 10: Contains a well-preserved Brahmi inscription recording donations by a merchant guild\n• Cave 18: Features detailed carvings of Buddhist figures including the Bodhisattva\n• Cave 20: Houses a large Buddha figure in meditation pose\n• Cave 23: Notable for its elaborately carved doorway\n• Several caves retain traces of original paintings and plaster'),
        _Section(Icons.museum_rounded, 'On-Site Museum',
            'A small but informative museum at the cave entrance displays:\n• Artifacts found during archaeological excavations\n• Ancient pottery, terracotta figurines, and coins\n• Scale models explaining the cave architecture\n• Photographs of excavation work\n• Educational panels on the history of Buddhism in the Nashik region\nEntry to the museum is included with the cave ticket.'),
        _Section(Icons.schedule_rounded, 'Visiting Information',
            '• Timings: 9:00 AM to 5:30 PM (closed on Fridays)\n• Entry fee: ₹25 for Indian nationals, ₹300 for foreign tourists (ASI rates)\n• Located on the Mumbai-Agra Highway near Nashik\n• The climb to the caves involves approximately 200 steps — not wheelchair accessible\n• Total visit duration: 1.5–2 hours\n• Official guide services available at the entrance for ₹150–₹250'),
        _Section(Icons.tips_and_updates_rounded, 'Photography & Tips',
            '• Morning visits (9–11 AM) offer the best natural light for photography\n• Photography is allowed without flash inside the caves\n• Carry water as there are no refreshment stalls inside\n• Wear comfortable walking shoes for the uneven rocky surfaces\n• Visit on weekdays for a quieter, more immersive experience\n• The view of Nashik city from the hilltop near the caves is excellent\n• Pair the visit with Muktidham Temple (5 km away) for a full heritage day'),
      ],
    ),
    _Attraction(
      name: 'Coin Museum, Nashik',
      description:
          'One of India\'s finest numismatic museums featuring rare coins spanning over 2,500 years of Indian monetary history from ancient punch-marked coins to modern currency.',
      distance: '32 km',
      category: 'Museum',
      categoryColor: Color(0xFF37474F),
      assetPath: AppImages.coinMuseum,
      gradientColors: [Color(0xFF263238), Color(0xFF78909C)],
      icon: Icons.museum_rounded,
      mapsQuery: 'Coin Museum Nashik',
      sections: [
        _Section(Icons.info_outline_rounded, 'Overview',
            'The Government of India\'s Coin Museum in Nashik is one of the finest numismatic (coin and currency) museums in the country. Operated by the Security Printing and Minting Corporation of India (SPMCIL), it is located near the India Security Press and Currency Note Press complex at Nashik Road. The museum offers a comprehensive journey through 2,500+ years of India\'s monetary history in beautifully curated galleries.'),
        _Section(Icons.history_edu_rounded, 'Historical Significance of Nashik',
            'Nashik has a deep connection with India\'s monetary history. The Currency Note Press (CNP) and India Security Press (ISP) in Nashik are among India\'s most important currency production facilities. The CNP prints a significant percentage of India\'s currency notes, while the ISP produces stamps, passports, and other security documents. The Coin Museum was established to showcase this heritage and educate the public about India\'s rich monetary past.'),
        _Section(Icons.collections_rounded, 'Collection Highlights',
            '• Janapada Period (600–300 BCE): Ancient silver punch-marked coins — among the world\'s earliest coins\n• Mauryan Empire: Coins of Chandragupta Maurya and Emperor Ashoka\n• Satavahana Dynasty: Lead and copper coins from the rulers of ancient Nashik\n• Gupta Period: Exquisite gold coins depicting kings in battle and hunting scenes\n• Mughal Era: Gold mohurs and silver rupees of emperors from Akbar to Aurangzeb\n• Maratha Coins: Silver Shivrai coins of Chhatrapati Shivaji Maharaj\n• British India: East India Company tokens, Anna and Pice series\n• Republic India: Evolution of Indian coins from 1950 to present day\n• Commemorative coins: Special series for independence, space missions, and cultural events'),
        _Section(Icons.science_rounded, 'The Minting Process',
            'A highlight of the museum is the section dedicated to the coin minting process. Visitors can learn how a coin is made — from the selection and refining of metal, to die preparation, blanking, annealing, and striking. Scale models and actual machinery displays bring this industrial process to life. The museum sometimes organises live demonstrations for student groups on request.'),
        _Section(Icons.schedule_rounded, 'Visiting Information',
            '• Timings: 10:00 AM to 5:00 PM\n• Closed on Mondays and all national/gazetted holidays\n• Entry is free for Indian citizens\n• Located at Security Press Road, Nashik Road (32 km from Trimbakeshwar)\n• Accessible by MSRTC bus (Nashik Road bus stand)\n• Ample parking available\n• Duration of visit: 1–1.5 hours\n• Photography allowed in designated areas only'),
        _Section(Icons.tips_and_updates_rounded, 'Tips for Visitors',
            '• Best suited for history enthusiasts, students, teachers, and coin collectors\n• Weekday mornings offer the quietest experience\n• The museum has informative bilingual (Hindi/English) display boards\n• A small gift shop sells replica coins and numismatic literature\n• Combine with Pandavleni Caves (nearby) for a complete heritage day trip\n• Entry may require a valid ID card; carry Aadhaar or similar\n• Special guided tours can be arranged for school groups by prior appointment'),
      ],
    ),
  ];

  /// Opens the detail screen for the attraction whose name best matches [name].
  static void openAttraction(BuildContext context, String name) {
    final lower = name.toLowerCase();
    final match = _attractions.firstWhere(
      (a) => a.name.toLowerCase().contains(lower) || lower.contains(a.name.toLowerCase()),
      orElse: () => _attractions.first,
    );
    Navigator.push(
      context,
      fadeSlideRoute((_) => _AttractionDetailScreen(attraction: match)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageService.isHindi,
      builder: (context, _, __) => Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBody: true,
      drawer: AppDrawer(
        selectedIndex: -1,
        onItemSelected: (i) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(initialScreenIndex: i)),
          (_) => false,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        onTap: (i) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: i)),
          (_) => false,
        ),
      ),
      body: Builder(
        builder: (ctx) {
          final cardWidth = (MediaQuery.of(ctx).size.width - 16 * 2 - 10) / 2;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  AppL10n.s.nearbyAttractions,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.appBarGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _attractions
                        .map((a) => SizedBox(width: cardWidth, child: _AttractionCard(attraction: a)))
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Section {
  final IconData icon;
  final String title;
  final String content;
  const _Section(this.icon, this.title, this.content);
}

class _Attraction {
  final String name;
  final String description;
  final String distance;
  final String category;
  final Color categoryColor;
  final String assetPath;
  final List<Color> gradientColors;
  final IconData icon;
  final String mapsQuery;
  final List<_Section> sections;

  const _Attraction({
    required this.name,
    required this.description,
    required this.distance,
    required this.category,
    required this.categoryColor,
    required this.assetPath,
    required this.gradientColors,
    required this.icon,
    required this.mapsQuery,
    required this.sections,
  });
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _AttractionCard extends StatelessWidget {
  final _Attraction attraction;
  const _AttractionCard({required this.attraction});

  void _openMaps() {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(attraction.mapsQuery)}');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      fadeSlideRoute((_) => _AttractionDetailScreen(attraction: attraction)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(src: attraction.assetPath, fit: BoxFit.cover,
                      fallbackColor: attraction.gradientColors.first),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_localCategory(attraction.category),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2)),
                    ),
                  ),
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(attraction.distance,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.s.attractionName(attraction.name),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(AppL10n.s.attractionDesc(attraction.name, attraction.description),
                      style: const TextStyle(fontSize: 10, color: AppColors.grey700, height: 1.45),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openDetail(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.read_more_rounded, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(AppL10n.s.readMore,
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  GestureDetector(
                    onTap: _openMaps,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.location_on_rounded, size: 22, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

}

// ── Attraction Detail Screen ──────────────────────────────────────────────────

class _AttractionDetailScreen extends StatefulWidget {
  final _Attraction attraction;
  const _AttractionDetailScreen({required this.attraction});

  @override
  State<_AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<_AttractionDetailScreen> {
  final _scrollController = ScrollController();
  bool _titleVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final heroHeight = MediaQuery.of(context).size.height * 0.62;
    // Show title when only ~kToolbarHeight + 16px of hero remains
    final threshold = heroHeight - kToolbarHeight - 16;
    final shouldShow = _scrollController.offset >= threshold;
    if (shouldShow != _titleVisible) setState(() => _titleVisible = shouldShow);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _openMaps() {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.attraction.mapsQuery)}');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final attraction = widget.attraction;
    final heroHeight = MediaQuery.of(context).size.height * 0.62;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            stretch: true,
            backgroundColor: attraction.gradientColors.first,
            elevation: 0,
            title: AnimatedOpacity(
              opacity: _titleVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                AppL10n.s.attractionName(attraction.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    src: attraction.assetPath,
                    fit: BoxFit.cover,
                    fallbackColor: attraction.gradientColors.first,
                  ),
                  // Bottom scrim
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.45, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.82),
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Title block
                  Positioned(
                    left: 20, right: 20, bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: attraction.categoryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_localCategory(attraction.category),
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppL10n.s.attractionName(attraction.name),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: 0.3,
                            shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded, size: 14, color: Colors.white70),
                            const SizedBox(width: 5),
                            Text('${attraction.distance} ${AppL10n.s.fromTemple}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Short description card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 14, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      AppL10n.s.attractionDesc(attraction.name, attraction.description),
                      style: const TextStyle(
                          fontSize: 14.5, color: Color(0xFF444444), height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...attraction.sections.asMap().entries.map((entry) => _SectionCard(
                      section: entry.value,
                      accentColor: attraction.categoryColor,
                      translatedTitle: AppL10n.s.attractionSectionTitle(attraction.name, entry.key, entry.value.title),
                      translatedContent: AppL10n.s.attractionSectionContent(attraction.name, entry.key, entry.value.content),
                  )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: Text(AppL10n.s.openInGoogleMaps,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: attraction.categoryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _Section section;
  final Color accentColor;
  final String? translatedTitle;
  final String? translatedContent;
  const _SectionCard({required this.section, required this.accentColor, this.translatedTitle, this.translatedContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(section.icon, size: 16, color: accentColor),
                ),
                const SizedBox(width: 10),
                Text(
                  translatedTitle ?? section.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Text(
              translatedContent ?? section.content,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF444444),
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
