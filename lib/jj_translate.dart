// // import 'package:flutter/material.dart';
// // import 'package:simplytranslate/simplytranslate.dart';
// // import 'package:logger/logger.dart';

// // class TestScreen extends StatefulWidget {
// //   const TestScreen({super.key});

// //   @override
// //   _TestScreenState createState() => _TestScreenState();
// // }

// // class _TestScreenState extends State<TestScreen> {
// //   String translatedText = ''; // Texte traduit
// //   final st = SimplyTranslator(EngineType.libre); // Initialisation du moteur de traduction
// //   final TextEditingController _controller = TextEditingController(); // Contrôleur du champ de texte
// //   bool _isLoading = false; // Indicateur de chargement
// //   final Logger logger = Logger(); // Initialisation du logger

// //   // Listes de langues
// //   final List<String> _languages = ['auto', 'fr', 'en', 'es', 'de', 'it'];
// //   String _selectedFromLang = 'auto'; // Langue source par défaut
// //   String _selectedToLang = 'en'; // Langue cible par défaut

// //   Future<void> _translateText(String text) async {
// //     setState(() {
// //       _isLoading = true; // Indique que la traduction est en cours
// //     });
// //     logger.d('Début de la traduction du texte : $text');

// //     try {
// //       final Translation translation = await st.translateSimply(
// //         text, // Texte entré par l'utilisateur
// //         from: _selectedFromLang, // Langue source sélectionnée
// //         to: _selectedToLang, // Langue cible sélectionnée
// //         instanceMode: InstanceMode.Loop,
// //         retries: 4,
// //       );

// //       setState(() {
// //         translatedText = translation.translations.text; // Mettre à jour le texte traduit
// //       });
// //       logger.d('Traduction réussie : $translatedText');
// //     } catch (error) {
// //       logger.e('Erreur lors de la traduction : $error');
// //     } finally {
// //       setState(() {
// //         _isLoading = false; // Fin du chargement
// //       });
// //       logger.d('Fin de la traduction');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Test de Traduction'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             TextField(
// //               controller: _controller, // Contrôleur du champ de texte
// //               decoration: const InputDecoration(
// //                 labelText: 'Entrez du texte à traduire',
// //                 border: OutlineInputBorder(),
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             // Liste déroulante pour choisir la langue source
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('Langue d\'origine :'),
// //                 DropdownButton<String>(
// //                   value: _selectedFromLang,
// //                   items: _languages.map((String value) {
// //                     return DropdownMenuItem<String>(
// //                       value: value,
// //                       child: Text(value),
// //                     );
// //                   }).toList(),
// //                   onChanged: (String? newValue) {
// //                     setState(() {
// //                       _selectedFromLang = newValue!;
// //                     });
// //                   },
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 20),
// //             // Liste déroulante pour choisir la langue cible
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('Traduire en :'),
// //                 DropdownButton<String>(
// //                   value: _selectedToLang,
// //                   items: _languages.map((String value) {
// //                     return DropdownMenuItem<String>(
// //                       value: value,
// //                       child: Text(value),
// //                     );
// //                   }).toList(),
// //                   onChanged: (String? newValue) {
// //                     setState(() {
// //                       _selectedToLang = newValue!;
// //                     });
// //                   },
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _isLoading ? null : () => _translateText(_controller.text),
// //               child: _isLoading ? const CircularProgressIndicator() : const Text('Traduire'),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               translatedText.isEmpty ? 'Traduction affichée ici' : translatedText, // Afficher la traduction
// //               style: const TextStyle(fontSize: 20),
// //               textAlign: TextAlign.center,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // void main() {
// //   runApp(const MaterialApp(
// //     home: TestScreen(),
// //   ));
// // }









// // import 'package:flutter/material.dart';
// // import 'package:simplytranslate/simplytranslate.dart';
// // import 'package:logger/logger.dart';

// // class TestScreen extends StatefulWidget {
// //   const TestScreen({super.key});

// //   @override
// //   _TestScreenState createState() => _TestScreenState();
// // }

// // class _TestScreenState extends State<TestScreen> {
// //   String translatedText = ''; // Texte traduit
// //   String translationTime = ''; // Temps de traduction
// //   final st = SimplyTranslator(EngineType.libre); // Initialisation du moteur de traduction
// //   final TextEditingController _controller = TextEditingController(); // Contrôleur du champ de texte
// //   bool _isLoading = false; // Indicateur de chargement
// //   final Logger logger = Logger(); // Initialisation du logger

