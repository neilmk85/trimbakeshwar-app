import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_l10n.dart';
import '../constants/constants.dart';
import '../services/language_service.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Mantra {
  final String name;
  final String deity;
  final Color color;
  final FaIconData? icon;
  final String? textIcon; // Devanagari/Unicode symbol rendered as Text
  final String devanagari;
  final String transliteration;
  final String meaning;
  final List<String> benefits;

  const _Mantra({
    required this.name,
    required this.deity,
    required this.color,
    this.icon,
    this.textIcon,
    required this.devanagari,
    required this.transliteration,
    required this.meaning,
    required this.benefits,
  });
}

const _mantras = [
  _Mantra(
    name: 'Mahamrityunjaya Mantra',
    deity: 'Lord Shiva',
    color: AppColors.poojaRed,
    textIcon: 'ॐ',
    devanagari:
        'ॐ त्र्यम्बकं यजामहे\nसुगन्धिं पुष्टिवर्धनम् ।\n'
        'उर्वारुकमिव बन्धनान्\nमृत्योर्मुक्षीय माऽमृतात् ॥',
    transliteration:
        'Om Tryambakam Yajamahe\nSugandhim Pushti-Vardhanam |\n'
        'Urvarukamiva Bandhanan\nMrityor Mukshiya Maamritat ||',
    meaning:
        'We worship the three-eyed Lord Shiva who is fragrant and who nourishes '
        'all beings. As the cucumber is severed from its bondage to the creeper, '
        'may He liberate us from death and grant us immortality.',
    benefits: [
      'Bestows health, healing, and longevity',
      'Protection from untimely or accidental death',
      'Liberation from the cycle of birth and death',
      'Removes fear and brings inner peace',
    ],
  ),
  _Mantra(
    name: 'Gayatri Mantra',
    deity: 'Devi Gayatri · Surya',
    color: AppColors.poojaOrange,
    icon: FontAwesomeIcons.sun,
    devanagari:
        'ॐ भूर्भुवः स्वः ।\nतत्सवितुर्वरेण्यम् ।\n'
        'भर्गो देवस्य धीमहि ।\nधियो यो नः प्रचोदयात् ॥',
    transliteration:
        'Om Bhur Bhuvah Svah |\nTat Savitur Varenyam |\n'
        'Bhargo Devasya Dhimahi |\nDhiyo Yo Nah Prachodayat ||',
    meaning:
        'We meditate on the glorious splendour of the divine Sun, the creator '
        'of all three realms. May that divine light illuminate and guide '
        'our intellect on the path of righteousness.',
    benefits: [
      'Awakens wisdom and sharpens the intellect',
      'Purifies the mind and removes negativity',
      'Brings clarity, focus, and spiritual growth',
      'One of the most powerful universal mantras',
    ],
  ),
  _Mantra(
    name: 'Om Namah Shivaya',
    deity: 'Lord Shiva',
    color: AppColors.primary,
    textIcon: 'ॐ',
    devanagari: 'ॐ नमः शिवाय ॥',
    transliteration: 'Om Namah Shivaya ||',
    meaning:
        'I bow to the auspicious Lord Shiva. The five syllables Na-Ma-Shi-Va-Ya '
        'represent the five elements — Earth, Water, Fire, Air, and Ether — '
        'and collectively invoke the pure cosmic consciousness of Shiva.',
    benefits: [
      'Purifies the soul and removes ego',
      'Daily chanting invites Shiva\'s grace',
      'Calms the mind and reduces anxiety',
      'Removes obstacles and grants liberation (moksha)',
    ],
  ),
  _Mantra(
    name: 'Shiv Panchakshara Stotram',
    deity: 'Lord Shiva',
    color: AppColors.poojaPurple,
    icon: FontAwesomeIcons.dharmachakra,
    devanagari:
        'नागेन्द्रहाराय त्रिलोचनाय\nभस्माङ्गरागाय महेश्वराय ।\n'
        'नित्याय शुद्धाय दिगम्बराय\nतस्मै नकाराय नमः शिवाय ॥\n\n'
        'मन्दाकिनीसलिलचन्दनचर्चिताय\nनन्दीश्वरप्रमथनाथमहेश्वराय ।\n'
        'मन्दारपुष्पबहुपुष्पसुपूजिताय\nतस्मै मकाराय नमः शिवाय ॥',
    transliteration:
        'Nagendraharaya Trilochanaya\nBhasmaangaraagaya Maheshwaraya |\n'
        'Nityaya Shuddhaya Digambaraya\nTasmai Nakaraaya Namah Shivaya ||\n\n'
        'Mandakinisalilachandanacharchitaaya\nNandishvarapramathanathamaheshwaraya |\n'
        'Mandaarapushpabahupushpasupujitaaya\nTasmai Makaraaya Namah Shivaya ||',
    meaning:
        'Salutations to Shiva adorned with a garland of serpents, the three-eyed '
        'one, smeared with sacred ash, the great lord. Salutations to the one '
        'worshipped with Mandara and many other flowers, bathed in Mandakini '
        'waters with sandalwood. Each verse salutes one syllable of Na-Ma-Shi-Va-Ya.',
    benefits: [
      'Removes sins and purifies the devotee',
      'Invokes all five aspects of Lord Shiva',
      'Recitation grants divine blessings and protection',
      'Leads to spiritual liberation',
    ],
  ),
  _Mantra(
    name: 'Ganesh Mantra',
    deity: 'Lord Ganesha',
    color: AppColors.poojaOrange,
    icon: FontAwesomeIcons.crown,
    devanagari:
        'ॐ गं गणपतये नमः ।\n\n'
        'वक्रतुण्ड महाकाय\nसूर्यकोटि समप्रभ ।\n'
        'निर्विघ्नं कुरु मे देव\nसर्वकार्येषु सर्वदा ॥',
    transliteration:
        'Om Gam Ganapataye Namah |\n\n'
        'Vakratunda Mahakaya\nSuryakoti Samaprabha |\n'
        'Nirvighnam Kuru Me Deva\nSarvakaryeshu Sarvada ||',
    meaning:
        'Salutations to Lord Ganesha, the one with a curved trunk and mighty '
        'body, radiant as a million suns. O Lord, please remove all obstacles '
        'from all my endeavours at all times.',
    benefits: [
      'Removes obstacles from any new beginning',
      'Invoked before all prayers and rituals',
      'Bestows wisdom, success, and good fortune',
      'Protects against negative energies',
    ],
  ),
  _Mantra(
    name: 'Shri Rudram — Namakam',
    deity: 'Lord Rudra (Shiva)',
    color: AppColors.poojaTeal,
    icon: FontAwesomeIcons.fire,
    devanagari:
        'ॐ नमस्ते रुद्र मन्यव\nउतो त इषवे नमः ।\nनमस्ते अस्तु धन्वने\nबाहुभ्यामुत ते नमः ॥\n\n'
        'या त इषुः शिवतमा\nशिवं बभूव ते धनुः ।\nशिवा शरव्या या तव\nतया नो रुद्र मृडय ॥',
    transliteration:
        'Om Namaste Rudra Manyava\nUto Ta Ishave Namah |\nNamaste Astu Dhanvane\nBahubhyamuta Te Namah ||\n\n'
        'Ya Ta Ishuh Shivatama\nShivam Babhuva Te Dhanuh |\nShiva Sharavya Ya Tava\nTaya No Rudra Mridaya ||',
    meaning:
        'O Rudra, salutations to your wrath; salutations also to your arrow. '
        'Salutations to your bow; salutations to your two arms. '
        'O Rudra, with your most auspicious arrow, your bow and your quiver, '
        'grant us happiness and relief from suffering.',
    benefits: [
      'Chanted during Rudra Abhishek at Trimbakeshwar',
      'Pacifies Rudra\'s fierce energy into benevolence',
      'Removes disease, sorrow, and misfortune',
      'One of the oldest Vedic hymns (Rigveda)',
    ],
  ),
  _Mantra(
    name: 'Shiv Tandav Stotra',
    deity: 'Lord Shiva · Composed by Ravana',
    color: Color(0xFF4527A0),
    icon: FontAwesomeIcons.boltLightning,
    devanagari:
        'जटाटवीगलज्जलप्रवाहपावितस्थले\n'
        'गलेऽवलम्ब्य लम्बितां भुजङ्गतुङ्गमालिकाम् ।\n'
        'डमड्डमड्डमड्डमन्निनादवड्डमर्वयं\n'
        'चकार चण्डताण्डवं तनोतु नः शिवः शिवम् ॥१॥\n\n'
        'जटाकटाहसम्भ्रमभ्रमन्निलिम्पनिर्झरी\n'
        'विलोलवीचिवल्लरीविराजमानमूर्धनि ।\n'
        'धगद्धगद्धगज्ज्वलल्ललाटपट्टपावके\n'
        'किशोरचन्द्रशेखरे रतिः प्रतिक्षणं मम ॥२॥\n\n'
        'धराधरेन्द्रनन्दिनीविलासबन्धुबन्धुर-\n'
        'स्फुरद्दिगन्तसन्ततिप्रमोदमानमानसे ।\n'
        'कृपाकटाक्षधोरणीनिरुद्धदुर्धरापदि\n'
        'क्वचिद्दिगम्बरे मनो विनोदमेतु वस्तुनि ॥३॥\n\n'
        'जटाभुजङ्गपिङ्गलस्फुरत्फणामणिप्रभा\n'
        'कदम्बकुङ्कुमद्रवप्रलिप्तदिग्वधूमुखे ।\n'
        'मदान्धसिन्धुरस्फुरत्त्वगुत्तरीयमेदुरे\n'
        'मनो विनोदमद्भुतं बिभर्तु भूतभर्तरि ॥४॥\n\n'
        'सहस्रलोचनप्रभृत्यशेषलेखशेखर-\n'
        'प्रसूनधूलिधोरणीविधूसराङ्घ्रिपीठभूः ।\n'
        'भुजङ्गराजमालया निबद्धजाटजूटकः\n'
        'श्रियै चिराय जायतां चकोरबन्धुशेखरः ॥५॥\n\n'
        'ललाटचत्वरज्वलद्धनञ्जयस्फुलिङ्गभा-\n'
        'निपीतपञ्चसायकं नमन्निलिम्पनायकम् ।\n'
        'सुधामयूखलेखया विराजमानशेखरं\n'
        'महाकपालिसम्पदेशिरोजटालमस्तु नः ॥६॥\n\n'
        'करालभालपट्टिकाधगद्धगद्धगज्ज्वलद्-\n'
        'धनञ्जयाहुतीकृतप्रचण्डपञ्चसायके ।\n'
        'धराधरेन्द्रनन्दिनीकुचाग्रचित्रपत्रक-\n'
        'प्रकल्पनैकशिल्पिनि त्रिलोचने रतिर्मम ॥७॥\n\n'
        'नवीनमेघमण्डली निरुद्धदुर्धरस्फुरत्-\n'
        'कुहूनिशीथिनीतमःप्रबद्धबद्धकन्धरः ।\n'
        'निलिम्पनिर्झरीधरस्तनोतु कृत्तिसिन्धुरः\n'
        'कलानिधानबन्धुरः श्रियं जगद्धुरंधरः ॥८॥\n\n'
        'प्रफुल्लनीलपङ्कजप्रपञ्चकालिमप्रभा-\n'
        'वलम्बिकण्ठकन्दलीरुचिप्रबद्धकन्धरम् ।\n'
        'स्मरच्छिदं पुरच्छिदं भवच्छिदं मखच्छिदं\n'
        'गजच्छिदांधकच्छिदं तमन्तकच्छिदं भजे ॥९॥\n\n'
        'अखर्वसर्वमङ्गला कलाकदम्बमञ्जरी-\n'
        'रसप्रवाहमाधुरी विजृम्भणामधुव्रतम् ।\n'
        'स्मरान्तकं पुरान्तकं भवान्तकं मखान्तकं\n'
        'गजान्तकान्धकान्तकं तमन्तकान्तकं भजे ॥१०॥\n\n'
        'जयत्वदभ्रविभ्रमभ्रमद्भुजङ्गमश्वस-\n'
        'द्विनिर्गमत्क्रमस्फुरत्करालभालहव्यवाट् ।\n'
        'धिमिद्धिमिद्धिमिध्वनन्मृदङ्गतुङ्गमङ्गल-\n'
        'ध्वनिक्रमप्रवर्तित प्रचण्डताण्डवः शिवः ॥११॥\n\n'
        'दृषद्विचित्रतल्पयोर्भुजङ्गमौक्तिकस्रजोर्-\n'
        'गरिष्ठरत्नलोष्ठयोः सुहृद्विपक्षपक्षयोः ।\n'
        'तृणारविन्दचक्षुषोः प्रजामहीमहेन्द्रयोः\n'
        'समप्रवृत्तिकः कदा सदाशिवं भजाम्यहम् ॥१२॥\n\n'
        'कदा निलिम्पनिर्झरीनिकुञ्जकोटरे वसन्\n'
        'विमुक्तदुर्मतिः सदा शिरःस्थमञ्जलिं वहन् ।\n'
        'विलोललोललोचनो ललामभाललग्नकः\n'
        'शिवेति मन्त्रमुच्चरन् कदा सुखी भवाम्यहम् ॥१३॥\n\n'
        'इमं हि नित्यमेव मुक्तमुत्तमोत्तमं स्तवं\n'
        'पठन्स्मरन्ब्रुवन्नरो विशुद्धिमेति सन्ततम् ।\n'
        'हरे गुरौ सुभक्तिमाशु याति नान्यथा गतिं\n'
        'विमोहनं हि देहिनां सुशंकरस्य चिन्तनम् ॥१४॥\n\n'
        'पूजावसानसमये दशवक्रगीतं\n'
        'यः शम्भुपूजनपरं पठति प्रदोषे ।\n'
        'तस्य स्थिरां रथगजेन्द्रतुरङ्गयुक्तां\n'
        'लक्ष्मीं सदैव सुमुखीं प्रददाति शम्भुः ॥१५॥',
    transliteration:
        'Jatatavigalajjalapravahapavitasthale\n'
        'Gale\'valambya lambitam bhujanghatungamalikam |\n'
        'Damaddamaddamaddamanninadavaddamarvayam\n'
        'Chakara chandatandavam tanotuna shivah shivam ||1||\n\n'
        'Jatakataha sambhrama bhramannilimpanirjhari\n'
        'Vilolaveechivallaree virajamana murdhani |\n'
        'Dhagaddhagaddhagajjvalallalata pattapavake\n'
        'Kishorachandrashekare ratih pratikishanam mama ||2||\n\n'
        'Dharadharendranandini vilasabandhubandhura-\n'
        'Sphuraddigantasantati pramodamanamanese |\n'
        'Kripakataksha dhorani niruddhadurdharapadi\n'
        'Kvachiddigambare mano vinodametu vastuni ||3||\n\n'
        'Smrucchindam puracchindam bhavacchindam makhacchindam\n'
        'Gajacchidandhakacchidam tamantakacchidam bhaje ||9||\n\n'
        'Kada nilimpanirjhari nikunjah kotare vasan\n'
        'Vimuktadurmatih sada shirahsthamanjhalim vahan |\n'
        'Vilolalolalochanah lalamabhalalaganakah\n'
        'Shiveti mantramuccaran kada sukhi bhavamyaham ||13||\n\n'
        'Imam hi nityameva muktamuttamottamam stavam\n'
        'Pathansmaran bruvannarah vishuddhimeti santatam |\n'
        'Hare gurau subhaktimashu yati nanyatha gatim\n'
        'Vimohanam hi dehinam sushankharasya chintanam ||14||',
    meaning:
        'Composed by the mighty Ravana, the Shiv Tandav Stotra is one of the '
        'most powerful hymns in praise of Lord Shiva. It describes Shiva\'s '
        'cosmic dance (Tandav) — his matted locks dripping with the sacred '
        'Ganges, the crescent moon adorning his head, the serpent coiled around '
        'his neck, and the blazing fire of his third eye. The stotra celebrates '
        'Shiva as the destroyer of death, cities, and ego — the supreme '
        'consciousness who dances at the centre of creation and dissolution.',
    benefits: [
      'Recitation destroys sins and purifies the soul',
      'Grants fearlessness, strength, and divine protection',
      'Invokes Shiva\'s cosmic energy and grace',
      'Regular chanting leads to liberation (moksha)',
      'Bestows prosperity, elephants, horses, and all wealth (phala shruti)',
    ],
  ),
  _Mantra(
    name: 'Rudra Mantra',
    deity: 'Lord Rudra (Shiva)',
    color: Color(0xFFB71C1C),
    icon: FontAwesomeIcons.khanda,
    devanagari:
        'ॐ नमो भगवते रुद्राय ॥\n\n'
        'ॐ तत्पुरुषाय विद्महे\nमहादेवाय धीमहि ।\nतन्नो रुद्रः प्रचोदयात् ॥\n\n'
        'ॐ त्र्यम्बकाय नमः ।\nॐ शूलपाणये नमः ।\nॐ पिनाकपाणये नमः ।\n'
        'ॐ शिवाय नमः ।\nॐ पशुपतये नमः ।\nॐ महादेवाय नमः ॥',
    transliteration:
        'Om Namo Bhagavate Rudraya ||\n\n'
        'Om Tatpurushaya Vidmahe\nMahadevaya Dhimahi |\nTanno Rudrah Prachodayat ||\n\n'
        'Om Tryambakaya Namah |\nOm Shulapaanaye Namah |\nOm Pinakapaanaye Namah |\n'
        'Om Shivaya Namah |\nOm Pashupataye Namah |\nOm Mahadevaya Namah ||',
    meaning:
        'Salutations to the divine Lord Rudra. We know the supreme Purusha, '
        'we meditate upon the great Lord — may Rudra inspire and illuminate our '
        'intellect. Salutations to the three-eyed one, to the bearer of the '
        'trident, to the holder of the Pinaka bow, to the auspicious one, '
        'to the lord of all beings, to the great God.',
    benefits: [
      'Invokes Rudra\'s fierce protective energy',
      'Destroys disease, enemies, and evil forces',
      'Chanted during Rudra Abhishek at Trimbakeshwar',
      'Grants fearlessness and divine grace',
      'Purifies the chanter\'s body, mind, and soul',
    ],
  ),
  _Mantra(
    name: 'Shiva Gayatri Mantra',
    deity: 'Lord Shiva · Mahadeva',
    color: Color(0xFF1A237E),
    textIcon: 'ॐ',
    devanagari:
        'ॐ तत्पुरुषाय विद्महे\nमहादेवाय धीमहि ।\nतन्नो रुद्रः प्रचोदयात् ॥\n\n'
        'ॐ पञ्चवक्त्राय विद्महे\nमहादेवाय धीमहि ।\nतन्नो रुद्रः प्रचोदयात् ॥',
    transliteration:
        'Om Tatpurushaya Vidmahe\nMahadevaya Dhimahi |\nTanno Rudrah Prachodayat ||\n\n'
        'Om Panchavaktraya Vidmahe\nMahadevaya Dhimahi |\nTanno Rudrah Prachodayat ||',
    meaning:
        'We know the supreme Purusha — the eternal, all-pervading consciousness. '
        'We meditate upon the great Lord Mahadeva. May Lord Rudra inspire, '
        'enlighten, and guide our intellect. We know the five-faced Lord Shiva; '
        'may Rudra, the destroyer of ignorance, illuminate our path.',
    benefits: [
      'Invokes Shiva\'s five aspects (Panchamukha)',
      'Awakens spiritual wisdom and divine knowledge',
      'Purifies the mind of negative thoughts',
      'Daily chanting grants Shiva\'s direct grace',
      'Leads the soul towards moksha (liberation)',
    ],
  ),
  _Mantra(
    name: 'Lingashtakam',
    deity: 'Lord Shiva · Shivalinga',
    color: Color(0xFF37474F),
    icon: FontAwesomeIcons.synagogue,
    devanagari:
        'ब्रह्ममुरारिसुरार्चितलिङ्गं\nनिर्मलभासितशोभितलिङ्गम् ।\n'
        'जन्मजदुःखविनाशकलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥१॥\n\n'
        'देवमुनिप्रवरार्चितलिङ्गं\nकामदहनकरुणाकरलिङ्गम् ।\n'
        'रावणदर्पविनाशनलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥२॥\n\n'
        'सर्वसुगन्धसुलेपितलिङ्गं\nबुद्धिविवर्धनकारणलिङ्गम् ।\n'
        'सिद्धसुरासुरवन्दितलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥३॥\n\n'
        'कनकमहामणिभूषितलिङ्गं\nफणिपतिवेष्टितशोभितलिङ्गम् ।\n'
        'दक्षसुयज्ञविनाशनलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥४॥\n\n'
        'कुङ्कुमचन्दनलेपितलिङ्गं\nपङ्कजहारसुशोभितलिङ्गम् ।\n'
        'सञ्चितपापविनाशनलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥५॥\n\n'
        'देवगणार्चितसेवितलिङ्गं\nभावैर्भक्तिभिरेव च लिङ्गम् ।\n'
        'दिनकरकोटिप्रभाकरलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥६॥\n\n'
        'अष्टदलोपरिवेष्टितलिङ्गं\nसर्वसमुद्भवकारणलिङ्गम् ।\n'
        'अष्टदरिद्रविनाशितलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥७॥\n\n'
        'सुरगुरुसुरवरपूजितलिङ्गं\nसुरवनपुष्पसदार्चितलिङ्गम् ।\n'
        'परात्परं परमात्मकलिङ्गं\nतत्प्रणमामि सदाशिवलिङ्गम् ॥८॥\n\n'
        'लिङ्गाष्टकमिदं पुण्यं यः पठेच्छिवसन्निधौ ।\n'
        'शिवलोकमवाप्नोति शिवेन सह मोदते ॥',
    transliteration:
        'Brahma Murari Surarchita Lingam\nNirmala Bhashita Shobhita Lingam |\n'
        'Janmaja Duhkha Vinashaka Lingam\nTat Pranamami Sada Shiva Lingam ||1||\n\n'
        'Deva Muni Pravara Archita Lingam\nKama Dahana Karunakara Lingam |\n'
        'Ravana Darpa Vinashana Lingam\nTat Pranamami Sada Shiva Lingam ||2||\n\n'
        'Sarva Sugandha Sulepita Lingam\nBuddhi Vivardhana Karana Lingam |\n'
        'Siddha Sura Asura Vandita Lingam\nTat Pranamami Sada Shiva Lingam ||3||\n\n'
        'Kumkuma Chandana Lepita Lingam\nPankaja Hara Sushobhita Lingam |\n'
        'Sanchita Papa Vinashana Lingam\nTat Pranamami Sada Shiva Lingam ||5||\n\n'
        'Ashta Dalo Pari Veshthita Lingam\nSarva Samudbhava Karana Lingam |\n'
        'Ashta Daridra Vinashita Lingam\nTat Pranamami Sada Shiva Lingam ||7||\n\n'
        'Lingashtakam Idam Punyam Yah Pathet Shiva Sannidhau |\n'
        'Shiva Lokam Avapnoti Shivena Saha Modate ||',
    meaning:
        'I bow to that eternal Shivalinga — worshipped by Brahma, Vishnu, and '
        'all the gods; pure and radiant; destroyer of the sorrows of birth and death. '
        'The Lingashtakam is an eight-verse hymn glorifying the Shivalinga in all '
        'its aspects — as destroyer of Kama, crusher of Ravana\'s pride, remover '
        'of accumulated sins, radiant as a crore of suns, and the supreme cause '
        'of all creation. One who recites this in Shiva\'s presence attains Shiva Loka.',
    benefits: [
      'Destroys all accumulated sins (Sanchita Karma)',
      'Removes the eight forms of poverty and misfortune',
      'Grants wisdom, spiritual illumination, and devotion',
      'Attainment of Shivaloka after death',
      'Regular recitation purifies the devotee completely',
    ],
  ),
  _Mantra(
    name: 'Shiva Panchakshara Stotram',
    deity: 'Lord Shiva · Five Syllables',
    color: Color(0xFF4A148C),
    icon: FontAwesomeIcons.om,
    devanagari:
        'नागेन्द्रहाराय त्रिलोचनाय\nभस्माङ्गरागाय महेश्वराय ।\n'
        'नित्याय शुद्धाय दिगम्बराय\nतस्मै नकाराय नमः शिवाय ॥१॥\n\n'
        'मन्दाकिनीसलिलचन्दनचर्चिताय\nनन्दीश्वरप्रमथनाथमहेश्वराय ।\n'
        'मन्दारपुष्पबहुपुष्पसुपूजिताय\nतस्मै मकाराय नमः शिवाय ॥२॥\n\n'
        'शिवाय गौरीवदनाब्जवृन्द-\nसूर्याय दक्षाध्वरनाशकाय ।\n'
        'श्रीनीलकण्ठाय वृषध्वजाय\nतस्मै शिकाराय नमः शिवाय ॥३॥\n\n'
        'वशिष्ठकुम्भोद्भवगौतमार्य-\nमुनीन्द्रदेवार्चितशेखराय ।\n'
        'चन्द्रार्कवैश्वानरलोचनाय\nतस्मै वकाराय नमः शिवाय ॥४॥\n\n'
        'यज्ञस्वरूपाय जटाधराय\nपिनाकहस्ताय सनातनाय ।\n'
        'दिव्याय देवाय दिगम्बराय\nतस्मै यकाराय नमः शिवाय ॥५॥\n\n'
        'पञ्चाक्षरमिदं पुण्यं यः पठेच्छिवसन्निधौ ।\n'
        'शिवलोकमवाप्नोति शिवेन सह मोदते ॥',
    transliteration:
        'Nagendraharaya Trilochanaya\nBhasmaangaraagaya Maheshwaraya |\n'
        'Nityaya Shuddhaya Digambaraya\nTasmai Nakaraya Namah Shivaya ||1||\n\n'
        'Mandakinisalilachandanacharchitaya\nNandishvara Pramathanatha Maheshwaraya |\n'
        'Mandaara Pushpa Bahu Pushpa Supujitaya\nTasmai Makaraya Namah Shivaya ||2||\n\n'
        'Shivaya Gauri Vadana Abja Vrinda\nSuryaya Daksha Adhvara Nashakaya |\n'
        'Shri Nilakanthaya Vrishadhvajaya\nTasmai Shikaraya Namah Shivaya ||3||\n\n'
        'Yajnasvarupaya Jatadharaya\nPinaka Hastaya Sanatanaya |\n'
        'Divyaya Devaya Digambaraya\nTasmai Yakaraya Namah Shivaya ||5||\n\n'
        'Panchaksharam Idam Punyam Yah Pathet Shiva Sannidhau |\n'
        'Shiva Lokam Avapnoti Shivena Saha Modate ||',
    meaning:
        'The Shiva Panchakshara Stotram is a five-verse hymn where each verse '
        'meditates on one syllable of the Panchakshara mantra Na-Ma-Shi-Va-Ya. '
        'Na — the serpent-garlanded three-eyed lord smeared with ash. '
        'Ma — worshipped with Mandara flowers, bathed with Mandakini waters. '
        'Shi — spouse of Gauri, destroyer of Daksha\'s sacrifice, the blue-throated one. '
        'Va — whose eyes are the sun, moon, and fire. '
        'Ya — the eternal one, holder of the Pinaka bow, the sky-clad divine.',
    benefits: [
      'Meditates on all five aspects of the Panchakshara',
      'Destroys all sins when recited near Shiva',
      'Grants residence in Shivaloka',
      'One of Adi Shankaracharya\'s greatest compositions',
      'Purifies body, mind, and the five senses',
    ],
  ),
  _Mantra(
    name: 'Nirvana Shatakam',
    deity: 'Lord Shiva · Adi Shankaracharya',
    color: Color(0xFF004D40),
    icon: FontAwesomeIcons.infinity,
    devanagari:
        'मनो बुद्ध्यहङ्कारचित्तानि नाहं\nन च श्रोत्रजिह्वे न च घ्राणनेत्रे ।\n'
        'न च व्योम भूमिर्न तेजो न वायुः\nचिदानन्दरूपः शिवोऽहम् शिवोऽहम् ॥१॥\n\n'
        'न च प्राणसंज्ञो न वै पञ्चवायुः\nन वा सप्तधातुर्न वा पञ्चकोशः ।\n'
        'न वाक्पाणिपादौ न चोपस्थपायू\nचिदानन्दरूपः शिवोऽहम् शिवोऽहम् ॥२॥\n\n'
        'न मे द्वेषरागौ न मे लोभमोहौ\nमदो नैव मे नैव मात्सर्यभावः ।\n'
        'न धर्मो न चार्थो न कामो न मोक्षः\nचिदानन्दरूपः शिवोऽहम् शिवोऽहम् ॥३॥\n\n'
        'न पुण्यं न पापं न सौख्यं न दुःखं\nन मन्त्रो न तीर्थं न वेदा न यज्ञः ।\n'
        'अहं भोजनं नैव भोज्यं न भोक्ता\nचिदानन्दरूपः शिवोऽहम् शिवोऽहम् ॥४॥\n\n'
        'न मृत्युर्न शङ्का न मे जातिभेदः\nपिता नैव मे नैव माता न जन्मः ।\n'
        'न बन्धुर्न मित्रं गुरुर्नैव शिष्यः\nचिदानन्दरूपः शिवोऽहम् शिवोऽहम् ॥५॥\n\n'
        'अहं निर्विकल्पो निराकाररूपो\nविभुत्वाच्च सर्वत्र सर्वेन्द्रियाणाम् ।\n'
        'न चासङ्गतं नैव मुक्तिर्न मेयः\nचिदानन्दरूपः शिवोऽहम् शिवोऽहम् ॥६॥',
    transliteration:
        'Mano Buddhi Ahankara Chittani Naham\nNa Cha Shrotra Jihve Na Cha Ghrana Netre |\n'
        'Na Cha Vyoma Bhumir Na Tejo Na Vayuh\nChidananda Rupah Shivo\'ham Shivo\'ham ||1||\n\n'
        'Na Cha Prana Sanjno Na Vai Pancha Vayuh\nNa Va Sapta Dhatur Na Va Pancha Koshah |\n'
        'Na Vak Pani Padau Na Chopastha Payu\nChidananda Rupah Shivo\'ham Shivo\'ham ||2||\n\n'
        'Na Me Dvesha Ragau Na Me Lobha Mohau\nMado Naiva Me Naiva Matsarya Bhavah |\n'
        'Na Dharmo Na Chartho Na Kamo Na Mokshah\nChidananda Rupah Shivo\'ham Shivo\'ham ||3||\n\n'
        'Na Punyam Na Papam Na Saukhyam Na Duhkham\nNa Mantro Na Tirtham Na Veda Na Yajnah |\n'
        'Aham Bhojanam Naiva Bhojyam Na Bhokta\nChidananda Rupah Shivo\'ham Shivo\'ham ||4||\n\n'
        'Na Mrityur Na Shanka Na Me Jati Bhedah\nPita Naiva Me Naiva Mata Na Janmah |\n'
        'Na Bandhur Na Mitram Gurur Naiva Shishyah\nChidananda Rupah Shivo\'ham Shivo\'ham ||5||\n\n'
        'Aham Nirvikalpo Nirakara Rupo\nVibhutvaccha Sarvatra Sarvendriyaanam |\n'
        'Na Cha Sangatam Naiva Muktir Na Meyah\nChidananda Rupah Shivo\'ham Shivo\'ham ||6||',
    meaning:
        'I am not the mind, intellect, ego, or memory. I am not the ears, tongue, '
        'nose, or eyes. I am not the sky, earth, fire, or wind. '
        'I am the form of pure consciousness and bliss — I am Shiva, I am Shiva. '
        'Composed by Adi Shankaracharya at age 8 when asked his identity by his Guru '
        'Govindapada, this six-verse masterpiece declares the ultimate non-dual truth: '
        'the individual self is identical to Shiva — pure, eternal, limitless consciousness.',
    benefits: [
      'Destroys the illusion of ego and false identity',
      'Leads to direct experience of non-dual consciousness',
      'Removes fear of death and the cycle of rebirth',
      'Deepens meditation and self-inquiry (Atma Vichara)',
      'One of the greatest Advaita Vedanta compositions',
    ],
  ),
  _Mantra(
    name: 'Rudrashtaka Stotram',
    deity: 'Lord Rudra · Goswami Tulsidas',
    color: Color(0xFF880E4F),
    icon: FontAwesomeIcons.personPraying,
    devanagari:
        'नमामीशमीशान निर्वाणरूपं\nविभुं व्यापकं ब्रह्मवेदस्वरूपम् ।\n'
        'निजं निर्गुणं निर्विकल्पं निरीहं\nचिदाकाशमाकाशवासं भजेऽहम् ॥१॥\n\n'
        'निराकारमोंकारमूलं तुरीयं\nगिरा ज्ञान गोतीतमीशं गिरीशम् ।\n'
        'करालं महाकाल कालं कृपालुं\nगुणागार संसारपारं नतोऽहम् ॥२॥\n\n'
        'तुषाराद्रि संकाश गौरं गभीरं\nमनोभूत कोटिप्रभा श्री शरीरम् ।\n'
        'स्फुरन्मौलि कल्लोलिनी चारु गंगा\nलसद्भालबालेन्दु कंठे भुजंगा ॥३॥\n\n'
        'चलत्कुण्डलं भ्रू सुनेत्रं विशालं\nप्रसन्नाननं नीलकण्ठं दयालम् ।\n'
        'मृगाधीशचर्माम्बरं मुण्डमालं\nप्रियं शंकरं सर्वनाथं भजामि ॥४॥\n\n'
        'प्रचण्डं प्रकृष्टं प्रगल्भं परेशं\nअखण्डं अजं भानुकोटिप्रकाशम् ।\n'
        'त्रयः शूल निर्मूलनं शूलपाणिं\nभजेऽहं भवानीपतिं भावगम्यम् ॥५॥\n\n'
        'कलातीत कल्याण कल्पान्तकारी\nसदा सज्जनानन्ददाता पुरारी ।\n'
        'चिदानन्दसंदोह मोहापहारी\nप्रसीद प्रसीद प्रभो मन्मथारी ॥६॥\n\n'
        'न यावद् उमानाथपादारविन्दं\nभजन्तीह लोके परे वा नराणाम् ।\n'
        'न तावत्सुखं शान्ति सन्तापनाशं\nप्रसीद प्रभो सर्वभूताधिवासम् ॥७॥\n\n'
        'न जानामि योगं जपं नैव पूजां\nनतोऽहं सदा सर्वदा शम्भु तुभ्यम् ।\n'
        'जरा जन्म दुःखौघ तातप्यमानं\nप्रभो पाहि आपन्नमामीश शम्भो ॥८॥\n\n'
        'रुद्राष्टकमिदं प्रोक्तं विप्रेण हरतोषये ।\n'
        'ये पठन्ति नरा भक्त्या तेषां शम्भुः प्रसीदति ॥',
    transliteration:
        'Namami Isham Ishan Nirvana Rupam\nVibhum Vyapakam Brahma Veda Svarupam |\n'
        'Nijam Nirgunam Nirvikalpam Niriyam\nChidakasham Akashavasm Bhaje\'ham ||1||\n\n'
        'Nirakara Omkaramulam Turiyam\nGira Jnana Gotitam Isham Girisham |\n'
        'Karalam Mahakala Kalam Kripalum\nGunaagara Samsaraparam Nato\'ham ||2||\n\n'
        'Prachandam Prakrustam Pragalbham Paresham\nAkhandam Ajam Bhanu Koti Prakasham |\n'
        'Trayah Shula Nirmulana Shulapanim\nBhaje\'ham Bhavani Patim Bhavagamyam ||5||\n\n'
        'Na Yavad Umanatha Padaravindam\nBhajanteeha Loke Pare Va Naranam |\n'
        'Na Tavat Sukham Shanti Santapa Nasham\nPrasida Prabho Sarva Bhutadhivasam ||7||\n\n'
        'Na Janami Yogam Japam Naiva Pujam\nNato\'ham Sada Sarvada Shambhu Tubhyam |\n'
        'Jara Janma Duhkhaugha Tatapyamanam\nPrabho Pahi Apannamam Isha Shambho ||8||\n\n'
        'Rudrashtakam Idam Proktam Viprena Hara Toshaye |\n'
        'Ye Pathanti Nara Bhaktya Tesham Shambhuh Prasidati ||',
    meaning:
        'I bow to Lord Shiva — the lord of lords, the form of liberation, '
        'all-pervading, the essence of Brahman and the Vedas. He is attributeless, '
        'pure consciousness, dwelling in the sky of awareness. '
        'Composed by Goswami Tulsidas, the Rudrashtaka is an eight-verse devotional '
        'hymn describing Shiva\'s divine form — white as the Himalayan snow, '
        'adorned with the Ganga in his matted locks, the crescent moon on his forehead, '
        'serpents around his neck, the trident in his hand, dressed in tiger skin, '
        'wearing a garland of skulls — the compassionate destroyer, the lord of Bhavani.',
    benefits: [
      'Composed by Tulsidas — considered supremely meritorious',
      'Destroys sins of birth, old age, and sorrow',
      'Lord Shambhu himself is pleased by its recitation',
      'Grants peace, happiness, and relief from all afflictions',
      'Leads to liberation even without knowledge of yoga or puja',
    ],
  ),
  _Mantra(
    name: 'Shanti Mantra',
    deity: 'Universal Peace',
    color: AppColors.poojaGreen,
    icon: FontAwesomeIcons.dove,
    devanagari:
        'ॐ सह नाववतु ।\nसह नौ भुनक्तु ।\nसह वीर्यं करवावहै ।\n'
        'तेजस्वि नावधीतमस्तु\nमा विद्विषावहै ।\n'
        'ॐ शान्तिः शान्तिः शान्तिः ॥',
    transliteration:
        'Om Saha Naavavatu |\nSaha Nau Bhunaktu |\nSaha Veeryam Karavavahai |\n'
        'Tejasvi Naavadhitamastu\nMaa Vidvishaavahai |\n'
        'Om Shantih Shantih Shantih ||',
    meaning:
        'May we both be protected together. May we both be nourished together. '
        'May we work together with great energy. May our study be vigorous and '
        'effective. May we not hate each other. Om peace, peace, peace.',
    benefits: [
      'Invokes universal peace and harmony',
      'Chanted to open and close Vedic study',
      'Removes the three types of suffering — physical, divine, and elemental',
      'Cultivates cooperation, love, and non-conflict',
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class MantraScreen extends StatefulWidget {
  const MantraScreen({super.key});

  @override
  State<MantraScreen> createState() => _MantraScreenState();
}

class _MantraScreenState extends State<MantraScreen> {
  final _scroll = ScrollController();
  bool _showBar = false;
  static const _heroHeight = 420.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final show = _scroll.offset > _heroHeight - kToolbarHeight;
      if (show != _showBar) setState(() => _showBar = show);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        ColoredBox(
          color: const Color(0xFFFFF8F0),
          child: SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                const _HeroHeader(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).padding.bottom + 16),
                  child: Column(
                    children: _mantras
                        .map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _MantraCard(mantra: m),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Sticky header
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          top: _showBar ? 0 : -(topPad + kToolbarHeight),
          left: 0,
          right: 0,
          child: Container(
            height: topPad + kToolbarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_fireDeep, _fireMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: topPad),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppL10n.s.mantrasHeading,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

// Fiery palette constants — vivid crimson→orange→gold
const _fireDeep   = Color(0xFFB71C1C);
const _fireMid    = Color(0xFFE53935);
const _fireBright = Color(0xFFEF6C00);
const _fireEmber  = Color(0xFFFF6D00);
const _fireGold   = Color(0xFFFFC107);
const _fireGoldBright = Color(0xFFFFE000);


class _HeroHeader extends StatefulWidget {
  const _HeroHeader();

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with TickerProviderStateMixin {
  late AnimationController _omCtrl;
  late AnimationController _rotCtrl;
  late Animation<double> _omScale;
  late Animation<double> _omGlow;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();

    // Main pulse controller
    _omCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Slow rotation for outer ring
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _omScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _omCtrl, curve: Curves.easeInOut),
    );
    _omGlow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _omCtrl, curve: Curves.easeInOut),
    );
    // Ripple ring expands outward and fades
    _ringScale = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: _omCtrl, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _omCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _omCtrl.dispose();
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_fireDeep, _fireMid, _fireBright],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // ── Background Om watermark ──
          Positioned(
            right: -18, bottom: -22,
            child: Text(
              'ॐ',
              style: TextStyle(
                fontSize: 200,
                color: Colors.white.withValues(alpha: 0.04),
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          // ── Radial glow — top-left ──
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _fireEmber.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Radial glow — bottom-right ──
          Positioned(
            bottom: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _fireGold.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Small spark top-right ──
          Positioned(
            top: 44, right: 50,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fireGold.withValues(alpha: 0.12),
              ),
            ),
          ),
          // ── Ember glow bar at bottom edge ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, _fireGold, Colors.transparent],
                ),
              ),
            ),
          ),
          // ── Floating menu button ──
          Positioned(
            top: 0, left: 0,
            child: SafeArea(
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ),
          // ── Main content ──
          SafeArea(
            bottom: false,
            child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 16),
            child: Column(
              children: [
                // Om medallion — amplified pulse + ripple + rotation
                AnimatedBuilder(
                  animation: Listenable.merge([_omCtrl, _rotCtrl]),
                  builder: (_, __) => SizedBox(
                    width: 160, height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple ring (expands outward + fades)
                        Transform.scale(
                          scale: _ringScale.value,
                          child: Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _fireEmber.withValues(alpha: _ringOpacity.value),
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                        // Second ripple ring (offset phase)
                        Transform.scale(
                          scale: _ringScale.value * 0.75,
                          child: Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _fireGold.withValues(alpha: _ringOpacity.value * 0.6),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        // Rotating dashed outer ring
                        Transform.rotate(
                          angle: _rotCtrl.value * 6.28318,
                          child: Container(
                            width: 118, height: 118,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _fireGold.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        // Main medallion — pulsing scale + glow
                        Transform.scale(
                          scale: _omScale.value,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFF8B2500), _fireDeep],
                                stops: [0.3, 1.0],
                              ),
                              border: Border.all(
                                color: _fireGold.withValues(alpha: 0.85),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _fireEmber.withValues(alpha: _omGlow.value),
                                  blurRadius: 48,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: _fireGold.withValues(alpha: _omGlow.value * 0.6),
                                  blurRadius: 22,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: _fireGoldBright.withValues(alpha: _omGlow.value * 0.25),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'ॐ',
                                style: TextStyle(
                                  fontSize: 50,
                                  color: _fireGoldBright,
                                  height: 1.1,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(color: _fireGold, blurRadius: 12),
                                    Shadow(color: _fireEmber, blurRadius: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Sanskrit subtitle
                Text(
                  'पवित्र मंत्र',
                  style: TextStyle(
                    fontSize: 14,
                    color: _fireGold.withValues(alpha: 0.9),
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppL10n.s.mantrasHeading,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  AppL10n.s.reciteReflectLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 2.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                // Pill row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FirePill(
                      icon: FontAwesomeIcons.fire,
                      label: AppL10n.s.sacredMantrasCount(_mantras.length),
                    ),
                    const SizedBox(width: 10),
                    _FirePill(
                      icon: FontAwesomeIcons.om,
                      label: AppL10n.s.vedicTradition,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ), // SafeArea
        ],
      ),
    );
  }
}

class _FirePill extends StatelessWidget {
  final FaIconData icon;
  final String label;
  const _FirePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: _fireGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _fireGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, color: _fireGoldBright, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: _fireGoldBright,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mantra Card ───────────────────────────────────────────────────────────────

class _MantraCard extends StatefulWidget {
  final _Mantra mantra;
  const _MantraCard({required this.mantra});

  @override
  State<_MantraCard> createState() => _MantraCardState();
}

class _MantraCardState extends State<_MantraCard> {
  bool _expanded = false;

  void _copyMantra() {
    final text =
        '${widget.mantra.devanagari}\n\n${widget.mantra.transliteration}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.mantra.name} copied'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mantra;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _expanded ? 0.09 : 0.055),
            blurRadius: _expanded ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Header ──
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    m.textIcon != null
                        ? SizedBox(
                            width: 28, height: 28,
                            child: Center(
                              child: Text(
                                m.textIcon!,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: m.color,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : FaIcon(m.icon!, color: m.color, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppL10n.s.mantraName(m.name),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDeep,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  color: m.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppL10n.s.mantraDeity(m.deity),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: m.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.grey500,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded Content ──
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Divider
                        Container(
                          height: 1,
                          color: m.color.withValues(alpha: 0.12),
                        ),
                        // Devanagari text area
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                          color: m.color.withValues(alpha: 0.04),
                          child: Text(
                            m.devanagari,
                            style: TextStyle(
                              fontSize: 22,
                              color: m.color,
                              fontWeight: FontWeight.w600,
                              height: 1.9,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Transliteration
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionChip(
                                  label: AppL10n.s.transliterationLabel, color: m.color),
                              const SizedBox(height: 10),
                              Text(
                                m.transliteration,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.grey700,
                                  fontStyle: FontStyle.italic,
                                  height: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Meaning
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionChip(label: AppL10n.s.meaningLabel, color: m.color),
                              const SizedBox(height: 10),
                              Text(
                                m.meaning,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF555566),
                                  height: 1.75,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Benefits
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionChip(label: AppL10n.s.benefitsLabel, color: m.color),
                              const SizedBox(height: 10),
                              ...m.benefits.map((b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 22, height: 22,
                                          margin:
                                              const EdgeInsets.only(top: 1),
                                          decoration: BoxDecoration(
                                            color: m.color
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Icon(Icons.check_rounded,
                                              size: 13, color: m.color),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(b,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF444455),
                                                  height: 1.5)),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        // Copy button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          child: GestureDetector(
                            onTap: _copyMantra,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 11, horizontal: 18),
                              decoration: BoxDecoration(
                                color: m.color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: m.color.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.copy_rounded,
                                      size: 15, color: m.color),
                                  const SizedBox(width: 7),
                                  Text(AppL10n.s.copyMantra,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: m.color)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Chip ──────────────────────────────────────────────────────────────

class _SectionChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
