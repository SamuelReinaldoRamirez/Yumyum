import 'translator.dart'; // Importez votre fichier translator.dart ici


class CustomTranslate{
  
  Future<String> translate(String inputText, String fromLanguage, String toLanguage) async {
    SimplyTranslator _translator = SimplyTranslator(EngineType.google);
    var translation = await _translator.translateSimply(
      inputText,
      from: fromLanguage,
      to: toLanguage,
      instanceMode: InstanceMode.Loop);
    var result = translation.translations.text;
    return result;
  }

}