// //   // Listes de langues
// //   final List<String> _languages = ['auto', 'fr', 'en', 'es', 'de', 'it'];
// //   String _selectedFromLang = 'auto'; // Langue source par défaut
// //   String _selectedToLang = 'en'; // Langue cible par défaut

// //   Future<void> _translateText(String text) async {
// //     setState(() {
// //       _isLoading = true; // Indique que la traduction est en cours
// //     });
// //     logger.d('Début de la traduction du texte : $text');

// //     final stopwatch = Stopwatch()..start(); // Démarrer le chronomètre

// //     try {
// //       final Translation translation = await st.translateSimply(
// //         text, // Texte entré par l'utilisateur
// //         from: _selectedFromLang, // Langue source sélectionnée
// //         to: _selectedToLang, // Langue cible sélectionnée
// //         instanceMode: InstanceMode.Loop,
// //         retries: 4,
// //       );

// //       stopwatch.stop(); // Arrêter le chronomètre

// //       setState(() {
// //         translatedText = translation.translations.text; // Mettre à jour le texte traduit
// //         translationTime = 'Temps de traduction: ${stopwatch.elapsedMilliseconds} ms'; // Afficher le temps de traduction
// //       });
// //       logger.d('Traduction réussie en ${stopwatch.elapsedMilliseconds} ms : $translatedText');
// //     } catch (error) {
// //       logger.e('Erreur lors de la traduction : $error');
// //     } finally {
// //       setState(() {
// //         _isLoading = false; // Fin du chargement
// //       });
// //       logger.d('Fin de la traduction');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Test de Traduction'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             TextField(
// //               controller: _controller, // Contrôleur du champ de texte
// //               decoration: const InputDecoration(
// //                 labelText: 'Entrez du texte à traduire',
// //                 border: OutlineInputBorder(),
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             // Liste déroulante pour choisir la langue source
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('Langue d\'origine :'),
// //                 DropdownButton<String>(
// //                   value: _selectedFromLang,
// //                   items: _languages.map((String value) {
// //                     return DropdownMenuItem<String>(
// //                       value: value,
// //                       child: Text(value),
// //                     );
// //                   }).toList(),
// //                   onChanged: (String? newValue) {
// //                     setState(() {
// //                       _selectedFromLang = newValue!;
// //                     });
// //                   },
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 20),
// //             // Liste déroulante pour choisir la langue cible
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('Traduire en :'),
// //                 DropdownButton<String>(
// //                   value: _selectedToLang,
// //                   items: _languages.map((String value) {
// //                     return DropdownMenuItem<String>(
// //                       value: value,
// //                       child: Text(value),
// //                     );
// //                   }).toList(),
// //                   onChanged: (String? newValue) {
// //                     setState(() {
// //                       _selectedToLang = newValue!;
// //                     });
// //                   },
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _isLoading ? null : () => _translateText(_controller.text),
// //               child: _isLoading ? const CircularProgressIndicator() : const Text('Traduire'),
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               translatedText.isEmpty ? 'Traduction affichée ici' : translatedText, // Afficher la traduction
// //               style: const TextStyle(fontSize: 20),
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 10),
// //             Text(
// //               translationTime.isEmpty ? '' : translationTime, // Afficher le temps de traduction
// //               style: const TextStyle(fontSize: 16, color: Colors.grey),
// //               textAlign: TextAlign.center,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // void main() {
// //   runApp(const MaterialApp(
// //     home: TestScreen(),
// //   ));
// // }










// // //FULL OPTION
// // import 'package:flutter/material.dart';
// // // import 'package:simplytranslate/simplytranslate.dart';
// // import 'translator.dart'; // Importez votre fichier translator.dart ici
// // import 'language.dart'; // Importez votre fichier language.dart ici

// // class TestScreen extends StatefulWidget {
// //   const TestScreen({super.key});

// //   @override
// //   _TestScreenState createState() => _TestScreenState();
// // }

// // class _TestScreenState extends State<TestScreen> {
// //   String _fromLanguage = 'auto';
// //   String _toLanguage = 'en';
// //   InstanceMode _instanceMode = InstanceMode.Loop;
// //   EngineType _engineType = EngineType.google;
// //   String _method = 'translateSimply';
// //   String _inputText = '';
// //   String _translatedText = '';
// //   String _translationTime = '';

