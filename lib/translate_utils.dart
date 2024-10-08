import 'package:logger/logger.dart';

import 'translator.dart'; // Importez votre fichier translator.dart ici


class CustomTranslate{
  Logger logger = Logger();
  
  Future<String> translate(String inputText, String fromLanguage, String toLanguage) async {
    logger.e(inputText);
    logger.e(toLanguage);
    // logger.e(fromLanguage);
    // logger.e(toLanguage);
    if(toLanguage == "he"){
      toLanguage = "iw";
    }else if(toLanguage == "zh"){
      toLanguage = "zh-cn";
    }
    SimplyTranslator translator = SimplyTranslator(EngineType.google);
    var translation = await translator.translateSimply(
      inputText,
      from: fromLanguage,
      to: toLanguage,
      instanceMode: InstanceMode.Loop);
    var result = translation.translations.text;
    logger.d(result);
    return result;
  }

}