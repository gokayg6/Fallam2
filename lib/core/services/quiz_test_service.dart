import '../models/quiz_test_model.dart';
import '../constants/app_strings.dart';

class QuizTestService {
  static final QuizTestService _instance = QuizTestService._internal();
  factory QuizTestService() => _instance;
  QuizTestService._internal();

  // Tüm mevcut testler
  List<QuizTestDefinition> getAllTests() {
    return [
      _getPersonalityTest(),
      _getFriendshipTest(),
      _getLoveTest(),
      _getCompatibilityTest(),
      _getLoveWhatDoYouWantTest(),
      _getRedFlagsTest(),
      _getFunnyTest(),
      _getChaosTest(),
      _getSuperPowerTest(),
      _getPlanetEnergyTest(),
      _getSoulmateZodiacTest(),
      _getMentalHealthColorTest(),
      _getSpiritAnimalTest(),
      _getEnergyStageTest(),
    ];
  }

  QuizTestDefinition? getTestById(String id) {
    try {
      return getAllTests().firstWhere(
        (test) => test.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Kişilik testi
  QuizTestDefinition _getPersonalityTest() {
    return QuizTestDefinition(
      id: 'personality',
      title: AppStrings.personalityTest,
      description: AppStrings.personalityTestSubtitle,
      emoji: '🧠',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(
              id: 'name',
              label: AppStrings.name,
              type: QuizFieldType.text,
              placeholder: AppStrings.enterYourName,
            ),
            QuizField(
              id: 'birthDate',
              label: AppStrings.birthDate,
              type: QuizFieldType.date,
              placeholder: AppStrings.selectYourBirthDate,
            ),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.personalityQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ1A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ1A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ1A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.personalityQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ2A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ2A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ2A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.personalityQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ3A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ3A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ3A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.personalityQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ4A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ4A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ4A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.personalityQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ5A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ5A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ5A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.personalityQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ6A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ6A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ6A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.personalityQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.personalityQ7A1),
                QuizOption(id: 'a2', text: AppStrings.personalityQ7A2),
                QuizOption(id: 'a3', text: AppStrings.personalityQ7A3),
                QuizOption(id: 'a4', text: AppStrings.personalityQ7A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Arkadaşlık testi
  QuizTestDefinition _getFriendshipTest() {
    return QuizTestDefinition(
      id: 'friendship',
      title: AppStrings.friendshipTest,
      description: AppStrings.friendshipTestSubtitle,
      emoji: '👥',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(
              id: 'yourName',
              label: AppStrings.yourName,
              type: QuizFieldType.text,
              placeholder: AppStrings.enterYourName,
            ),
            QuizField(
              id: 'yourBirthDate',
              label: AppStrings.yourBirthDate,
              type: QuizFieldType.date,
              placeholder: AppStrings.selectYourBirthDate,
            ),
            QuizField(
              id: 'friendName',
              label: AppStrings.friendName,
              type: QuizFieldType.text,
              placeholder: AppStrings.enterFriendName,
            ),
            QuizField(
              id: 'friendBirthDate',
              label: AppStrings.friendBirthDate,
              type: QuizFieldType.date,
              placeholder: AppStrings.selectFriendBirthDate,
            ),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.friendshipQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.friendshipQ1A1),
                QuizOption(id: 'a2', text: AppStrings.friendshipQ1A2),
                QuizOption(id: 'a3', text: AppStrings.friendshipQ1A3),
                QuizOption(id: 'a4', text: AppStrings.friendshipQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.friendshipQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.friendshipQ2A1),
                QuizOption(id: 'a2', text: AppStrings.friendshipQ2A2),
                QuizOption(id: 'a3', text: AppStrings.friendshipQ2A3),
                QuizOption(id: 'a4', text: AppStrings.friendshipQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.friendshipQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.friendshipQ3A1),
                QuizOption(id: 'a2', text: AppStrings.friendshipQ3A2),
                QuizOption(id: 'a3', text: AppStrings.friendshipQ3A3),
                QuizOption(id: 'a4', text: AppStrings.friendshipQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.friendshipQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.friendshipQ4A1),
                QuizOption(id: 'a2', text: AppStrings.friendshipQ4A2),
                QuizOption(id: 'a3', text: AppStrings.friendshipQ4A3),
                QuizOption(id: 'a4', text: AppStrings.friendshipQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.friendshipQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.friendshipQ5A1),
                QuizOption(id: 'a2', text: AppStrings.friendshipQ5A2),
                QuizOption(id: 'a3', text: AppStrings.friendshipQ5A3),
                QuizOption(id: 'a4', text: AppStrings.friendshipQ5A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Aşk testi
  QuizTestDefinition _getLoveTest() {
    return QuizTestDefinition(
      id: 'love',
      title: AppStrings.loveTest,
      description: AppStrings.loveTestSubtitle,
      emoji: '❤️',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(
              id: 'name',
              label: AppStrings.name,
              type: QuizFieldType.text,
            ),
            QuizField(
              id: 'birthDate',
              label: AppStrings.birthDate,
              type: QuizFieldType.date,
            ),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.loveQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.loveQ1A1),
                QuizOption(id: 'a2', text: AppStrings.loveQ1A2),
                QuizOption(id: 'a3', text: AppStrings.loveQ1A3),
                QuizOption(id: 'a4', text: AppStrings.loveQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.loveQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.loveQ2A1),
                QuizOption(id: 'a2', text: AppStrings.loveQ2A2),
                QuizOption(id: 'a3', text: AppStrings.loveQ2A3),
                QuizOption(id: 'a4', text: AppStrings.loveQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.loveQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.loveQ3A1),
                QuizOption(id: 'a2', text: AppStrings.loveQ3A2),
                QuizOption(id: 'a3', text: AppStrings.loveQ3A3),
                QuizOption(id: 'a4', text: AppStrings.loveQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.loveQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.loveQ4A1),
                QuizOption(id: 'a2', text: AppStrings.loveQ4A2),
                QuizOption(id: 'a3', text: AppStrings.loveQ4A3),
                QuizOption(id: 'a4', text: AppStrings.loveQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.loveQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.loveQ5A1),
                QuizOption(id: 'a2', text: AppStrings.loveQ5A2),
                QuizOption(id: 'a3', text: AppStrings.loveQ5A3),
                QuizOption(id: 'a4', text: AppStrings.loveQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.loveQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.loveQ6A1),
                QuizOption(id: 'a2', text: AppStrings.loveQ6A2),
                QuizOption(id: 'a3', text: AppStrings.loveQ6A3),
                QuizOption(id: 'a4', text: AppStrings.loveQ6A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // İlişki Uyum testi
  QuizTestDefinition _getCompatibilityTest() {
    return QuizTestDefinition(
      id: 'compatibility',
      title: AppStrings.compatibilityTest,
      description: AppStrings.relationshipCompatibilitySubtitle,
      emoji: '💕',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'yourName', label: AppStrings.yourName, type: QuizFieldType.text),
            QuizField(id: 'yourBirthDate', label: AppStrings.yourBirthDate, type: QuizFieldType.date),
            QuizField(id: 'partnerName', label: AppStrings.partnerName, type: QuizFieldType.text),
            QuizField(id: 'partnerBirthDate', label: AppStrings.partnerBirthDate, type: QuizFieldType.date),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.compatibilityQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.compatibilityQ1A1),
                QuizOption(id: 'a2', text: AppStrings.compatibilityQ1A2),
                QuizOption(id: 'a3', text: AppStrings.compatibilityQ1A3),
                QuizOption(id: 'a4', text: AppStrings.compatibilityQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.compatibilityQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.compatibilityQ2A1),
                QuizOption(id: 'a2', text: AppStrings.compatibilityQ2A2),
                QuizOption(id: 'a3', text: AppStrings.compatibilityQ2A3),
                QuizOption(id: 'a4', text: AppStrings.compatibilityQ2A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // İlişkinde Gerçekten Ne İstiyorsun Testi
  QuizTestDefinition _getLoveWhatDoYouWantTest() {
    return QuizTestDefinition(
      id: 'love_what_you_want',
      title: AppStrings.relationshipWhatYouWantTest,
      description: AppStrings.relationshipWhatYouWantSubtitle,
      emoji: '💞',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: 'Ad', type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: 'Doğum tarihi', type: QuizFieldType.date),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: 'Aşk senin gözünde...',
              options: [
                QuizOption(id: 'a1', text: 'Ruhların birleşimi'),
                QuizOption(id: 'a2', text: 'Tutkulu bir deneyim'),
                QuizOption(id: 'a3', text: 'Güvenli bir liman'),
                QuizOption(id: 'a4', text: 'Keyifli bir paylaşım'),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: 'Bir partnerde seni etkileyen ilk şey ne olur?',
              options: [
                QuizOption(id: 'a1', text: 'Enerjisi'),
                QuizOption(id: 'a2', text: 'Karizması'),
                QuizOption(id: 'a3', text: 'Güven vermesi'),
                QuizOption(id: 'a4', text: 'Özgür tavrı'),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: 'İlişkide asla vazgeçemeyeceğin şey nedir?',
              options: [
                QuizOption(id: 'a1', text: 'Duygusal bağlılık'),
                QuizOption(id: 'a2', text: 'Fiziksel çekim'),
                QuizOption(id: 'a3', text: 'Sadakat'),
                QuizOption(id: 'a4', text: 'Alan tanımak'),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: 'Bir tartışmada ne yaparsın?',
              options: [
                QuizOption(id: 'a1', text: 'Hemen konuşurum'),
                QuizOption(id: 'a2', text: 'Biraz bekler, sonra patlarım'),
                QuizOption(id: 'a3', text: 'Sakin kalmaya çalışırım'),
                QuizOption(id: 'a4', text: 'Uzaklaşırım, zamanla geçsin isterim'),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: 'İlişkide uzun vadede ne beklersin?',
              options: [
                QuizOption(id: 'a1', text: 'Ruh eşi bağlantısı'),
                QuizOption(id: 'a2', text: 'Aşkın hiç bitmemesi'),
                QuizOption(id: 'a3', text: 'Sadakat ve istikrar'),
                QuizOption(id: 'a4', text: 'Birlikte büyüyebilmek ama özgür kalmak'),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: 'Kalbini verdiğinde…',
              options: [
                QuizOption(id: 'a1', text: 'Tamamen adanırım'),
                QuizOption(id: 'a2', text: 'Her şeyimi paylaşırım'),
                QuizOption(id: 'a3', text: 'Dengemi korumaya çalışırım'),
                QuizOption(id: 'a4', text: 'Hislerimi kontrol ederim'),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: 'Sevgi senin için...',
              options: [
                QuizOption(id: 'a1', text: 'Sessiz bir enerji bağı'),
                QuizOption(id: 'a2', text: 'Yakan bir ateş'),
                QuizOption(id: 'a3', text: 'Güçlü bir bağ'),
                QuizOption(id: 'a4', text: 'Akışta yaşanan bir his'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getRedFlagsTest() {
    return QuizTestDefinition(
      id: 'red_flags',
      title: AppStrings.loveRedFlagsTest,
      description: AppStrings.loveRedFlagsSubtitle,
      emoji: '❤️‍🔥',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: AppStrings.birthDate, type: QuizFieldType.date, required: false),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.redFlagsQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ1A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ1A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ1A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.redFlagsQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ2A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ2A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ2A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.redFlagsQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ3A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ3A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ3A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.redFlagsQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ4A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ4A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ4A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.redFlagsQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ5A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ5A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ5A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.redFlagsQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ6A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ6A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ6A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.redFlagsQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ7A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ7A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ7A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ7A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q8',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q8',
              question: AppStrings.redFlagsQ8,
              options: [
                QuizOption(id: 'a1', text: AppStrings.redFlagsQ8A1),
                QuizOption(id: 'a2', text: AppStrings.redFlagsQ8A2),
                QuizOption(id: 'a3', text: AppStrings.redFlagsQ8A3),
                QuizOption(id: 'a4', text: AppStrings.redFlagsQ8A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getFunnyTest() {
    return QuizTestDefinition(
      id: 'funny',
      title: AppStrings.zodiacFunLevelTest,
      description: AppStrings.zodiacFunLevelSubtitle,
      emoji: '🎭',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: AppStrings.birthDate, type: QuizFieldType.date),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.funnyQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.funnyQ1A1),
                QuizOption(id: 'a2', text: AppStrings.funnyQ1A2),
                QuizOption(id: 'a3', text: AppStrings.funnyQ1A3),
                QuizOption(id: 'a4', text: AppStrings.funnyQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.funnyQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.funnyQ2A1),
                QuizOption(id: 'a2', text: AppStrings.funnyQ2A2),
                QuizOption(id: 'a3', text: AppStrings.funnyQ2A3),
                QuizOption(id: 'a4', text: AppStrings.funnyQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.funnyQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.funnyQ3A1),
                QuizOption(id: 'a2', text: AppStrings.funnyQ3A2),
                QuizOption(id: 'a3', text: AppStrings.funnyQ3A3),
                QuizOption(id: 'a4', text: AppStrings.funnyQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.funnyQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.funnyQ4A1),
                QuizOption(id: 'a2', text: AppStrings.funnyQ4A2),
                QuizOption(id: 'a3', text: AppStrings.funnyQ4A3),
                QuizOption(id: 'a4', text: AppStrings.funnyQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.funnyQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.funnyQ5A1),
                QuizOption(id: 'a2', text: AppStrings.funnyQ5A2),
                QuizOption(id: 'a3', text: AppStrings.funnyQ5A3),
                QuizOption(id: 'a4', text: AppStrings.funnyQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.funnyQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.funnyQ6A1),
                QuizOption(id: 'a2', text: AppStrings.funnyQ6A2),
                QuizOption(id: 'a3', text: AppStrings.funnyQ6A3),
                QuizOption(id: 'a4', text: AppStrings.funnyQ6A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getChaosTest() {
    return QuizTestDefinition(
      id: 'chaos',
      title: AppStrings.zodiacChaosLevelTest,
      description: AppStrings.zodiacChaosLevelSubtitle,
      emoji: '💥',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: AppStrings.birthDate, type: QuizFieldType.date),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.chaosQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ1A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ1A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ1A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.chaosQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ2A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ2A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ2A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.chaosQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ3A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ3A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ3A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.chaosQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ4A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ4A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ4A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.chaosQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ5A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ5A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ5A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.chaosQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ6A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ6A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ6A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.chaosQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.chaosQ7A1),
                QuizOption(id: 'a2', text: AppStrings.chaosQ7A2),
                QuizOption(id: 'a3', text: AppStrings.chaosQ7A3),
                QuizOption(id: 'a4', text: AppStrings.chaosQ7A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getSuperPowerTest() {
    return QuizTestDefinition(
      id: 'super_power',
      title: AppStrings.hiddenSuperPowerTest,
      description: AppStrings.hiddenSuperPowerSubtitle,
      emoji: '⚡',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'mood', label: AppStrings.mood, type: QuizFieldType.mood),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.superPowerQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ1A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ1A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ1A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.superPowerQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ2A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ2A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ2A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.superPowerQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ3A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ3A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ3A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.superPowerQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ4A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ4A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ4A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.superPowerQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ5A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ5A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ5A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.superPowerQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ6A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ6A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ6A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.superPowerQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ7A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ7A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ7A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ7A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q8',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q8',
              question: AppStrings.superPowerQ8,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ8A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ8A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ8A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ8A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q9',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q9',
              question: AppStrings.superPowerQ9,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ9A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ9A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ9A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ9A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q10',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q10',
              question: AppStrings.superPowerQ10,
              options: [
                QuizOption(id: 'a1', text: AppStrings.superPowerQ10A1),
                QuizOption(id: 'a2', text: AppStrings.superPowerQ10A2),
                QuizOption(id: 'a3', text: AppStrings.superPowerQ10A3),
                QuizOption(id: 'a4', text: AppStrings.superPowerQ10A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getPlanetEnergyTest() {
    return QuizTestDefinition(
      id: 'planet_energy',
      title: AppStrings.planetEnergyTest,
      description: AppStrings.planetEnergySubtitle,
      emoji: '🌌',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: AppStrings.birthDate, type: QuizFieldType.date, required: false),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.planetEnergyQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ1A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ1A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ1A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.planetEnergyQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ2A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ2A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ2A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.planetEnergyQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ3A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ3A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ3A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.planetEnergyQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ4A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ4A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ4A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.planetEnergyQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ5A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ5A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ5A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.planetEnergyQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ6A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ6A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ6A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.planetEnergyQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ7A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ7A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ7A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ7A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q8',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q8',
              question: AppStrings.planetEnergyQ8,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ8A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ8A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ8A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ8A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q9',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q9',
              question: AppStrings.planetEnergyQ9,
              options: [
                QuizOption(id: 'a1', text: AppStrings.planetEnergyQ9A1),
                QuizOption(id: 'a2', text: AppStrings.planetEnergyQ9A2),
                QuizOption(id: 'a3', text: AppStrings.planetEnergyQ9A3),
                QuizOption(id: 'a4', text: AppStrings.planetEnergyQ9A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getSoulmateZodiacTest() {
    return QuizTestDefinition(
      id: 'soulmate_zodiac',
      title: AppStrings.soulmateZodiacTest,
      description: AppStrings.soulmateZodiacSubtitle,
      emoji: '💫',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: AppStrings.birthDate, type: QuizFieldType.date),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.soulmateZodiacQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ1A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ1A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ1A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.soulmateZodiacQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ2A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ2A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ2A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.soulmateZodiacQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ3A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ3A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ3A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.soulmateZodiacQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ4A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ4A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ4A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.soulmateZodiacQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ5A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ5A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ5A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.soulmateZodiacQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ6A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ6A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ6A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.soulmateZodiacQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.soulmateZodiacQ7A1),
                QuizOption(id: 'a2', text: AppStrings.soulmateZodiacQ7A2),
                QuizOption(id: 'a3', text: AppStrings.soulmateZodiacQ7A3),
                QuizOption(id: 'a4', text: AppStrings.soulmateZodiacQ7A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getMentalHealthColorTest() {
    return QuizTestDefinition(
      id: 'mental_health_color',
      title: AppStrings.mentalHealthColorTest,
      description: AppStrings.mentalHealthColorSubtitle,
      emoji: '🌈',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'mood', label: AppStrings.howIsYourMood, type: QuizFieldType.mood, hint: AppStrings.mentalHealthColorMoodHint),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.mentalHealthColorQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.mentalHealthColorQ1A1),
                QuizOption(id: 'a2', text: AppStrings.mentalHealthColorQ1A2),
                QuizOption(id: 'a3', text: AppStrings.mentalHealthColorQ1A3),
                QuizOption(id: 'a4', text: AppStrings.mentalHealthColorQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.mentalHealthColorQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.mentalHealthColorQ2A1),
                QuizOption(id: 'a2', text: AppStrings.mentalHealthColorQ2A2),
                QuizOption(id: 'a3', text: AppStrings.mentalHealthColorQ2A3),
                QuizOption(id: 'a4', text: AppStrings.mentalHealthColorQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.mentalHealthColorQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.mentalHealthColorQ3A1),
                QuizOption(id: 'a2', text: AppStrings.mentalHealthColorQ3A2),
                QuizOption(id: 'a3', text: AppStrings.mentalHealthColorQ3A3),
                QuizOption(id: 'a4', text: AppStrings.mentalHealthColorQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.mentalHealthColorQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.mentalHealthColorQ4A1),
                QuizOption(id: 'a2', text: AppStrings.mentalHealthColorQ4A2),
                QuizOption(id: 'a3', text: AppStrings.mentalHealthColorQ4A3),
                QuizOption(id: 'a4', text: AppStrings.mentalHealthColorQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.mentalHealthColorQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.mentalHealthColorQ5A1),
                QuizOption(id: 'a2', text: AppStrings.mentalHealthColorQ5A2),
                QuizOption(id: 'a3', text: AppStrings.mentalHealthColorQ5A3),
                QuizOption(id: 'a4', text: AppStrings.mentalHealthColorQ5A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getSpiritAnimalTest() {
    return QuizTestDefinition(
      id: 'spirit_animal',
      title: AppStrings.spiritAnimalTest,
      description: AppStrings.spiritAnimalSubtitle,
      emoji: '🦋',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'birthDate', label: AppStrings.birthDate, type: QuizFieldType.date, required: false),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.spiritAnimalQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ1A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ1A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ1A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.spiritAnimalQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ2A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ2A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ2A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.spiritAnimalQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ3A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ3A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ3A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.spiritAnimalQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ4A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ4A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ4A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.spiritAnimalQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ5A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ5A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ5A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.spiritAnimalQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ6A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ6A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ6A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.spiritAnimalQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ7A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ7A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ7A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ7A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q8',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q8',
              question: AppStrings.spiritAnimalQ8,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ8A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ8A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ8A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ8A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q9',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q9',
              question: AppStrings.spiritAnimalQ9,
              options: [
                QuizOption(id: 'a1', text: AppStrings.spiritAnimalQ9A1),
                QuizOption(id: 'a2', text: AppStrings.spiritAnimalQ9A2),
                QuizOption(id: 'a3', text: AppStrings.spiritAnimalQ9A3),
                QuizOption(id: 'a4', text: AppStrings.spiritAnimalQ9A4),
              ],
            ),
          ],
        ),
      ],
    );
  }

  QuizTestDefinition _getEnergyStageTest() {
    return QuizTestDefinition(
      id: 'energy_stage',
      title: AppStrings.energyStageTest,
      description: AppStrings.energyStageSubtitle,
      emoji: '🔮',
      sections: [
        QuizSection(
          id: 'form',
          title: '',
          type: QuizSectionType.form,
          fields: [
            QuizField(id: 'name', label: AppStrings.name, type: QuizFieldType.text),
            QuizField(id: 'mood', label: AppStrings.dayMood, type: QuizFieldType.mood),
          ],
        ),
        QuizSection(
          id: 'q1',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: AppStrings.energyStageQ1,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ1A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ1A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ1A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ1A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q2',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q2',
              question: AppStrings.energyStageQ2,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ2A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ2A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ2A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ2A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q3',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q3',
              question: AppStrings.energyStageQ3,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ3A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ3A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ3A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ3A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q4',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q4',
              question: AppStrings.energyStageQ4,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ4A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ4A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ4A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ4A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q5',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: AppStrings.energyStageQ5,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ5A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ5A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ5A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ5A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q6',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q6',
              question: AppStrings.energyStageQ6,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ6A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ6A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ6A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ6A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q7',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q7',
              question: AppStrings.energyStageQ7,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ7A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ7A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ7A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ7A4),
              ],
            ),
          ],
        ),
        QuizSection(
          id: 'q8',
          title: '',
          type: QuizSectionType.question,
          questions: [
            QuizQuestion(
              id: 'q8',
              question: AppStrings.energyStageQ8,
              options: [
                QuizOption(id: 'a1', text: AppStrings.energyStageQ8A1),
                QuizOption(id: 'a2', text: AppStrings.energyStageQ8A2),
                QuizOption(id: 'a3', text: AppStrings.energyStageQ8A3),
                QuizOption(id: 'a4', text: AppStrings.energyStageQ8A4),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