// //   late SimplyTranslator _translator;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _translator = SimplyTranslator(_engineType);
// //   }

// //   Future<void> _translate() async {
// //     String result;
// //     final stopwatch = Stopwatch()..start();

// //     try {
// //       if (_method == 'translateSimply') {
// //         var translation = await _translator.translateSimply(_inputText, from : _fromLanguage, to : _toLanguage, instanceMode: _instanceMode);
// //         result = translation.translations.text;
// //       } else {
// //         result = await _translator.trSimply(_inputText, _fromLanguage, _toLanguage);
// //       }
// //     } catch (e) {
// //       result = 'Error: $e';
// //     } finally {
// //       stopwatch.stop();
// //       _translationTime = '${stopwatch.elapsed.inMilliseconds} ms';
// //     }

// //     setState(() {
// //       _translatedText = result;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Translator')),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             DropdownButton<String>(
// //               value: _fromLanguage,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _fromLanguage = value!;
// //                 });
// //               },
// //               items: LanguageList.langs.keys.map((code) {
// //                 return DropdownMenuItem<String>(
// //                   value: code,
// //                   child: Text(LanguageList.langs[code]!),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<String>(
// //               value: _toLanguage,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _toLanguage = value!;
// //                 });
// //               },
// //               items: LanguageList.langs.keys.map((code) {
// //                 return DropdownMenuItem<String>(
// //                   value: code,
// //                   child: Text(LanguageList.langs[code]!),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<InstanceMode>(
// //               value: _instanceMode,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _instanceMode = value!;
// //                 });
// //               },
// //               items: InstanceMode.values.map((mode) {
// //                 return DropdownMenuItem<InstanceMode>(
// //                   value: mode,
// //                   child: Text(mode.toString().split('.').last),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<EngineType>(
// //               value: _engineType,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _engineType = value!;
// //                   _translator = SimplyTranslator(_engineType); // Met à jour l'instance du traducteur
// //                 });
// //               },
// //               items: EngineType.values.map((engine) {
// //                 return DropdownMenuItem<EngineType>(
// //                   value: engine,
// //                   child: Text(engine.toString().split('.').last),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<String>(
// //               value: _method,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _method = value!;
// //                 });
// //               },
// //               items: ['translateSimply', 'trSimply'].map((method) {
// //                 return DropdownMenuItem<String>(
// //                   value: method,
// //                   child: Text(method),
// //                 );
// //               }).toList(),
// //             ),
// //             TextField(
// //               onChanged: (value) {
// //                 setState(() {
// //                   _inputText = value;
// //                 });
// //               },
// //               decoration: InputDecoration(labelText: 'Enter text to translate'),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _translate,
// //               child: Text('Translate'),
// //             ),
// //             SizedBox(height: 20),
// //             Text('Translated Text: $_translatedText'),
// //             Text('Translation Time: $_translationTime'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }





// // import 'package:flutter/material.dart';
// // import 'translator.dart'; // Importez votre fichier translator.dart ici
// // import 'language.dart'; // Importez votre fichier language.dart ici

// // class TestScreen extends StatefulWidget {
// //   const TestScreen({super.key});

// //   @override
// //   _TestScreenState createState() => _TestScreenState();
// // }

// // class _TestScreenState extends State<TestScreen> {
// //   String _fromLanguage = 'auto';
// //   String _toLanguage = 'en';
// //   InstanceMode _instanceMode = InstanceMode.Loop;
// //   EngineType _engineType = EngineType.google;
// //   String _method = 'translateSimply';
// //   String _inputText = '';
// //   String _translatedText = '';
// //   String _translationTime = '';
// //   String _url = ''; // Nouvelle variable pour stocker l'URL utilisée

// //   late SimplyTranslator _translator;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _translator = SimplyTranslator(_engineType);
// //   }

// //   Future<void> _translate() async {
// //     String result;
// //     final stopwatch = Stopwatch()..start();

// //     try {
// //       if (_method == 'translateSimply') {
// //         var translation = await _translator.translateSimply(
// //             _inputText,
// //             from: _fromLanguage,
// //             to: _toLanguage,
// //             instanceMode: _instanceMode);
// //         result = translation.translations.text;
// //         _url = _translator.getCurrentInstance; // Récupère l'URL utilisée
// //       } else {
// //         result = await _translator.trSimply(_inputText, _fromLanguage, _toLanguage);
// //         // Vous pouvez adapter ce cas si vous avez accès à l'URL dans ce mode
// //         _url = ''; // Si pas d'URL disponible ici
// //       }
// //     } catch (e) {
// //       result = 'Error: $e';
// //       _url = ''; // En cas d'erreur, réinitialise l'URL
// //     } finally {
// //       stopwatch.stop();
// //       _translationTime = '${stopwatch.elapsed.inMilliseconds} ms';
// //     }

// //     setState(() {
// //       _translatedText = result;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Translator')),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             DropdownButton<String>(
// //               value: _fromLanguage,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _fromLanguage = value!;
// //                 });
// //               },
// //               items: LanguageList.langs.keys.map((code) {
// //                 return DropdownMenuItem<String>(
// //                   value: code,
// //                   child: Text(LanguageList.langs[code]!),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<String>(
// //               value: _toLanguage,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _toLanguage = value!;
// //                 });
// //               },
// //               items: LanguageList.langs.keys.map((code) {
// //                 return DropdownMenuItem<String>(
// //                   value: code,
// //                   child: Text(LanguageList.langs[code]!),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<InstanceMode>(
// //               value: _instanceMode,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _instanceMode = value!;
// //                 });
// //               },
// //               items: InstanceMode.values.map((mode) {
// //                 return DropdownMenuItem<InstanceMode>(
// //                   value: mode,
// //                   child: Text(mode.toString().split('.').last),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<EngineType>(
// //               value: _engineType,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _engineType = value!;
// //                   _translator = SimplyTranslator(_engineType); // Met à jour l'instance du traducteur
// //                 });
// //               },
// //               items: EngineType.values.map((engine) {
// //                 return DropdownMenuItem<EngineType>(
// //                   value: engine,
// //                   child: Text(engine.toString().split('.').last),
// //                 );
// //               }).toList(),
// //             ),
// //             DropdownButton<String>(
// //               value: _method,
// //               onChanged: (value) {
// //                 setState(() {
// //                   _method = value!;
// //                 });
// //               },
// //               items: ['translateSimply', 'trSimply'].map((method) {
// //                 return DropdownMenuItem<String>(
// //                   value: method,
// //                   child: Text(method),
// //                 );
// //               }).toList(),
// //             ),
// //             TextField(
// //               onChanged: (value) {
// //                 setState(() {
// //                   _inputText = value;
// //                 });
// //               },
// //               decoration: InputDecoration(labelText: 'Enter text to translate'),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _translate,
// //               child: Text('Translate'),
// //             ),
// //             SizedBox(height: 20),
// //             Text('Translated Text: $_translatedText'),
// //             Text('Translation Time: $_translationTime'),
// //             SizedBox(height: 20),
// //             Text('URL Used: $_url'), // Nouveau champ pour afficher l'URL
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'translator.dart'; // Importez votre fichier translator.dart ici
// import 'language.dart'; // Importez votre fichier language.dart ici

// class TestScreen extends StatefulWidget {
//   const TestScreen({super.key});

//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   String _fromLanguage = 'auto';
//   String _toLanguage = 'en';
//   InstanceMode _instanceMode = InstanceMode.Loop;
//   EngineType _engineType = EngineType.google;
//   String _method = 'translateSimply';
//   String _inputText = '';
//   String _translatedText = '';
//   String _translationTime = '';
//   String _url = ''; // Nouvelle variable pour stocker l'URL utilisée

//   late SimplyTranslator _translator;
//   final logger = Logger(); // Instance du logger

//   @override
//   void initState() {
//     super.initState();
//     _translator = SimplyTranslator(_engineType);
//     var urlZer = _translator.getCurrentInstance;
//     logger.d("Initial translator setup with engine type: $_engineType");
//     logger.d("TRANSLATOR URL: $urlZer");
//   }

//   Future<void> _translate() async {
//     String result;
//     final stopwatch = Stopwatch()..start();
//     logger.d("Starting translation with method: $_method");

//     try {
//       if (_method == 'translateSimply') {
//         var translation = await _translator.translateSimply(
//             _inputText,
//             from: _fromLanguage,
//             to: _toLanguage,
//             instanceMode: _instanceMode);
//         result = translation.translations.text;
//         _url = _translator.getCurrentInstance; // Récupère l'URL utilisée
//         logger.d("Translation success. URL: $_url");
//         logger.i("Translation success. URL: $_url");
//       } else {
//         result = await _translator.trSimply(_inputText, _fromLanguage, _toLanguage);
//         _url = ''; // Si pas d'URL disponible ici
//         logger.d("Translation success using trSimply");
//       }
//     } catch (e) {
//       result = 'Error: $e';
//       _url = ''; // En cas d'erreur, réinitialise l'URL
//       logger.e("Translation failed: $e");
//     } finally {
//       stopwatch.stop();
//       _translationTime = '${stopwatch.elapsed.inMilliseconds} ms';
//       logger.d("Translation time: $_translationTime");
//     }

//     setState(() {
//       _translatedText = result;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Translator')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButton<String>(
//               value: _fromLanguage,
//               onChanged: (value) {
//                 setState(() {
//                   _fromLanguage = value!;
//                   logger.d("From language changed: $_fromLanguage");
//                 });
//               },
//               items: LanguageList.langs.keys.map((code) {
//                 return DropdownMenuItem<String>(
//                   value: code,
//                   child: Text(LanguageList.langs[code]!),
//                 );
//               }).toList(),
//             ),
//             DropdownButton<String>(
//               value: _toLanguage,
//               onChanged: (value) {
//                 setState(() {
//                   _toLanguage = value!;
//                   logger.d("To language changed: $_toLanguage");
//                 });
//               },
//               items: LanguageList.langs.keys.map((code) {
//                 return DropdownMenuItem<String>(
//                   value: code,
//                   child: Text(LanguageList.langs[code]!),
//                 );
//               }).toList(),
//             ),
//             DropdownButton<InstanceMode>(
//               value: _instanceMode,
//               onChanged: (value) {
//                 setState(() {
//                   _instanceMode = value!;
//                   logger.d("Instance mode changed: $_instanceMode");
//                 });
//               },
//               items: InstanceMode.values.map((mode) {
//                 return DropdownMenuItem<InstanceMode>(
//                   value: mode,
//                   child: Text(mode.toString().split('.').last),
//                 );
//               }).toList(),
//             ),
//             DropdownButton<EngineType>(
//               value: _engineType,
//               onChanged: (value) {
//                 setState(() {
//                   _engineType = value!;
//                   _translator = SimplyTranslator(_engineType); // Met à jour l'instance du traducteur
//                   logger.d("Engine type changed: $_engineType");
//                 });
//               },
//               items: EngineType.values.map((engine) {
//                 return DropdownMenuItem<EngineType>(
//                   value: engine,
//                   child: Text(engine.toString().split('.').last),
//                 );
//               }).toList(),
//             ),
//             DropdownButton<String>(
//               value: _method,
//               onChanged: (value) {
//                 setState(() {
//                   _method = value!;
//                   logger.d("Translation method changed: $_method");
//                 });
//               },
//               items: ['translateSimply', 'trSimply'].map((method) {
//                 return DropdownMenuItem<String>(
//                   value: method,
//                   child: Text(method),
//                 );
//               }).toList(),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _inputText = value;
//                   logger.d("Input text updated: $_inputText");
//                 });
//               },
//               decoration: InputDecoration(labelText: 'Enter text to translate'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _translate,
//               child: Text('Translate'),
//             ),
//             SizedBox(height: 20),
//             Text('Translated Text: $_translatedText'),
//             Text('Translation Time: $_translationTime'),
//             SizedBox(height: 20),
//             Text('URL Used: $_url'), // Nouveau champ pour afficher l'URL
//           ],
//         ),
//       ),
//     );
//   }
// }

// 0) generer tous les fichiers de translate qui sont mentionnés dans main
// 1) supprimer jjtranslate
// 1b) OK faire une branche en reroll le dernier commit pour voir à quel point les traductions dynamiques font lagger
// 2) OK en bar de recherche #lang pour switcher la langue?
// 2b) centrer le bouton comptes suivis et le bouton filtres etc
// 3) anglais par defaut quand le fichier de traduction est absent
// 4) cache pour toutes les strings
// 5) mapbox translate
// 7) à la place du shake, faire ## dans la recherche
// ce fichier est à supprimer et il faut créer un systeme de cache pour les strings (et pour les strings traduites (on utilisera une api avec tant d'appels gratuits par mois pour avoir des traductions plus accurates)) et puis il faut aussi faire mapbox pour traduire la map 

